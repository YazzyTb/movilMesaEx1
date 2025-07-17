import 'package:dio/dio.dart';
import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';

/// Clase para la respuesta del carrito desde la API
class CartResponse {
  final int id;
  final int usuario;
  final bool activo;
  final List<CartDetail> detalles;

  CartResponse({
    required this.id,
    required this.usuario,
    required this.activo,
    required this.detalles,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      id: json['id'],
      usuario: json['usuario'],
      activo: json['activo'],
      detalles: (json['detalles'] as List)
          .map((item) => CartDetail.fromJson(item))
          .toList(),
    );
  }
}

class CartDetail {
  final int id;
  final BookCartInfo producto;
  final int cantidad;
  final String precioUnitario;
  final String subtotal;

  CartDetail({
    required this.id,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'],
      producto: BookCartInfo.fromJson(json['producto']),
      cantidad: json['cantidad'],
      precioUnitario: json['precio_unitario'],
      subtotal: json['subtotal'],
    );
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
              return CartResponse.fromJson(response.data);
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
      final data = {
        'cantidad': quantity,
      };

      final response = await DioConfig.dio.patch(
        '${ApiEndpoints.cartDetail}$itemId/',
        data: data,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('CartService: Error actualizando item: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('CartService: Error inesperado: ${e.toString()}');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Elimina un item del carrito
  Future<bool> removeCartItem(int itemId) async {
    try {
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
