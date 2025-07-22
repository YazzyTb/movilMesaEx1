/// API endpoints for the application
class ApiEndpoints {
  /// Base path for library API
  static const String libraryBase = '/Libreria';

  /// Products endpoints
  static const String products = '$libraryBase/productos/';
  static const String productsOnSale = '$libraryBase/productos/en-oferta/';

  /// Categories endpoint
  static const String categories = '$libraryBase/categorias/';

  /// Authors endpoints
  static const String authors = '$libraryBase/autores/';

  /// Genres endpoints
  static const String genres = '$libraryBase/generos/';

  /// Publishers endpoints
  static const String publishers = '$libraryBase/editoriales/';

  /// Offers endpoints
  static const String offers = '$libraryBase/ofertas/';
  static const String activeOffers = '$libraryBase/ofertas/vigentes/';
  static const String upcomingOffers = '$libraryBase/ofertas/proximas/';
  static const String expiredOffers = '$libraryBase/ofertas/expiradas/';

  /// Cart endpoints
  static const String cart = '$libraryBase/carrito/activo/';
  static const String cartDetail = '$libraryBase/detalle-carrito/';

  /// Cart management endpoints
  static String cartUpdatePrices(int cartId) =>
      '$libraryBase/carrito/$cartId/actualizar-precios/';
  static String cartEmpty(int cartId) => '$libraryBase/carrito/$cartId/vaciar/';
  static String cartConvertToOrder(int cartId) =>
      '$libraryBase/carrito/$cartId/convertir-a-pedido/';
  static String cartRecommendations(int cartId) =>
      '$libraryBase/carrito/$cartId/recomendaciones/';

  /// Orders endpoints
  static const String orders = '$libraryBase/pedidos/';
  static const String orderDetails = '$libraryBase/detalles/';
  static const String myOrders = '$libraryBase/pedidos/mis-pedidos/';

  /// Order management endpoints
  static String orderRate(int orderId) =>
      '$libraryBase/pedidos/$orderId/calificar/';
  static String orderCalculateTotal(int orderId) =>
      '$libraryBase/pedidos/$orderId/calcular-total/';

  /// Product management endpoints (for offers)
  static String productApplyOffer(int productId, int offerId) =>
      '$libraryBase/productos/$productId/aplicar-oferta/$offerId/';
  static String productRemoveOffer(int productId) =>
      '$libraryBase/productos/$productId/quitar-oferta/';

  /// Offer management endpoints
  static String offerProducts(int offerId) =>
      '$libraryBase/ofertas/$offerId/productos/';
  static String offerAddProducts(int offerId) =>
      '$libraryBase/ofertas/$offerId/agregar-productos/';
  static String offerRemoveProducts(int offerId) =>
      '$libraryBase/ofertas/$offerId/quitar-productos/';

  /// Machine Learning endpoints
  static const String mlCombinations = '$libraryBase/pedidos/combinaciones-ml/';
  static const String mlCombinationsDownload =
      '$libraryBase/pedidos/descargar-ml-csv/';

  /// Authentication endpoints
  static const String login = '$libraryBase/login/';
  static const String register = '$libraryBase/usuarios/crear-cliente/';
  static const String users = '$libraryBase/usuarios/';
  static const String roles = '$libraryBase/roles/';
  static const String permissions = '$libraryBase/permisos/';

  /// Search and filter helpers
  static String productsWithCategory(String categoryName) =>
      '$products?categoria=${Uri.encodeComponent(categoryName)}';
  static String productsWithAuthor(String authorName) =>
      '$products?autor=${Uri.encodeComponent(authorName)}';
  static String productsWithGenre(String genreName) =>
      '$products?genero=${Uri.encodeComponent(genreName)}';
  static String productsWithPublisher(String publisherName) =>
      '$products?editorial=${Uri.encodeComponent(publisherName)}';

  /// Utility methods for building complex queries
  static String buildProductSearchUrl({
    String? search,
    String? category,
    String? author,
    String? genre,
    String? publisher,
    bool? onSale,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) {
    final queryParams = <String>[];

    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (category != null && category.isNotEmpty) {
      queryParams.add('categoria=${Uri.encodeComponent(category)}');
    }
    if (author != null && author.isNotEmpty) {
      queryParams.add('autor=${Uri.encodeComponent(author)}');
    }
    if (genre != null && genre.isNotEmpty) {
      queryParams.add('genero=${Uri.encodeComponent(genre)}');
    }
    if (publisher != null && publisher.isNotEmpty) {
      queryParams.add('editorial=${Uri.encodeComponent(publisher)}');
    }
    if (onSale == true) {
      queryParams.add('en_oferta=true');
    }
    if (minPrice != null) {
      queryParams.add('precio_min=$minPrice');
    }
    if (maxPrice != null) {
      queryParams.add('precio_max=$maxPrice');
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams.add('ordenar_por=${Uri.encodeComponent(sortBy)}');
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams.add('orden=${Uri.encodeComponent(sortOrder)}');
    }

    if (queryParams.isEmpty) {
      return products;
    }

    return '$products?${queryParams.join('&')}';
  }

  /// Method to build offer filter URLs
  static String buildOfferSearchUrl({
    bool? active,
    bool? upcoming,
    bool? expired,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final queryParams = <String>[];

    if (active == true) {
      return activeOffers;
    }
    if (upcoming == true) {
      return upcomingOffers;
    }
    if (expired == true) {
      return expiredOffers;
    }

    if (startDate != null) {
      queryParams.add('fecha_inicio=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('fecha_fin=${endDate.toIso8601String()}');
    }

    if (queryParams.isEmpty) {
      return offers;
    }

    return '$offers?${queryParams.join('&')}';
  }

  /// Helper method to get full URL
  static String getFullUrl(String endpoint, {String? baseUrl}) {
    // This would typically use the base URL from environment config
    // For now, it's just the endpoint since DioConfig handles the base URL
    return endpoint;
  }

  /// Validation methods
  static bool isValidEndpoint(String endpoint) {
    return endpoint.startsWith(libraryBase) &&
        endpoint.length > libraryBase.length;
  }

  /// Debug method to list all available endpoints
  static Map<String, dynamic> getAllEndpoints() {
    return {
      'authentication': {
        'login': login,
        'register': register,
        'users': users,
        'roles': roles,
        'permissions': permissions,
      },
      'products': {
        'all': products,
        'on_sale': productsOnSale,
        'categories': categories,
        'authors': authors,
        'genres': genres,
        'publishers': publishers,
      },
      'offers': {
        'all': offers,
        'active': activeOffers,
        'upcoming': upcomingOffers,
        'expired': expiredOffers,
      },
      'cart': {
        'active': cart,
        'details': cartDetail,
      },
      'orders': {
        'all': orders,
        'details': orderDetails,
        'my_orders': myOrders,
      },
      'machine_learning': {
        'combinations': mlCombinations,
        'download': mlCombinationsDownload,
      },
    };
  }
}
