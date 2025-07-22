import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';

class LibraryService extends ChangeNotifier {
  final List<Book> _books = [];
  final List<Book> _booksOnSale = [];
  final List<Oferta> _activeOffers = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Filtros y búsqueda
  String _currentSearchQuery = '';
  String? _currentCategoryFilter;
  String? _currentAuthorFilter;
  String? _currentGenreFilter;
  bool _showOnlyOnSale = false;

  // Cache para mejorar rendimiento
  DateTime? _lastBookLoad;
  DateTime? _lastOfferLoad;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Getters
  List<Book> get books => _books;
  List<Book> get booksOnSale => _booksOnSale;
  List<Oferta> get activeOffers => _activeOffers;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Getters para filtros
  String get currentSearchQuery => _currentSearchQuery;
  String? get currentCategoryFilter => _currentCategoryFilter;
  String? get currentAuthorFilter => _currentAuthorFilter;
  String? get currentGenreFilter => _currentGenreFilter;
  bool get showOnlyOnSale => _showOnlyOnSale;

  // Estadísticas
  int get totalBooks => _books.length;
  int get booksOnSaleCount => _books.where((book) => book.estaEnOferta).length;
  int get outOfStockCount => _books.where((book) => book.stock == 0).length;
  int get lowStockCount =>
      _books.where((book) => book.stock > 0 && book.stock <= 5).length;
  int get availableBooksCount => _books.where((book) => book.stock > 0).length;

  // Constructor
  LibraryService() {
    loadBooks();
    loadActiveOffers();
  }

  // Verificar si el cache es válido
  bool _isCacheValid(DateTime? lastLoad) {
    if (lastLoad == null) return false;
    return DateTime.now().difference(lastLoad) < _cacheTimeout;
  }

  // Refresh all data
  Future<void> refreshBooks() async {
    print('LibraryService: Refrescando todos los datos');
    await Future.wait([
      loadBooks(forceRefresh: true),
      loadBooksOnSale(forceRefresh: true),
      loadActiveOffers(forceRefresh: true),
    ]);
  }

