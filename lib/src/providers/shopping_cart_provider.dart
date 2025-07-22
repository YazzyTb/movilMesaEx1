import 'package:flutter/material.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/services/cart_service.dart';

/// Modelo para representar un ítem en el carrito
class CartItem {
  final Book book;
  final int quantity;
  final String? priceUnit;
  final String? subtotal;
  final int? id;
  final CartDetail?
      cartDetail; // NUEVO: Referencia al detalle completo del carrito

  CartItem({
    required this.book,
    required this.quantity,
    this.priceUnit,
    this.subtotal,
    this.id,
    this.cartDetail, // NUEVO
  });

  // Helpers para ofertas
  bool get tieneOferta => cartDetail?.tieneOferta ?? false;
  double get ahorroTotal => cartDetail?.ahorroNumerico ?? 0.0;
  String get nombreOferta => cartDetail?.nombreOferta ?? '';
  bool get ofertaVigente => cartDetail?.ofertaEsVigente ?? false;

  // Precio efectivo considerando ofertas
  double get precioEfectivo {
    if (cartDetail != null) {
      return cartDetail!.precioNumerico;
    }
    return double.tryParse(book.precio) ?? 0.0;
  }

  // Subtotal efectivo
  double get subtotalEfectivo {
    if (cartDetail != null) {
      return cartDetail!.subtotalNumerico;
    }
    return precioEfectivo * quantity;
  }
}

/// Provider para gestionar el estado del carrito de compras
class ShoppingCartProvider extends ChangeNotifier {
  final CartService _cartService;

  // Constructor que permite inyectar un CartService (útil para pruebas)
  ShoppingCartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  CartResponse? _cartResponse; // NUEVO: Respuesta completa del carrito

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CartResponse? get cartResponse => _cartResponse;

  int get itemCount => _items.length;

  // ACTUALIZADO: Calcular total considerando ofertas
  double get totalAmount {
    if (_cartResponse != null) {
      return _cartResponse!.totalNumerico;
    }

    // Fallback al cálculo manual
    double total = 0.0;
    for (var item in _items) {
      total += item.subtotalEfectivo;
    }
    return total;
  }

  // NUEVO: Total original sin ofertas
  double get totalOriginal {
    if (_cartResponse != null) {
      return _cartResponse!.totalOriginalNumerico;
    }

    // Fallback al cálculo manual
    double total = 0.0;
    for (var item in _items) {
      if (item.cartDetail != null) {
        total += item.cartDetail!.precioOriginalNumerico * item.quantity;
      } else {
        total += (double.tryParse(item.book.precio) ?? 0) * item.quantity;
      }
    }
    return total;
  }

  // NUEVO: Total de ahorros por ofertas
  double get totalAhorros {
    if (_cartResponse != null) {
      return _cartResponse!.ahorroNumerico;
    }

    // Fallback al cálculo manual
    double ahorro = 0.0;
    for (var item in _items) {
      ahorro += item.ahorroTotal * item.quantity;
    }
    return ahorro;
  }

  // NUEVO: Verificar si hay ofertas en el carrito
  bool get tieneOfertas => totalAhorros > 0;

  // NUEVO: Obtener estadísticas de ofertas
  Map<String, dynamic> get estadisticasOfertas {
    int productosConOferta = 0;
    int productosSinOferta = 0;
    Map<String, int> ofertasPorNombre = {};

    for (var item in _items) {
      if (item.tieneOferta) {
        productosConOferta++;
        final nombreOferta = item.nombreOferta;
        if (nombreOferta.isNotEmpty) {
          ofertasPorNombre[nombreOferta] =
              (ofertasPorNombre[nombreOferta] ?? 0) + 1;
        }
      } else {
        productosSinOferta++;
      }
    }

    return {
      'productos_con_oferta': productosConOferta,
      'productos_sin_oferta': productosSinOferta,
      'ofertas_por_nombre': ofertasPorNombre,
      'total_ahorros': totalAhorros,
      'porcentaje_ahorro':
          totalOriginal > 0 ? (totalAhorros / totalOriginal) * 100 : 0,
    };
  }

