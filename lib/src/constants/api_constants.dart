/// API endpoints for the application
class ApiEndpoints {
  /// Base path for library API
  static const String libraryBase = '/Libreria';

  /// Products endpoint for getting books
  static const String products = '$libraryBase/productos/';

  /// Cart endpoints
  static const String cart = '$libraryBase/carrito/activo/';
  static const String cartDetail = '$libraryBase/detalle-carrito/';

  /// Orders endpoint for getting order history
  static const String orders = '$libraryBase/pedidos/';
}
