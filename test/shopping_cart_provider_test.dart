import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/services/cart_service.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'mock_cart_service.mocks.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'mock_shared_preferences.dart';

void main() {
  late ShoppingCartProvider cartProvider;
  late MockCartService mockCartService;

  setUpAll(() async {
    // Configurar SharedPreferences mock
    await setUpSharedPreferencesForTests();

    // Inicializar UserPreferences
    await UserPreferences().initPrefs();
  });

  setUp(() {
    mockCartService = MockCartService();
    cartProvider = ShoppingCartProvider(cartService: mockCartService);
  });

  group('ShoppingCartProvider', () {
    test('loadCart actualiza la lista de items cuando la carga es exitosa',
        () async {
      // ARRANGE
      final mockCartResponse = CartResponse(
        id: 1,
        usuario: 123,
        activo: true,
        detalles: [
          CartDetail(
            id: 1,
            producto: BookCartInfo(
              id: 101,
              nombre: 'Libro de prueba',
              precio: '25.99',
              stock: 10,
              imagen: 'http://example.com/book.jpg',
            ),
            cantidad: 2,
            precioUnitario: '25.99',
            subtotal: '51.98',
          ),
        ],
      );

      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);

      // ACT
      await cartProvider.loadCart();

      // ASSERT
      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.items[0].book.nombre, equals('Libro de prueba'));
      expect(cartProvider.items[0].quantity, equals(2));
      expect(cartProvider.isLoading, isFalse);
      expect(cartProvider.errorMessage, isNull);
    });

    test('loadCart establece items vacíos cuando el carrito está vacío',
        () async {
      // ARRANGE
      when(mockCartService.getCart()).thenAnswer((_) async => null);

      // ACT
      await cartProvider.loadCart();

      // ASSERT
      expect(cartProvider.items.length, equals(0));
      expect(cartProvider.isLoading, isFalse);
      expect(cartProvider.errorMessage, isNull);
    });

    test('loadCart establece errorMessage cuando ocurre un error', () async {
      // ARRANGE
      when(mockCartService.getCart())
          .thenAnswer((_) async => throw Exception('Error de prueba'));

      // ACT
      await cartProvider.loadCart();

      // ASSERT
      expect(cartProvider.items.length, equals(0));
      expect(cartProvider.isLoading, isFalse);
      expect(cartProvider.errorMessage, contains('Error de prueba'));
    });

    test('addItemToCart llama al servicio y recarga el carrito', () async {
      // ARRANGE
      final testBook = Book(
        id: 101,
        nombre: 'Libro de prueba',
        descripcion: 'Descripción de prueba',
        stock: 10,
        imagen: 'http://example.com/book.jpg',
        precio: '25.99',
        isActive: true,
      );

      when(mockCartService.addToCart(101, 2)).thenAnswer((_) async => true);

      // Simulamos que loadCart también tiene éxito
      final mockCartResponse = CartResponse(
        id: 1,
        usuario: 123,
        activo: true,
        detalles: [
          CartDetail(
            id: 1,
            producto: BookCartInfo(
              id: 101,
              nombre: 'Libro de prueba',
              precio: '25.99',
              stock: 10,
              imagen: 'http://example.com/book.jpg',
            ),
            cantidad: 2,
            precioUnitario: '25.99',
            subtotal: '51.98',
          ),
        ],
      );
      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);

      // ACT
      final result = await cartProvider.addItemToCart(testBook, 2);

      // ASSERT
      verify(mockCartService.addToCart(101, 2)).called(1);
      verify(mockCartService.getCart()).called(1);
      expect(result, isTrue);
      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.isLoading, isFalse);
    });

    test('updateCartItemQuantity llama al servicio y recarga el carrito',
        () async {
      // ARRANGE
      when(mockCartService.updateCartItemQuantity(1, 3))
          .thenAnswer((_) async => true);

      // Simulamos que loadCart también tiene éxito
      final mockCartResponse = CartResponse(
        id: 1,
        usuario: 123,
        activo: true,
        detalles: [
          CartDetail(
            id: 1,
            producto: BookCartInfo(
              id: 101,
              nombre: 'Libro de prueba',
              precio: '25.99',
              stock: 10,
              imagen: 'http://example.com/book.jpg',
            ),
            cantidad: 3, // La cantidad actualizada
            precioUnitario: '25.99',
            subtotal: '77.97',
          ),
        ],
      );
      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);

      // ACT
      final result = await cartProvider.updateCartItemQuantity(1, 3);

      // ASSERT
      verify(mockCartService.updateCartItemQuantity(1, 3)).called(1);
      verify(mockCartService.getCart()).called(1);
      expect(result, isTrue);
      expect(cartProvider.items.length, equals(1));
      expect(cartProvider.items[0].quantity, equals(3));
      expect(cartProvider.isLoading, isFalse);
    });

    test('removeCartItem llama al servicio y recarga el carrito', () async {
      // ARRANGE
      when(mockCartService.removeCartItem(1)).thenAnswer((_) async => true);

      // Simulamos que loadCart devuelve un carrito vacío después de eliminar
      when(mockCartService.getCart()).thenAnswer((_) async => CartResponse(
            id: 1,
            usuario: 123,
            activo: true,
            detalles: [], // Carrito vacío
          ));

      // ACT
      final result = await cartProvider.removeCartItem(1);

      // ASSERT
      verify(mockCartService.removeCartItem(1)).called(1);
      verify(mockCartService.getCart()).called(1);
      expect(result, isTrue);
      expect(cartProvider.items.length, equals(0));
      expect(cartProvider.isLoading, isFalse);
    });

    test('clearCart vacía la lista de items', () async {
      // ARRANGE - Primero cargamos algunos items
      final mockCartResponse = CartResponse(
        id: 1,
        usuario: 123,
        activo: true,
        detalles: [
          CartDetail(
            id: 1,
            producto: BookCartInfo(
              id: 101,
              nombre: 'Libro de prueba',
              precio: '25.99',
              stock: 10,
              imagen: 'http://example.com/book.jpg',
            ),
            cantidad: 2,
            precioUnitario: '25.99',
            subtotal: '51.98',
          ),
        ],
      );
      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);
      await cartProvider.loadCart();
      expect(cartProvider.items.length, equals(1)); // Verificar que hay items

      // ACT
      await cartProvider.clearCart();

      // ASSERT
      expect(cartProvider.items.length, equals(0));
    });

    test('totalAmount calcula correctamente el total', () async {
      // ARRANGE - Cargamos algunos items con subtotales diferentes
      final mockCartResponse = CartResponse(
        id: 1,
        usuario: 123,
        activo: true,
        detalles: [
          CartDetail(
            id: 1,
            producto: BookCartInfo(
              id: 101,
              nombre: 'Libro 1',
              precio: '25.99',
              stock: 10,
              imagen: 'http://example.com/book1.jpg',
            ),
            cantidad: 2,
            precioUnitario: '25.99',
            subtotal: '51.98',
          ),
          CartDetail(
            id: 2,
            producto: BookCartInfo(
              id: 102,
              nombre: 'Libro 2',
              precio: '15.50',
              stock: 5,
              imagen: 'http://example.com/book2.jpg',
            ),
            cantidad: 1,
            precioUnitario: '15.50',
            subtotal: '15.50',
          ),
        ],
      );
      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);
      await cartProvider.loadCart();

      // ACT
      final total = cartProvider.totalAmount;

      // ASSERT - 51.98 + 15.50 = 67.48
      expect(total, closeTo(67.48, 0.01));
    });
  });
}
