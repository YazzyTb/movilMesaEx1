import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/widgets/book_card.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'mock_shared_preferences.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';

void main() {
  final testBook = Book(
    id: 1,
    nombre: 'Test Book Title',
    descripcion: 'Test book description',
    precio: '25.99',
    stock: 10,
    imagen: 'https://example.com/image.jpg',
    isActive: true,
    categoria: Categoria(id: 1, nombre: 'Ficción', isActive: true),
    genero: Genero(id: 2, nombre: 'Aventura', isActive: true),
    autor: Autor(id: 3, nombre: 'Test Author', isActive: true),
    editorial: Editorial(id: 4, nombre: 'Test Publisher', isActive: true),
  );

  final outOfStockBook = Book(
    id: 2,
    nombre: 'Out of Stock Book',
    descripcion: 'This book is currently unavailable',
    precio: '19.99',
    stock: 0,
    imagen: 'https://example.com/image2.jpg',
    isActive: true,
  );

  Widget createBookCardWithProvider(Book book) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ChangeNotifierProvider(
              create: (_) => ShoppingCartProvider(),
              child: BookCard(book: book),
            ),
          ),
        ),
      ),
    );
  }

  setUpAll(() async {
    // Configurar SharedPreferences mock
    await setUpSharedPreferencesForTests();

    // Inicializar UserPreferences
    await UserPreferences().initPrefs();
  });

  testWidgets('BookCard displays book information correctly',
      (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createBookCardWithProvider(testBook));
    await tester.pumpAndSettle(); // Wait for all animations to complete

    // Verify book information is displayed
    expect(find.text('Test Book Title'), findsOneWidget);
    expect(find.text('Test book description'), findsOneWidget);
    expect(find.text('\$25.99'), findsOneWidget);
    expect(find.text('Stock: 10'), findsOneWidget);

    // Verificar que el icono del carrito está presente en lugar del texto
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets('BookCard displays out-of-stock book information',
      (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(createBookCardWithProvider(outOfStockBook));
    await tester.pumpAndSettle(); // Wait for all animations to complete

    // Verify book information is displayed
    expect(find.text('Out of Stock Book'), findsOneWidget);
    expect(find.text('This book is currently unavailable'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);
    expect(find.text('Stock: 0'), findsOneWidget);

    // Verificar que el icono del carrito está presente en lugar del texto
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });

  testWidgets('BookCard handles long text with ellipsis',
      (WidgetTester tester) async {
    // Set a larger surface size to avoid overflow
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final bookWithLongText = Book(
      id: 3,
      nombre:
          'This is a very long book title that should be truncated with ellipsis because it exceeds the maximum number of lines allowed',
      descripcion:
          'This is a very long description that should be truncated with ellipsis because it exceeds the maximum number of lines allowed. It contains a lot of details about the book that might not fit in the available space.',
      precio: '15.99',
      stock: 5,
      imagen: 'https://example.com/image3.jpg',
      isActive: true,
    );

    await tester.pumpWidget(createBookCardWithProvider(bookWithLongText));
    await tester.pumpAndSettle(); // Wait for all animations to complete

    // Verify both title and description texts exist
    expect(
        find.textContaining('This is a very long book title'), findsOneWidget);
    expect(
        find.textContaining('This is a very long description'), findsOneWidget);
  });

  // Clean up after tests
  tearDown(() {
    // Reset the screen size after tests
    TestWidgetsFlutterBinding.ensureInitialized()
        .window
        .clearPhysicalSizeTestValue();
  });
}
