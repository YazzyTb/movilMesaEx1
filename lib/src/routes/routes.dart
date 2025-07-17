import 'package:flutter/material.dart';

import 'package:exam1_software_movil/src/pages/pages.dart';
import 'package:exam1_software_movil/src/share_preferens/user_preferences.dart';
import 'package:exam1_software_movil/src/pages/book_details_page.dart';
import 'package:exam1_software_movil/src/pages/pay_page.dart';
import 'package:exam1_software_movil/src/pages/cart_page.dart';
import 'package:exam1_software_movil/src/pages/order_history_page.dart';
import 'package:exam1_software_movil/src/pages/books_page.dart';

class Routes {
  static const String HOME = 'home';
  static const String LOGIN = 'login';
  static const String REGISTER = 'register';
  static const String BOOK_DETAILS = 'book-details';
  static const String CART = 'cart';
  static const String PAYMENT = 'payment';
  static const String ORDER_HISTORY = 'order-history';
  static const String BOOKS = 'books';

  static Map<String, WidgetBuilder> getRoutes() {
    final prefs = UserPreferences();

    return <String, WidgetBuilder>{
      LOGIN: (BuildContext context) =>
          prefs.clientId == 0 || prefs.token == '' ? LoginPage() : HomePage(),
      HOME: (BuildContext context) => HomePage(),
      REGISTER: (BuildContext context) => RegisterPage(),
      BOOK_DETAILS: (BuildContext context) => const BookDetailsPage(),
      CART: (BuildContext context) => const CartPage(),
      PAYMENT: (BuildContext context) => const PayPage(),
      ORDER_HISTORY: (BuildContext context) => const OrderHistoryPage(),
      BOOKS: (BuildContext context) => const BooksPage(),
    };
  }
}
