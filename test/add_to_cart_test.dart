import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/services/cart_service.dart';
import 'package:exam1_software_movil/src/widgets/quantity_selector_dialog.dart';
import 'mock_cart_service.mocks.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'mock_shared_preferences.dart';

void main() {
  late MockCartService mockCartService;
  late ShoppingCartProvider cartProvider;

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

  group('Añadir al Carrito', () {
    testWidgets('QuantitySelectorDialog añade el producto al carrito',
        (WidgetTester tester) async {
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

      // Configuramos nuestro mock
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

      // Creamos un function counter para verificar que se llamó la función onAddToCart
      int addToCartCalls = 0;

      // Construimos nuestro widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShoppingCartProvider>.value(
            value: cartProvider,
            child: Scaffold(
              body: QuantitySelectorDialog(
                book: testBook,
                onAddToCart: (quantity) {
                  addToCartCalls++;
                  cartProvider.addItemToCart(testBook, quantity);
                },
              ),
            ),
          ),
        ),
      );

      // Esperamos a que el diálogo se muestre completamente
      await tester.pumpAndSettle();

      // Verificamos que vemos los elementos esperados
      expect(find.text('Añadir al carrito'), findsOneWidget);
      expect(find.text('Libro de prueba'), findsOneWidget);
      expect(find.text('\$25.99'), findsOneWidget);
      expect(find.text('Stock: 10'), findsOneWidget);

      // ACT - Aumentamos la cantidad a 2
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Verificamos que la cantidad cambió
      expect(find.text('2'), findsOneWidget);

      // Pulsamos el botón de añadir
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(addToCartCalls, 1);
      verify(mockCartService.addToCart(101, 2)).called(1);
    });

    test('ShoppingCartProvider.addItemToCart añade correctamente el producto',
        () async {
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

      when(mockCartService.addToCart(101, 1)).thenAnswer((_) async => true);

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
            cantidad: 1,
            precioUnitario: '25.99',
            subtotal: '25.99',
          ),
        ],
      );
      when(mockCartService.getCart()).thenAnswer((_) async => mockCartResponse);

      // Inicialmente asumimos que el carrito está vacío
      expect(cartProvider.items.length, 0);

      // ACT
      final result = await cartProvider.addItemToCart(testBook, 1);

      // ASSERT
      expect(result, isTrue);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[0].book.id, 101);
      expect(cartProvider.items[0].quantity, 1);
      expect(cartProvider.totalAmount, closeTo(25.99, 0.01));
    });

    test('ShoppingCartProvider.addItemToCart maneja errores correctamente',
        () async {
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

      // Simulamos un error en la API
      when(mockCartService.addToCart(101, 1))
          .thenAnswer((_) async => throw Exception('Error de conexión'));

      // ACT
      final result = await cartProvider.addItemToCart(testBook, 1);

      // ASSERT
      expect(result, isFalse);
      expect(cartProvider.errorMessage, contains('Error de conexión'));
      expect(cartProvider.items.length, 0);
    });
  });
}
