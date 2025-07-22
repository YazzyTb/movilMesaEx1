import 'package:dio/dio.dart';
import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';

/// Clase para la respuesta del carrito desde la API
class CartResponse {
  final int id;
  final int usuario;
  final bool activo;
  final List<CartDetail> detalles;

  // Nuevos campos de resumen con ofertas
  final String totalOriginal;
  final String ahorroTotalOfertas;
  final int cantidadProductos;
  final int cantidadItems;
  final Map<String, dynamic> resumenOfertas;

  CartResponse({
    required this.id,
    required this.usuario,
    required this.activo,
    required this.detalles,
    required this.totalOriginal,
    required this.ahorroTotalOfertas,
    required this.cantidadProductos,
    required this.cantidadItems,
    required this.resumenOfertas,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'],
      usuario: json['usuario'],
      activo: json['activo'],
      detalles: (json['detalles'] as List)
          .map((item) => CartDetail.fromJson(item))
          .toList(),
      totalOriginal: json['total_original'] ?? '0.00',
      ahorroTotalOfertas: json['ahorro_por_ofertas'] ?? '0.00',
      cantidadProductos: json['cantidad_productos'] ?? 0,
      cantidadItems: json['cantidad_items'] ?? 0,
      resumenOfertas: json['resumen_ofertas'] ?? {},
    );
  }

  double get totalNumerico {
    return detalles.where((item) => item.isActive).fold(
        0.0, (sum, item) => sum + (double.tryParse(item.subtotal) ?? 0.0));
  }

  double get totalOriginalNumerico => double.tryParse(totalOriginal) ?? 0.0;
  double get ahorroNumerico => double.tryParse(ahorroTotalOfertas) ?? 0.0;

  bool get tieneOfertas => ahorroNumerico > 0;

  List<CartDetail> get detallesActivos =>
      detalles.where((d) => d.isActive).toList();
}

class CartDetail {
  final int id;
  final BookCartInfo producto;
  final int cantidad;
  final String precioUnitario;
  final String precioOriginal;
  final String descuentoOferta;
  final String? nombreOferta;
  final DateTime? fechaOfertaAplicada;
  final String subtotal;
  final bool isActive;

  // Nuevos campos calculados de ofertas
  final String ahorroTotalOferta;
  final String subtotalOriginal;
  final bool tieneOferta;
  final Map<String, dynamic>? ofertaVigente;

  CartDetail({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioOriginal,
    required this.descuentoOferta,
    this.nombreOferta,
    this.fechaOfertaAplicada,
    required this.subtotal,
    this.isActive = true,
    required this.ahorroTotalOferta,
    required this.subtotalOriginal,
    required this.tieneOferta,
    this.ofertaVigente,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'],
      producto: BookCartInfo.fromJson(json['producto']),
      cantidad: json['cantidad'],
      precioUnitario: json['precio_unitario'],
      precioOriginal: json['precio_original'] ?? json['precio_unitario'],
      descuentoOferta: json['descuento_oferta'] ?? '0.00',
      nombreOferta: json['nombre_oferta'],
      fechaOfertaAplicada: json['fecha_oferta_aplicada'] != null
          ? DateTime.parse(json['fecha_oferta_aplicada'])
          : null,
      subtotal: json['subtotal'],
      isActive: json['is_active'] ?? true,
      ahorroTotalOferta: json['ahorro_por_oferta'] ?? '0.00',
      subtotalOriginal: json['subtotal_original'] ?? json['subtotal'],
      tieneOferta: json['tiene_oferta'] ?? false,
      ofertaVigente: json['oferta_vigente'],
    );
  }

  // Métodos de utilidad
  double get precioNumerico => double.tryParse(precioUnitario) ?? 0.0;
  double get precioOriginalNumerico => double.tryParse(precioOriginal) ?? 0.0;
  double get ahorroNumerico => double.tryParse(ahorroTotalOferta) ?? 0.0;
  double get subtotalNumerico => double.tryParse(subtotal) ?? 0.0;
  double get descuentoNumerico => double.tryParse(descuentoOferta) ?? 0.0;

  bool get ofertaEsVigente => ofertaVigente?['vigente'] ?? false;

  String get estadoOferta {
    if (!tieneOferta) return 'Sin oferta';
    if (ofertaEsVigente) return 'Oferta vigente';
    return 'Oferta expirada';
  }

  // Calcula el porcentaje de descuento
  double get porcentajeDescuento {
    if (!tieneOferta || precioOriginalNumerico == 0) return 0.0;
    return (descuentoNumerico / precioOriginalNumerico) * 100;
  }
}

class BookCartInfo {
  final int id;
  final String nombre;
  final String precio;
  final int stock;
  final String? imagen;

  BookCartInfo({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    this.imagen,
  });

  factory BookCartInfo.fromJson(Map<String, dynamic> json) {
    return BookCartInfo(
      id: json['id'],
      nombre: json['nombre'],
      precio: json['precio'],
      stock: json['stock'],
      imagen: json['imagen'],
    );
  }
}