  /// Carga los items del carrito desde la API
  Future<void> loadCart() async {
    print('ShoppingCartProvider: Iniciando loadCart()');
    _setLoading(true);
    _clearError();

    try {
      final cartData = await _cartService.getCart();

      _items.clear();

      if (cartData != null) {
        _cartResponse = cartData;
        print(
            'ShoppingCartProvider: Encontrados ${cartData.detalles.length} items en el carrito');
        print(
            'ShoppingCartProvider: Total original: ${cartData.totalOriginal}');
        print(
            'ShoppingCartProvider: Total ahorros: ${cartData.ahorroTotalOfertas}');

        for (var detail in cartData.detallesActivos) {
          final libro = Book(
            id: detail.producto.id,
            nombre: detail.producto.nombre,
            descripcion: '',
            stock: detail.producto.stock,
            imagen: detail.producto.imagen ?? '',
            precio: detail.producto.precio,
            isActive: true,
            // Campos de ofertas - usar datos del cartDetail si están disponibles
            precioConDescuento: detail.precioUnitario,
            descuentoAplicado: detail.descuentoOferta,
            tieneOfertaVigente: detail.tieneOferta,
          );

          _items.add(CartItem(
            book: libro,
            quantity: detail.cantidad,
            priceUnit: detail.precioUnitario,
            subtotal: detail.subtotal,
            id: detail.id,
            cartDetail: detail, // NUEVO: Guardar referencia completa
          ));
        }

        print('ShoppingCartProvider: Items procesados con ofertas aplicadas');
      } else {
        print('ShoppingCartProvider: Carrito vacío o no encontrado');
        _cartResponse = null;
      }

      // Usar microtask para evitar notificar durante el build
      Future.microtask(() {
        print(
            'ShoppingCartProvider: Notificando listeners con ${_items.length} items');
        notifyListeners();
      });
    } catch (e) {
      print('ShoppingCartProvider: Error: ${e.toString()}');
      _setError(e.toString());
    } finally {
      print('ShoppingCartProvider: Finalizado loadCart()');
      _setLoading(false);
    }
  }

