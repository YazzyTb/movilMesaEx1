import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';

class LibraryService extends ChangeNotifier {
  final List<Book> _books = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Constructor
  LibraryService() {
    loadBooks();
  }

  // Refresh books
  Future<void> refreshBooks() async {
    await loadBooks();
  }

  // Load books from API
  Future<void> loadBooks() async {
    _setLoading(true);
    _clearError();

    try {
      // Verificar que el token está disponible
      final prefs = UserPreferences();
      print('LOADING BOOKS - Token disponible: ${prefs.token.isNotEmpty}');
      print('LOADING BOOKS - Token value: ${prefs.token}');

      print('LOADING BOOKS - Realizando solicitud a: ${ApiEndpoints.products}');
      final response = await DioConfig.dio.get(ApiEndpoints.products);

      print('LOADING BOOKS - Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('LOADING BOOKS - Respuesta exitosa');
        final List<dynamic> booksJson = response.data;
        print(
            'LOADING BOOKS - Número de libros recibidos: ${booksJson.length}');

        _books.clear();
        for (var item in booksJson) {
          _books.add(Book.fromJson(item));
        }

        notifyListeners();
      } else if (response.statusCode == 401) {
        print('LOADING BOOKS - ERROR DE AUTORIZACIÓN 401');
        print('LOADING BOOKS - Respuesta: ${response.data}');
        _setError(
            'Error de autorización. Por favor inicie sesión nuevamente. (${response.statusCode})');
      } else {
        print('LOADING BOOKS - ERROR: StatusCode ${response.statusCode}');
        print('LOADING BOOKS - Response data: ${response.data}');
        _setError('Error al cargar los libros: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('LOADING BOOKS - DioException: ${e.type}');
      print('LOADING BOOKS - DioException mensaje: ${e.message}');
      if (e.response != null) {
        print('LOADING BOOKS - DioException status: ${e.response?.statusCode}');
        print('LOADING BOOKS - DioException data: ${e.response?.data}');
      }
      _setError(DioConfig.handleDioError(e));
    } catch (e) {
      print('LOADING BOOKS - Error inesperado: $e');
      _setError('Error inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
