import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:exam1_software_movil/src/models/order_model.dart';
import 'package:exam1_software_movil/src/constants/constants.dart';

class OrderService extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carga el historial de pedidos del usuario
  Future<void> loadOrders() async {
    _setLoading(true);
    _clearError();

    try {
      print('OrderService: Enviando solicitud GET a ${ApiEndpoints.orders}');
      final response = await DioConfig.dio.get(ApiEndpoints.orders);
      print(
          'OrderService: Respuesta recibida con código ${response.statusCode}');

      if (response.statusCode == 200) {
        print('OrderService: Parseando datos de respuesta');
        final List<dynamic> ordersJson = response.data;
        _orders = ordersJson.map((json) => Order.fromJson(json)).toList();

        // Ordenar los pedidos por fecha (más recientes primero)
        _orders.sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));

        print('OrderService: ${_orders.length} pedidos cargados');
      } else {
        print('OrderService: Error código ${response.statusCode}');
        _setError('Error al cargar pedidos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'OrderService: DioException - Tipo: ${e.type}, Mensaje: ${e.message}');
      print('OrderService: Datos de respuesta: ${e.response?.data}');
      _setError(DioConfig.handleDioError(e));
    } catch (e) {
      print('OrderService: Error inesperado: ${e.toString()}');
      _setError('Error inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

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