/// Servicio para gestionar las operaciones del carrito con la API
class CartService {
  /// Obtiene el carrito del usuario
  Future<CartResponse?> getCart() async {
    try {
      print('CartService: Enviando solicitud GET a ${ApiEndpoints.cart}');
      final response = await DioConfig.dio.get(ApiEndpoints.cart);
      print(
          'CartService: Respuesta recibida con código ${response.statusCode}');

      if (response.statusCode == 200) {
        print('CartService: Parseando datos de respuesta: ${response.data}');

        try {
          // Comprobar si la respuesta es una lista o un mapa
          if (response.data is List) {
            // Si es una lista, usar el primer elemento si está disponible
            if ((response.data as List).isNotEmpty) {
              return CartResponse.fromJson(response.data[0]);
            } else {
              print('CartService: Respuesta es una lista vacía');
              return null;
            }
          } else {
            // Procesar como mapa (original)
            return CartResponse.fromJson(response.data);
          }
        } catch (parseError) {
          print('CartService: Error parseando datos: $parseError');
          throw Exception('Error al procesar datos del carrito: $parseError');
        }
      } else {
        print('CartService: Error código ${response.statusCode}');
        throw Exception('Error al cargar el carrito: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'CartService: DioException - Tipo: ${e.type}, Mensaje: ${e.message}');
      print('CartService: Datos de respuesta: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        // Si no se encuentra el carrito, devolver null
        print('CartService: 404 - Carrito no encontrado');
        return null;
      }

      throw _handleDioError(e);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Añade un item al carrito
  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final data = {
        'producto_id': productId,
        'cantidad': quantity,
      };

      print(
          'CartService: Añadiendo producto $productId con cantidad $quantity');
      final response = await DioConfig.dio.post(
        ApiEndpoints.cartDetail,
        data: data,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      print('CartService: Error añadiendo al carrito: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Actualiza la cantidad de un item en el carrito
  Future<bool> updateCartItemQuantity(int itemId, int quantity) async {
    try {
      print('CartService: Actualizando item $itemId con cantidad $quantity');

      final data = {
        'cantidad': quantity,
      };

      final response = await DioConfig.dio.patch(
        '${ApiEndpoints.cartDetail}$itemId/',
        data: data,
      );

      print('CartService: Respuesta de actualización: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('CartService: Item actualizado exitosamente');
        return true;
      } else {
        print('CartService: Error en actualización: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('CartService: DioException actualizando item: ${e.message}');
      print('CartService: Respuesta de error: ${e.response?.data}');

      // Intentar extraer mensaje de error específico
      String errorMessage = 'Error actualizando item';
      if (e.response?.data is Map) {
        final errorData = e.response!.data as Map;
        if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('non_field_errors')) {
          errorMessage = errorData['non_field_errors'][0];
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Elimina un item del carrito
  Future<bool> removeCartItem(int itemId) async {
    try {
      print('CartService: Eliminando item $itemId del carrito');
      final response = await DioConfig.dio.delete(
        '${ApiEndpoints.cartDetail}$itemId/',
      );

      return response.statusCode == 204;
    } on DioException catch (e) {
      print('CartService: Error eliminando item: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Actualiza los precios del carrito según ofertas vigentes
  Future<bool> actualizarPreciosCarrito(int cartId) async {
    try {
      print('CartService: Actualizando precios del carrito $cartId');
      final response = await DioConfig.dio.post(
        '${ApiEndpoints.libraryBase}/carrito/$cartId/actualizar-precios/',
      );

      print(
          'CartService: Precios actualizados con código ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('CartService: Error actualizando precios: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Vacía el carrito
  Future<bool> vaciarCarrito(int cartId) async {
    try {
      print('CartService: Vaciando carrito $cartId');
      final response = await DioConfig.dio.delete(
        '${ApiEndpoints.libraryBase}/carrito/$cartId/vaciar/',
      );

      print('CartService: Carrito vaciado con código ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('CartService: Error vaciando carrito: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Convierte un carrito a pedido
  Future<bool> convertCartToOrder(int cartId) async {
    try {
      print('CartService: Convirtiendo carrito $cartId a pedido');
      final response = await DioConfig.dio.post(
        '${ApiEndpoints.libraryBase}/carrito/$cartId/convertir-a-pedido/',
      );

      final success = response.statusCode == 200 || response.statusCode == 201;
      print(
          'CartService: Conversión ${success ? 'exitosa' : 'fallida'} con código ${response.statusCode}');
      return success;
    } on DioException catch (e) {
      print('CartService: Error convirtiendo carrito a pedido: ${e.message}');
      print('CartService: Datos de respuesta: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error al procesar el pedido: $e');
    }
  }

  /// Obtiene recomendaciones basadas en el carrito
  Future<List<Book>> getCartRecommendations(int cartId) async {
    try {
      print('CartService: Obteniendo recomendaciones para carrito $cartId');
      final response = await DioConfig.dio.get(
        '${ApiEndpoints.libraryBase}/carrito/$cartId/recomendaciones/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> booksJson = response.data['recomendaciones'];
        return booksJson.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('CartService: Error obteniendo recomendaciones: ${e.message}');
      return []; // Devolver lista vacía en lugar de error
    } catch (e) {
      print('CartService: Error inesperado obteniendo recomendaciones: $e');
      return [];
    }
  }

  /// Gestiona los errores de Dio
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Error de conexión: Tiempo de espera agotado.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No se pudo conectar al servidor.');
    } else if (e.response?.statusCode == 401) {
      return Exception('Sesión expirada. Por favor inicie sesión nuevamente.');
    } else {
      return Exception(DioConfig.handleDioError(e));
    }
  }
}
