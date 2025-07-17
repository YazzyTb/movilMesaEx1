import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:exam1_software_movil/src/constants/constants.dart';
import 'package:exam1_software_movil/src/db/db.dart';
import 'package:exam1_software_movil/src/providers/providers.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/services/library_service.dart';
import 'package:exam1_software_movil/src/services/category_service.dart';
import 'package:exam1_software_movil/src/widgets/loading_overlay.dart';
import 'package:exam1_software_movil/src/services/speech_recognition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.load();

  // Configurar manejador de errores para ignorar errores específicos
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('mouse_tracker.dart')) {
      // Ignorar errores específicos del MouseTracker
      print('Ignorando error de MouseTracker');
    } else {
      // Manejar otros errores normalmente
      FlutterError.presentError(details);
    }
  };

  // Configuracion de stripe
  final stripeKey =
      EnvConfig.stripePublishableKey.replaceAll(RegExp(r'\s+'), '');
  Stripe.publishableKey = stripeKey;
  await Stripe.instance.applySettings();

  // Evita capturas de pantalla
  // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  // database local

  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'demo.db');

  print(path);
  // Delete the database
  // await deleteDatabase(path);

  // Open the database
  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute('DROP TABLE IF EXISTS test');
    await db.execute(
        'CREATE TABLE eventclient (id INTEGER PRIMARY KEY, clientId INTEGER, eventId INTEGER)');
    await db.execute('CREATE TABLE user (id INTEGER PRIMARY KEY, age INTEGER)');
    await db.execute(
        'CREATE TABLE student (id INTEGER, name TEXT, surname TEXT, mail TEXT)');
    print('table created');
  });

  print('tablas creadas');

  print('Databaseee: $database');
  await database.close();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  String? token = await messaging.getToken();
  print('tokeennnnn: $token');

  print('User granted permission: ${settings.authorizationStatus}');

  final prefs = UserPreferences();
  await prefs.initPrefs();
  runApp(MyApp(databasePathFuture: Future.value(path)));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.databasePathFuture});

  final Future<String> databasePathFuture;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  _init() async {
    final pushProvider = PushNotificationProvider();
    await pushProvider.initNotifications();

    pushProvider.messages.listen((argument) async {
      if (argument.isNotEmpty) {
        try {
          final Map<String, dynamic> eventClientMap =
              json.decode(argument['eventClient']);
          final dataMap = {
            'id': int.parse(eventClientMap['id']),
            'clientId': int.parse(eventClientMap['clientId']),
            'eventId': int.parse(eventClientMap['eventId'])
          };

          var dataBaseLocal = DBSQLiteLocal();
          await dataBaseLocal.openDataBaseLocal();

          await dataBaseLocal.insert('eventclient', dataMap);

          await dataBaseLocal.closeDataBase();
        } catch (e) {
          // print(e);
        }

        final prefs = UserPreferences();
        prefs.selectedPage = 1;
        pushProvider.deleteData();
        navigatorKey.currentState?.pushNamed(Routes.HOME);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ShoppingCartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryService(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            onThemeChanged: _setThemeMode,
          ),
        ),
        ChangeNotifierProxyProvider<ShoppingCartProvider,
            RecommendationProvider>(
          create: (_) => RecommendationProvider(),
          update: (_, cartProvider, previousRecommendationProvider) =>
              previousRecommendationProvider ?? RecommendationProvider(),
        ),
      ],
      child: GlobalLoadingOverlay(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'NOVA Librería',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode,
          initialRoute: Routes.LOGIN,
          routes: Routes.getRoutes(),
        ),
      ),
    );
  }
}
