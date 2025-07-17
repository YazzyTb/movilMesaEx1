import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/pages/pages.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/providers/theme_provider.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/services/library_service.dart';
import 'package:exam1_software_movil/src/services/category_service.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/models/category_model.dart';
import 'mock_shared_preferences.dart';
import 'mock_cart_service.mocks.dart';

// Solución: usar clases que extiendan de ChangeNotifier para los mocks
class MockLibraryService extends ChangeNotifier implements LibraryService {
  @override
  List<Book> get books => [];

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String get errorMessage => '';

  @override
  Future<void> loadBooks() async {
    // No hacer nada en el mock
  }

  @override
  Future<void> refreshBooks() async {
    // No hacer nada en el mock
  }
}

class MockCategoryService extends ChangeNotifier implements CategoryService {
  @override
  List<Category> get categories => [];

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String get errorMessage => '';

  @override
  Future<void> loadCategories() async {
    // No hacer nada en el mock
  }

  @override
  Future<void> refreshCategories() async {
    // No hacer nada en el mock
  }
}

void main() {
  late MockCartService mockCartService;
  late MockLibraryService mockLibraryService;
  late MockCategoryService mockCategoryService;

  setUpAll(() async {
    // Configurar SharedPreferences mock
    await setUpSharedPreferencesForTests();

    // Inicializar UserPreferences
    await UserPreferences().initPrefs();
  });

  setUp(() {
    mockCartService = MockCartService();
    mockLibraryService = MockLibraryService();
    mockCategoryService = MockCategoryService();
  });

  testWidgets('Routes should be correctly registered',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) =>
                ShoppingCartProvider(cartService: mockCartService),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ThemeProvider(
              onThemeChanged: (mode) {},
            ),
          ),
          // Usar ChangeNotifierProvider en lugar de Provider
          ChangeNotifierProvider<LibraryService>(
            create: (_) => mockLibraryService,
          ),
          ChangeNotifierProvider<CategoryService>(
            create: (_) => mockCategoryService,
          ),
        ],
        child: MaterialApp(
          routes: Routes.getRoutes(),
          // Agregar una ruta inicial
          home: const LoginPage(),
        ),
      ),
    );

    // Verify the routes are registered correctly
    final routes = Routes.getRoutes();
    expect(routes.containsKey(Routes.HOME), true,
        reason: 'HOME route should be registered');
    expect(routes.containsKey(Routes.LOGIN), true,
        reason: 'LOGIN route should be registered');
    expect(routes.containsKey(Routes.REGISTER), true,
        reason: 'REGISTER route should be registered');
  });

  testWidgets('Navigation to HOME route should work',
      (WidgetTester tester) async {
    // Create a key to identify the navigator
    final navigatorKey = GlobalKey<NavigatorState>();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) =>
                ShoppingCartProvider(cartService: mockCartService),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ThemeProvider(
              onThemeChanged: (mode) {},
            ),
          ),
          // Usar ChangeNotifierProvider en lugar de Provider
          ChangeNotifierProvider<LibraryService>(
            create: (_) => mockLibraryService,
          ),
          ChangeNotifierProvider<CategoryService>(
            create: (_) => mockCategoryService,
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          routes: Routes.getRoutes(),
          initialRoute: Routes.LOGIN,
        ),
      ),
    );

    // Navigate to HOME route
    navigatorKey.currentState?.pushNamed(Routes.HOME);
    await tester.pumpAndSettle();

    // Verify that HomePage widget is shown
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets(
      'Routes.HOME constant should match string literals used in navigation',
      (WidgetTester tester) async {
    // Test that the value of Routes.HOME matches the string literals used in navigation
    expect(Routes.HOME, equals('home'));
  });
}
