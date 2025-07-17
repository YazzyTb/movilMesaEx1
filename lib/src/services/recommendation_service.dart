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
        final List<dynamic> booksJson = response.data['recomendaciones'];
        print(
            'RecommendationService: Number of recommendations: ${booksJson.length}');

        _recommendations.clear();
        for (var item in booksJson) {
          _recommendations.add(Book.fromJson(item));
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
        nombre: "Cien años de soledad",
        descripcion:
            "Una de las obras más importantes de la literatura latinoamericana",
        stock: 15,
        imagen:
            "https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        precio: "24.99",
        isActive: true,
      ),
      Book(
        id: 102,
        nombre: "El principito",
        descripcion:
            "Una historia poética que aborda temas profundos como el sentido de la vida",
        stock: 20,
        imagen:
            "https://images.unsplash.com/photo-1589998059171-988d887df646?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        precio: "14.99",
        isActive: true,
      ),
      Book(
        id: 103,
        nombre: "Don Quijote de la Mancha",
        descripcion: "La obra cumbre de la literatura española",
        stock: 10,
        imagen:
            "https://images.unsplash.com/photo-1532012197267-da84d127e765?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        precio: "29.99",
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