  // Load books from API
  Future<void> loadBooks({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid(_lastBookLoad) && _books.isNotEmpty) {
      print('LibraryService: Usando cache para libros');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Verificar que el token está disponible
      final prefs = UserPreferences();
      print('LOADING BOOKS - Token disponible: ${prefs.token.isNotEmpty}');

      String endpoint = _buildBooksEndpoint();
      print('LOADING BOOKS - Realizando solicitud a: $endpoint');

      final response = await DioConfig.dio.get(endpoint);
      print('LOADING BOOKS - Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('LOADING BOOKS - Respuesta exitosa');
        final List<dynamic> booksJson = response.data;
        print(
            'LOADING BOOKS - Número de libros recibidos: ${booksJson.length}');

        _books.clear();
        for (var item in booksJson) {
          try {
            _books.add(Book.fromJson(item));
          } catch (e) {
            print('LOADING BOOKS - Error parseando libro: $e');
            print('LOADING BOOKS - Datos del libro problemático: $item');
          }
        }

        // Ordenar libros: primero los que tienen ofertas, luego por nombre
        _books.sort((a, b) {
          // Primero por ofertas
          if (a.estaEnOferta && !b.estaEnOferta) return -1;
          if (!a.estaEnOferta && b.estaEnOferta) return 1;

          // Luego por stock (productos disponibles primero)
          if (a.stock > 0 && b.stock == 0) return -1;
          if (a.stock == 0 && b.stock > 0) return 1;

          // Finalmente por nombre
          return a.nombre.compareTo(b.nombre);
        });

        _lastBookLoad = DateTime.now();
        print(
            'LOADING BOOKS - ${_books.length} libros cargados, ${booksOnSaleCount} con ofertas');
        notifyListeners();
      } else if (response.statusCode == 401) {
        print('LOADING BOOKS - ERROR DE AUTORIZACIÓN 401');
        _setError('Error de autorización. Por favor inicie sesión nuevamente.');
      } else {
        print('LOADING BOOKS - ERROR: StatusCode ${response.statusCode}');
        _setError('Error al cargar los productos: ${response.statusCode}');
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

  // Cargar productos en oferta específicamente
  Future<void> loadBooksOnSale({bool forceRefresh = false}) async {
    if (!forceRefresh && _booksOnSale.isNotEmpty) {
      print('LibraryService: Usando cache para productos en oferta');
      return;
    }

    try {
      print('LOADING BOOKS ON SALE - Cargando productos en oferta');
      final response = await DioConfig.dio.get(ApiEndpoints.productsOnSale);

      if (response.statusCode == 200) {
        final List<dynamic> booksJson = response.data;
        _booksOnSale.clear();

        for (var item in booksJson) {
          try {
            _booksOnSale.add(Book.fromJson(item));
          } catch (e) {
            print('LOADING BOOKS ON SALE - Error parseando libro: $e');
          }
        }

        // Ordenar por mayor descuento primero
        _booksOnSale.sort(
            (a, b) => b.porcentajeDescuento.compareTo(a.porcentajeDescuento));

        print(
            'LOADING BOOKS ON SALE - ${_booksOnSale.length} productos en oferta cargados');
        notifyListeners();
      } else {
        print('LOADING BOOKS ON SALE - Error: ${response.statusCode}');
      }
    } catch (e) {
      print('LOADING BOOKS ON SALE - Error: $e');
      // No mostrar error crítico por esto, usar productos en oferta de _books
      _booksOnSale.clear();
      _booksOnSale.addAll(_books.where((book) => book.estaEnOferta));
    }
  }

  // Cargar ofertas activas
  Future<void> loadActiveOffers({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _isCacheValid(_lastOfferLoad) &&
        _activeOffers.isNotEmpty) {
      print('LibraryService: Usando cache para ofertas activas');
      return;
    }

    try {
      print('LOADING ACTIVE OFFERS - Cargando ofertas activas');
      final response = await DioConfig.dio.get(ApiEndpoints.activeOffers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> offersJson;

        // Manejar diferentes formatos de respuesta
        if (responseData is Map && responseData.containsKey('ofertas')) {
          offersJson = responseData['ofertas'];
        } else if (responseData is List) {
          offersJson = responseData;
        } else {
          print('LOADING ACTIVE OFFERS - Formato de respuesta inesperado');
          return;
        }

        _activeOffers.clear();

        for (var item in offersJson) {
          try {
            _activeOffers.add(Oferta.fromJson(item));
          } catch (e) {
            print('LOADING ACTIVE OFFERS - Error parseando oferta: $e');
          }
        }

        // Ordenar por fecha de fin (las que expiran pronto primero)
        _activeOffers.sort((a, b) => a.fechaFin.compareTo(b.fechaFin));

        _lastOfferLoad = DateTime.now();
        print(
            'LOADING ACTIVE OFFERS - ${_activeOffers.length} ofertas activas cargadas');
        notifyListeners();
      } else {
        print('LOADING ACTIVE OFFERS - Error: ${response.statusCode}');
      }
    } catch (e) {
      print('LOADING ACTIVE OFFERS - Error: $e');
      // No mostrar error crítico por esto
    }
  }

  // Buscar productos
  Future<void> searchBooks(String query) async {
    if (_currentSearchQuery == query) return;

    _currentSearchQuery = query;
    print('LibraryService: Buscando productos con query: "$query"');
    await loadBooks(forceRefresh: true);
  }

  // Filtrar por categoría
  Future<void> filterByCategory(String? categoryName) async {
    if (_currentCategoryFilter == categoryName) return;

    _currentCategoryFilter = categoryName;
    print('LibraryService: Filtrando por categoría: $categoryName');
    await loadBooks(forceRefresh: true);
  }

  // Filtrar por autor
  Future<void> filterByAuthor(String? authorName) async {
    if (_currentAuthorFilter == authorName) return;

    _currentAuthorFilter = authorName;
    print('LibraryService: Filtrando por autor: $authorName');
    await loadBooks(forceRefresh: true);
  }

  // Filtrar por género
  Future<void> filterByGenre(String? genreName) async {
    if (_currentGenreFilter == genreName) return;

    _currentGenreFilter = genreName;
    print('LibraryService: Filtrando por género: $genreName');
    await loadBooks(forceRefresh: true);
  }

  // Mostrar solo productos en oferta
  Future<void> toggleOnSaleFilter() async {
    _showOnlyOnSale = !_showOnlyOnSale;
    print('LibraryService: Filtro de ofertas: $_showOnlyOnSale');

    if (_showOnlyOnSale && _booksOnSale.isEmpty) {
      await loadBooksOnSale(forceRefresh: true);
    } else {
      await loadBooks(forceRefresh: true);
    }
  }

  // Limpiar todos los filtros
  Future<void> clearAllFilters() async {
    print('LibraryService: Limpiando todos los filtros');
    _currentSearchQuery = '';
    _currentCategoryFilter = null;
    _currentAuthorFilter = null;
    _currentGenreFilter = null;
    _showOnlyOnSale = false;
    await loadBooks(forceRefresh: true);
  }

  // Obtener libros filtrados localmente
  List<Book> getFilteredBooks({
    String? searchQuery,
    String? category,
    String? author,
    String? genre,
    bool? onSale,
    int? minStock,
    double? minPrice,
    double? maxPrice,
    String? sortBy, // 'name', 'price', 'discount', 'stock'
    bool sortAscending = true,
  }) {
    List<Book> filtered = List.from(_books);

    // Filtro por búsqueda
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((book) {
        return book.nombre.toLowerCase().contains(query) ||
            book.descripcion.toLowerCase().contains(query) ||
            (book.autor?.nombre.toLowerCase().contains(query) ?? false) ||
            (book.categoria?.nombre.toLowerCase().contains(query) ?? false) ||
            (book.genero?.nombre.toLowerCase().contains(query) ?? false) ||
            (book.editorial?.nombre.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtro por categoría
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.categoria?.nombre.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    // Filtro por autor
    if (author != null && author.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.autor?.nombre.toLowerCase() == author.toLowerCase();
      }).toList();
    }

    // Filtro por género
    if (genre != null && genre.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.genero?.nombre.toLowerCase() == genre.toLowerCase();
      }).toList();
    }

    // Filtro por ofertas
    if (onSale == true) {
      filtered = filtered.where((book) => book.estaEnOferta).toList();
    }

    // Filtro por stock mínimo
    if (minStock != null) {
      filtered = filtered.where((book) => book.stock >= minStock).toList();
    }

    // Filtro por rango de precios
    if (minPrice != null) {
      filtered = filtered.where((book) {
        final precio = book.estaEnOferta
            ? book.precioConDescuentoNumerico
            : book.precioNumerico;
        return precio >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((book) {
        final precio = book.estaEnOferta
            ? book.precioConDescuentoNumerico
            : book.precioNumerico;
        return precio <= maxPrice;
      }).toList();
    }

    // Ordenamiento
    if (sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;

        switch (sortBy.toLowerCase()) {
          case 'name':
            comparison = a.nombre.compareTo(b.nombre);
            break;
          case 'price':
            final priceA = a.estaEnOferta
                ? a.precioConDescuentoNumerico
                : a.precioNumerico;
            final priceB = b.estaEnOferta
                ? b.precioConDescuentoNumerico
                : b.precioNumerico;
            comparison = priceA.compareTo(priceB);
            break;
          case 'discount':
            comparison = a.porcentajeDescuento.compareTo(b.porcentajeDescuento);
            break;
          case 'stock':
            comparison = a.stock.compareTo(b.stock);
            break;
          default:
            comparison = a.nombre.compareTo(b.nombre);
        }

        return sortAscending ? comparison : -comparison;
      });
    }

    return filtered;
  }

  // Obtener productos relacionados por categoría
  List<Book> getRelatedBooksByCategory(Book book, {int limit = 5}) {
    if (book.categoria == null) return [];

    return _books
        .where((b) =>
            b.id != book.id &&
            b.categoria?.id == book.categoria!.id &&
            b.stock > 0)
        .take(limit)
        .toList();
  }

  // Obtener productos relacionados por autor
  List<Book> getRelatedBooksByAuthor(Book book, {int limit = 5}) {
    if (book.autor == null) return [];

    return _books
        .where((b) =>
            b.id != book.id && b.autor?.id == book.autor!.id && b.stock > 0)
        .take(limit)
        .toList();
  }

  // Obtener productos relacionados por género
  List<Book> getRelatedBooksByGenre(Book book, {int limit = 5}) {
    if (book.genero == null) return [];

    return _books
        .where((b) =>
            b.id != book.id && b.genero?.id == book.genero!.id && b.stock > 0)
        .take(limit)
        .toList();
  }

  // Obtener productos más vendidos (simulado basado en stock bajo)
  List<Book> getBestSellers({int limit = 10}) {
    // En una implementación real, esto vendría del backend
    // Por ahora, simulamos con productos que tienen stock medio-bajo (vendidos)
    return _books.where((book) => book.stock > 0 && book.stock < 20).toList()
      ..sort((a, b) {
        // Priorizar los que tienen ofertas
        if (a.estaEnOferta && !b.estaEnOferta) return -1;
        if (!a.estaEnOferta && b.estaEnOferta) return 1;
        // Luego por stock más bajo (más vendidos)
        return a.stock.compareTo(b.stock);
      })
      ..take(limit).toList();
  }

  // Obtener productos con stock bajo
  List<Book> getLowStockBooks({int stockThreshold = 5}) {
    return _books
        .where((book) => book.stock > 0 && book.stock <= stockThreshold)
        .toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
  }

  // Obtener productos más caros
  List<Book> getMostExpensiveBooks({int limit = 10}) {
    return _books.where((book) => book.stock > 0).toList()
      ..sort((a, b) => b.precioNumerico.compareTo(a.precioNumerico))
      ..take(limit).toList();
  }

  // Obtener productos más baratos
  List<Book> getCheapestBooks({int limit = 10}) {
    return _books.where((book) => book.stock > 0).toList()
      ..sort((a, b) => a.precioNumerico.compareTo(b.precioNumerico))
      ..take(limit).toList();
  }

  // Obtener productos con mayor descuento
  List<Book> getBiggestDiscounts({int limit = 10}) {
    return _books.where((book) => book.estaEnOferta && book.stock > 0).toList()
      ..sort((a, b) => b.porcentajeDescuento.compareTo(a.porcentajeDescuento))
      ..take(limit).toList();
  }

  // Obtener estadísticas de ofertas
  Map<String, dynamic> getOfferStatistics() {
    final booksWithOffers = _books.where((book) => book.estaEnOferta).toList();

    double totalSavings = 0;
    double totalOriginalValue = 0;
    double totalDiscountedValue = 0;
    Map<String, int> offersByName = {};
    Map<String, double> savingsByOffer = {};

    for (var book in booksWithOffers) {
      final saving = book.descuentoNumerico;
      final original = book.precioNumerico;
      final discounted = book.precioConDescuentoNumerico;

      totalSavings += saving;
      totalOriginalValue += original;
      totalDiscountedValue += discounted;

      if (book.oferta != null) {
        final offerName = book.oferta!.nombre;
        offersByName[offerName] = (offersByName[offerName] ?? 0) + 1;
        savingsByOffer[offerName] = (savingsByOffer[offerName] ?? 0) + saving;
      }
    }

    return {
      'total_books_with_offers': booksWithOffers.length,
      'total_books': _books.length,
      'percentage_with_offers': _books.isNotEmpty
          ? (booksWithOffers.length / _books.length) * 100
          : 0,
      'total_potential_savings': totalSavings,
      'total_original_value': totalOriginalValue,
      'total_discounted_value': totalDiscountedValue,
      'average_discount_percentage': totalOriginalValue > 0
          ? (totalSavings / totalOriginalValue) * 100
          : 0,
      'offers_by_name': offersByName,
      'savings_by_offer': savingsByOffer,
      'active_offers_count': _activeOffers.length,
      'out_of_stock_count': outOfStockCount,
      'low_stock_count': lowStockCount,
      'available_books_count': availableBooksCount,
    };
  }

  // Obtener libro por ID
  Book? getBookById(int id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      print('LibraryService: Libro con ID $id no encontrado');
      return null;
    }
  }

  // Verificar si un libro está en stock
  bool isBookInStock(int bookId, {int quantity = 1}) {
    final book = getBookById(bookId);
    return book != null && book.stock >= quantity;
  }

  // Obtener precio efectivo de un libro (con ofertas)
  double getEffectivePrice(int bookId) {
    final book = getBookById(bookId);
    if (book == null) return 0.0;

    return book.estaEnOferta
        ? book.precioConDescuentoNumerico
        : book.precioNumerico;
  }

  // Obtener categorías únicas de los libros cargados
  List<String> getAvailableCategories() {
    final categories = <String>{};
    for (var book in _books) {
      if (book.categoria != null) {
        categories.add(book.categoria!.nombre);
      }
    }
    return categories.toList()..sort();
  }

  // Obtener autores únicos de los libros cargados
  List<String> getAvailableAuthors() {
    final authors = <String>{};
    for (var book in _books) {
      if (book.autor != null) {
        authors.add(book.autor!.nombre);
      }
    }
    return authors.toList()..sort();
  }

  // Obtener géneros únicos de los libros cargados
  List<String> getAvailableGenres() {
    final genres = <String>{};
    for (var book in _books) {
      if (book.genero != null) {
        genres.add(book.genero!.nombre);
      }
    }
    return genres.toList()..sort();
  }

  // Construir endpoint con filtros
  String _buildBooksEndpoint() {
    return ApiEndpoints.buildProductSearchUrl(
      search: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
      category: _currentCategoryFilter,
      author: _currentAuthorFilter,
      genre: _currentGenreFilter,
      onSale: _showOnlyOnSale,
    );
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

  // Método para debug
  void printServiceStatistics() {
    print('=== LIBRARY SERVICE STATISTICS ===');
    print('Total books: $totalBooks');
    print('Books on sale: $booksOnSaleCount');
    print('Available books: $availableBooksCount');
    print('Out of stock: $outOfStockCount');
    print('Low stock: $lowStockCount');
    print('Active offers: ${_activeOffers.length}');
    print('Last book load: $_lastBookLoad');
    print('Last offer load: $_lastOfferLoad');
    print('Current filters:');
    print('  - Search: "$_currentSearchQuery"');
    print('  - Category: $_currentCategoryFilter');
    print('  - Author: $_currentAuthorFilter');
    print('  - Genre: $_currentGenreFilter');
    print('  - Show only on sale: $_showOnlyOnSale');

    final offerStats = getOfferStatistics();
    print('Offer statistics:');
    offerStats.forEach((key, value) {
      print('  - $key: $value');
    });

    print('Available categories: ${getAvailableCategories().length}');
    print('Available authors: ${getAvailableAuthors().length}');
    print('Available genres: ${getAvailableGenres().length}');
    print('===================================');
  }

  // Limpiar cache manualmente
  void clearCache() {
    print('LibraryService: Limpiando cache');
    _lastBookLoad = null;
    _lastOfferLoad = null;
  }

  @override
  void dispose() {
    print('LibraryService: Liberando recursos');
    _books.clear();
    _booksOnSale.clear();
    _activeOffers.clear();
    super.dispose();
  }
}
