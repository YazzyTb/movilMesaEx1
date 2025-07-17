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

  CartItem({
    required this.book,
    required this.quantity,
    this.priceUnit,
    this.subtotal,
    this.id,
  });
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
  CartResponse? _cartResponse;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CartResponse? get cartResponse => _cartResponse;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      if (item.subtotal != null) {
        total += double.tryParse(item.subtotal!) ?? 0;
      } else {
        total += (double.tryParse(item.book.precio) ?? 0) * item.quantity;
      }
    }
    return total;
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

        for (var detail in cartData.detalles) {
          final libro = Book(
            id: detail.producto.id,
            nombre: detail.producto.nombre,
            descripcion: '',
            stock: detail.producto.stock,
            imagen: detail.producto.imagen ?? '',
            precio: detail.producto.precio,
            isActive: true,
          );

          _items.add(CartItem(
            book: libro,
            quantity: detail.cantidad,
            priceUnit: detail.precioUnitario,
            subtotal: detail.subtotal,
            id: detail.id,
          ));
        }
      } else {
        print('ShoppingCartProvider: Carrito vacío o no encontrado');
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
      final success = await _cartService.addToCart(book.id, quantity);

      if (success) {
        await loadCart(); // Recargar carrito después de añadir
        return true;
      } else {
        _setError('Error al añadir al carrito');
        return false;
      }
    } catch (e) {
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
      final success = await _cartService.removeCartItem(itemId);

      if (success) {
        await loadCart(); // Recargar carrito después de eliminar
        return true;
      } else {
        _setError('Error al eliminar item');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
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
    _items.clear();
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
}
