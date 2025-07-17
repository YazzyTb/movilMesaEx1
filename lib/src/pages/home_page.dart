import 'package:exam1_software_movil/src/db/db.dart';
import 'package:exam1_software_movil/src/providers/shopping_cart_provider.dart';
import 'package:exam1_software_movil/src/services/library_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:exam1_software_movil/src/pages/pages.dart';
import 'package:exam1_software_movil/src/pages/cart_page.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/routes/routes.dart';
import 'package:exam1_software_movil/src/widgets/custom_gradient_background.dart';
import 'package:exam1_software_movil/src/providers/providers.dart';
import 'package:provider/provider.dart';

//"https://cdn.pixabay.com/photo/2017/03/27/12/18/fields-2178329_1280.jpg"

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final prefs = UserPreferences();

  Future<void> _checkIfThereIsNotification() async {
    bool renderAgain = false;
    try {
      var dataBaseLocal = DBSQLiteLocal();
      await dataBaseLocal.openDataBaseLocal();
      bool isEmptyTable = await dataBaseLocal.isTheTableEmpty('eventclient');
      print('DATA BASE HOME $isEmptyTable');

      if (!isEmptyTable) {
        if (prefs.selectedPage != 1) {
          prefs.selectedPage = 1;
          setState(() {});
        } else {
          renderAgain = true;
        }
      }

      await dataBaseLocal.closeDataBase();
    } catch (e) {
      // print(e);
    } finally {
      if (renderAgain) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.HOME, (route) => false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set default to books page (index 1)
    if (prefs.selectedPage == 0) {
      prefs.selectedPage = 1;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfThereIsNotification();
    }
  }

  final List<Widget> tabBarViews = [
    // Cart
    const CartPage(),

    // Books
    const BooksPage(),

    // Profile
    const MyPhotosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final cartProvider = Provider.of<ShoppingCartProvider>(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => LibraryService(),
        ),
      ],
      child: Scaffold(
        body: CustomGradientBackground(
          isDark: isDark,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: tabBarViews[prefs.selectedPage],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: GNav(
                  selectedIndex: prefs.selectedPage,
                  onTabChange: (index) {
                    setState(() => prefs.selectedPage = index);
                  },
                  gap: 8,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  activeColor: colorScheme.primary,
                  tabBackgroundColor: colorScheme.primary.withOpacity(0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  tabBorderRadius: 16,
                  iconSize: 24,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  tabs: [
                    GButton(
                      icon: CupertinoIcons.cart_fill,
                      text: 'Carrito',
                      iconSize: 22,
                      leading: cartProvider.itemCount > 0
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(CupertinoIcons.cart_fill),
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cartProvider.itemCount}',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                    const GButton(
                      icon: CupertinoIcons.book_fill,
                      text: 'Libros',
                      iconSize: 22,
                    ),
                    const GButton(
                      icon: CupertinoIcons.person_fill,
                      text: 'Perfil',
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