  /// Añade un libro al carrito
  Future<bool> addItemToCart(Book book, int quantity) async {
    _setLoading(true);
    _clearError();

    try {
      print(
          'ShoppingCartProvider: Añadiendo ${book.nombre} (cantidad: $quantity)');
      final success = await _cartService.addToCart(book.id, quantity);

      if (success) {
        print(
            'ShoppingCartProvider: Producto añadido exitosamente, recargando carrito');
        await loadCart(); // Recargar carrito después de añadir
        return true;
      } else {
        _setError('Error al añadir al carrito');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error añadiendo producto: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza la cantidad de un item en el carrito
  Future<bool> updateCartItemQuantity(int itemId, int quantity) async {
    _setLoading(true);
    _clearError();

    try {
      print(
          'ShoppingCartProvider: Actualizando cantidad del item $itemId a $quantity');
      final success =
          await _cartService.updateCartItemQuantity(itemId, quantity);

      if (success) {
        await loadCart(); // Recargar carrito después de actualizar
        return true;
      } else {
        _setError('Error al actualizar carrito');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error actualizando cantidad: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un item del carrito
  Future<bool> removeCartItem(int itemId) async {
    _setLoading(true);
    _clearError();

    try {
      print('ShoppingCartProvider: Eliminando item $itemId');
      final success = await _cartService.removeCartItem(itemId);

      if (success) {
        await loadCart(); // Recargar carrito después de eliminar
        return true;
      } else {
        _setError('Error al eliminar item');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error eliminando item: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// NUEVO: Actualiza los precios del carrito según ofertas vigentes
  Future<bool> updateCartPrices() async {
    if (_cartResponse == null) {
      _setError('No hay carrito activo para actualizar');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print(
          'ShoppingCartProvider: Actualizando precios del carrito ${_cartResponse!.id}');
      final success =
          await _cartService.actualizarPreciosCarrito(_cartResponse!.id);

      if (success) {
        await loadCart(); // Recargar carrito después de actualizar precios
        print('ShoppingCartProvider: Precios actualizados exitosamente');
        return true;
      } else {
        _setError('Error al actualizar precios');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error actualizando precios: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// NUEVO: Vacía completamente el carrito
  Future<bool> emptyCart() async {
    if (_cartResponse == null) {
      _setError('No hay carrito activo para vaciar');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('ShoppingCartProvider: Vaciando carrito ${_cartResponse!.id}');
      final success = await _cartService.vaciarCarrito(_cartResponse!.id);

      if (success) {
        await loadCart(); // Recargar carrito después de vaciarlo
        print('ShoppingCartProvider: Carrito vaciado exitosamente');
        return true;
      } else {
        _setError('Error al vaciar carrito');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error vaciando carrito: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// NUEVO: Obtiene recomendaciones basadas en el carrito
  Future<List<Book>> getCartRecommendations() async {
    if (_cartResponse == null) {
      print(
          'ShoppingCartProvider: No hay carrito activo para obtener recomendaciones');
      return [];
    }

    try {
      print(
          'ShoppingCartProvider: Obteniendo recomendaciones para carrito ${_cartResponse!.id}');
      final recommendations =
          await _cartService.getCartRecommendations(_cartResponse!.id);
      print(
          'ShoppingCartProvider: Obtenidas ${recommendations.length} recomendaciones');
      return recommendations;
    } catch (e) {
      print('ShoppingCartProvider: Error obteniendo recomendaciones: $e');
      return [];
    }
  }

  /// Procesa una compra con datos de pago (implementación simulada)
  /// En un entorno real, este método enviaría los datos de pago a un backend
  /// que se comunicaría con Stripe
  Future<bool> processPurchase() async {
    _setLoading(true);
    _clearError();

    try {
      // Verificar que tengamos un carrito activo
      if (_cartResponse == null) {
        print('ShoppingCartProvider: No hay carrito activo para procesar');
        _setError('No se encontró un carrito activo para procesar');
        return false;
      }

      final int cartId = _cartResponse!.id;
      print('ShoppingCartProvider: Procesando compra para carrito $cartId');

      // Mostrar información de la compra antes de procesar
      print(
          'ShoppingCartProvider: Total original: \${totalOriginal.toStringAsFixed(2)}');
      print(
          'ShoppingCartProvider: Total con ofertas: \${totalAmount.toStringAsFixed(2)}');
      print(
          'ShoppingCartProvider: Ahorro total: \${totalAhorros.toStringAsFixed(2)}');

      // Simulamos un procesamiento de pago exitoso
      // En una implementación real, aquí se enviarían los datos de la tarjeta
      // y del carrito al backend
      await Future.delayed(
          const Duration(seconds: 2)); // Simulación de llamada API

      // Convertir el carrito a pedido solo si el pago fue exitoso
      try {
        final orderSuccess = await _cartService.convertCartToOrder(cartId);

        if (!orderSuccess) {
          print('ShoppingCartProvider: Error al convertir carrito a pedido');
          _setError(
              'El pago fue procesado pero hubo un error al crear el pedido');
          return false;
        }

        print('ShoppingCartProvider: Carrito convertido a pedido exitosamente');
        print(
            'ShoppingCartProvider: Compra completada con ahorro de \${totalAhorros.toStringAsFixed(2)}');

        // Limpiar el carrito local después de convertir a pedido exitosamente
        _items.clear();
        _cartResponse = null;
        notifyListeners();

        return true;
      } catch (e) {
        print('ShoppingCartProvider: Error convirtiendo carrito a pedido: $e');
        _setError(
            'El pago fue procesado pero hubo un error al crear el pedido: $e');
        return false;
      }
    } catch (e) {
      print('ShoppingCartProvider: Error en procesamiento de pago: $e');
      _setError('Error al procesar el pago: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia el carrito localmente
  Future<void> clearCart() async {
    print('ShoppingCartProvider: Limpiando carrito localmente');
    _items.clear();
    _cartResponse = null;
    notifyListeners();
  }

  // Métodos auxiliares para gestionar estados de carga/error
  void _setLoading(bool value) {
    _isLoading = value;
    // Usar microtask para evitar llamar durante build
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _setError(String message) {
    _errorMessage = message;
    // Usar microtask para evitar llamar durante build
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// NUEVO: Método para obtener un resumen detallado del carrito
  Map<String, dynamic> getCartSummary() {
    return {
      'item_count': itemCount,
      'total_original': totalOriginal,
      'total_with_offers': totalAmount,
      'total_savings': totalAhorros,
      'has_offers': tieneOfertas,
      'savings_percentage':
          totalOriginal > 0 ? (totalAhorros / totalOriginal) * 100 : 0,
      'offer_statistics': estadisticasOfertas,
      'cart_id': _cartResponse?.id,
      'is_empty': _items.isEmpty,
    };
  }

  /// NUEVO: Método para imprimir información de debug del carrito
  void printCartDebugInfo() {
    print('=== CART DEBUG INFO ===');
    print('Items count: ${_items.length}');
    print('Total original: \${totalOriginal.toStringAsFixed(2)}');
    print('Total with offers: \${totalAmount.toStringAsFixed(2)}');
    print('Total savings: \${totalAhorros.toStringAsFixed(2)}');
    print('Has offers: $tieneOfertas');

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      print('Item $i: ${item.book.nombre}');
      print('  - Quantity: ${item.quantity}');
      print('  - Has offer: ${item.tieneOferta}');
      print('  - Offer name: ${item.nombreOferta}');
      print('  - Price: \${item.precioEfectivo.toStringAsFixed(2)}');
      print('  - Subtotal: \${item.subtotalEfectivo.toStringAsFixed(2)}');
      print('  - Savings: \${item.ahorroTotal.toStringAsFixed(2)}');
    }
    print('======================');
  }
}
