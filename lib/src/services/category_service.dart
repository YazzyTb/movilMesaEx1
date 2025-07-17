import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/category_model.dart';

class CategoryService extends ChangeNotifier {
  final List<Category> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Constructor
  CategoryService() {
    loadCategories();
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // Load categories from API
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final categoriesEndpoint = '${ApiEndpoints.libraryBase}/categorias/';
      print('LOADING CATEGORIES - Realizando solicitud a: $categoriesEndpoint');

      final response = await DioConfig.dio.get(categoriesEndpoint);

      print('LOADING CATEGORIES - Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('LOADING CATEGORIES - Respuesta exitosa');
        final List<dynamic> categoriesJson = response.data;
        print(
            'LOADING CATEGORIES - Número de categorías recibidas: ${categoriesJson.length}');

        _categories.clear();
        for (var item in categoriesJson) {
          _categories.add(Category.fromJson(item));
        }

        notifyListeners();
      } else if (response.statusCode == 401) {
        print('LOADING CATEGORIES - ERROR DE AUTORIZACIÓN 401');
        print('LOADING CATEGORIES - Respuesta: ${response.data}');
        _setError(
            'Error de autorización. Por favor inicie sesión nuevamente. (${response.statusCode})');
      } else {
        print('LOADING CATEGORIES - ERROR: StatusCode ${response.statusCode}');
        print('LOADING CATEGORIES - Response data: ${response.data}');
        _setError('Error al cargar las categorías: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('LOADING CATEGORIES - DioException: ${e.type}');
      print('LOADING CATEGORIES - DioException mensaje: ${e.message}');
      if (e.response != null) {
        print(
            'LOADING CATEGORIES - DioException status: ${e.response?.statusCode}');
        print('LOADING CATEGORIES - DioException data: ${e.response?.data}');
      }
      _setError(DioConfig.handleDioError(e));
    } catch (e) {
      print('LOADING CATEGORIES - Error inesperado: $e');
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
