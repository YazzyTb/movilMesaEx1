import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/services/cart_service.dart';

class RecommendationService with ChangeNotifier {
  final UserPreferences _prefs = UserPreferences();
  final CartService _cartService = CartService();

  List<Book> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches recommendations based on the items in the cart
  /// or based on user's browsing history if cart is empty
  Future<List<Book>> getRecommendations({List<int>? bookIds}) async {
    _setLoading(true);
    _clearError();

    try {
      // First get the current cart to obtain cart ID
      final cartResponse = await _cartService.getCart();

      if (cartResponse == null) {
        print(
            'RecommendationService: No active cart found, returning mock data');
        await _getMockRecommendations();
        return _recommendations;
      }

      final cartId = cartResponse.id;
      print(
          'RecommendationService: Using cart ID: $cartId for recommendations');

      // Build the recommendation URL
      final url =
          '${ApiEndpoints.libraryBase}/carrito/$cartId/recomendaciones/';
      print('RecommendationService: Requesting recommendations from: $url');

      final response = await DioConfig.dio.get(url);

      if (response.statusCode == 200) {
        print('RecommendationService: Successfully received recommendations');
        final responseData = response.data;

        // Verificar si la respuesta tiene el formato esperado
        if (responseData is Map &&
            responseData.containsKey('recomendaciones')) {
          final List<dynamic> booksJson = responseData['recomendaciones'];
          print(
              'RecommendationService: Number of recommendations: ${booksJson.length}');

          _recommendations.clear();
          for (var item in booksJson) {
            _recommendations.add(Book.fromJson(item));
          }
        } else {
          print(
              'RecommendationService: Unexpected response format, using mock data');
          await _getMockRecommendations();
        }

        notifyListeners();
        return _recommendations;
      } else {
        print(
            'RecommendationService: Unexpected status code: ${response.statusCode}');
        _setError('Error al cargar recomendaciones: ${response.statusCode}');
        await _getMockRecommendations();
        return _recommendations;
      }
    } on DioException catch (e) {
      print('RecommendationService: DioException: ${e.type}');
      print('RecommendationService: DioException message: ${e.message}');

      if (e.response != null) {
        print('RecommendationService: Status: ${e.response?.statusCode}');
        print('RecommendationService: Data: ${e.response?.data}');

        // Si es 503 (Service Unavailable), usar datos mock sin mostrar error
        if (e.response?.statusCode == 503) {
          print('RecommendationService: Service unavailable, using mock data');
          await _getMockRecommendations();
          return _recommendations;
        }
      }

      _setError(_handleDioError(e));
      await _getMockRecommendations();
      return _recommendations;
    } catch (e) {
      print('RecommendationService: Unexpected error: $e');
      _setError('Error inesperado: $e');
      await _getMockRecommendations();
      return _recommendations;
    } finally {
      _setLoading(false);
    }
  }

  /// Provides mock recommendations for demonstration purposes
  Future<void> _getMockRecommendations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data
    _recommendations = [
      Book(
        id: 101,
        nombre: "Xiaomi Redmi Note 14 PRO 5G 8+256GB Blanco",
        descripcion:
            "El Xiaomi Redmi Note 14 Pro 5G es la opción ideal para quienes buscan un smartphone con tecnología de última generación, conectividad ultrarrápida y un rendimiento excepcional en todas sus funciones",
        stock: 15,
        imagen:
            "https://www.tutiendaexperta.com/5109-large_default_2x/xiaomi-redmi-note-14-pro-5g-8gb256gb.jpg",
        precio: "3500",
        precioConDescuento: "4000.0",
        descuentoAplicado: "true",
        tieneOfertaVigente: true,
        isActive: true,
      ),
      Book(
        id: 102,
        nombre: "Xiaomi Poco X7 8+256GB Negro",
        descripcion:
            "El Xiaomi Poco X7 es la elección perfecta para quienes buscan potencia, almacenamiento y una experiencia fluida en un smartphone confiable y moderno.",
        stock: 20,
        imagen:
            "https://www.celulares.com/fotos/xiaomi-poco-x7-pro-98030-g.jpg",
        precio: "4500",
        precioConDescuento: "5990.0",
        descuentoAplicado: "true",
        tieneOfertaVigente: true,
        isActive: true,
      ),
      Book(
        id: 103,
        nombre: "Honor 200 5G 12+256GB Negro",
        descripcion:
            "El Honor 200 destaca por su diseño elegantemente sofisticado. Su pantalla completa con bordes casi invisibles ofrece una experiencia visual impresionante.",
        stock: 10,
        imagen:
            "https://corprotec.com/wp-content/uploads/2024/01/Honor-200-pro.webp",
        precio: "6500",
        precioConDescuento: " 5990.0",
        descuentoAplicado: "true",
        tieneOfertaVigente: true,
        isActive: true,
      ),
    ];

    notifyListeners();
  }

  /// Handles Dio errors
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Error de conexión: Tiempo de espera agotado.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor.';
    } else if (e.response?.statusCode == 401) {
      return 'Sesión expirada. Por favor inicie sesión nuevamente.';
    } else {
      return DioConfig.handleDioError(e);
    }
  }

  // Utility methods for state management
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
