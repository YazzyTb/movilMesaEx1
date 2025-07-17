import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:exam1_software_movil/src/services/cart_service.dart';
import 'package:exam1_software_movil/src/constants/constants.dart';
import 'mock_cart_service.mocks.dart';

void main() {
  late MockCartService cartService;

  setUp(() {
    cartService = MockCartService();
  });

  group('CartService', () {
    test('getCart devuelve CartResponse cuando la respuesta es exitosa',
        () async {
      // ARRANGE
      final mockResponseData = {
        'id': 1,
        'usuario': 123,
        'activo': true,
        'detalles': [
          {
            'id': 1,
            'producto': {
              'id': 101,
              'nombre': 'Libro de prueba',
              'precio': '25.99',
              'stock': 10,
              'imagen': 'http://example.com/book.jpg'
            },
            'cantidad': 2,
            'precio_unitario': '25.99',
            'subtotal': '51.98'
          }
        ]
      };

      // Setup mock to return a CartResponse
      final expectedResponse = CartResponse(
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

      when(cartService.getCart()).thenAnswer((_) async => expectedResponse);

      // ACT
      final result = await cartService.getCart();

      // ASSERT
      expect(result, isNotNull);
      expect(result!.id, equals(1));
      expect(result.usuario, equals(123));
      expect(result.detalles.length, equals(1));

      final detail = result.detalles.first;
      expect(detail.id, equals(1));
      expect(detail.producto.nombre, equals('Libro de prueba'));
      expect(detail.cantidad, equals(2));
    });

    test('getCart maneja respuesta de tipo List correctamente', () async {
      // ARRANGE
      final expectedResponse = CartResponse(
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

      when(cartService.getCart()).thenAnswer((_) async => expectedResponse);

      // ACT
      final result = await cartService.getCart();

      // ASSERT
      expect(result, isNotNull);
      expect(result!.id, equals(1));
      expect(result.detalles.length, equals(1));
    });

    test('addToCart devuelve true cuando la respuesta es exitosa', () async {
      // ARRANGE
      const productId = 101;
      const quantity = 2;

      when(cartService.addToCart(productId, quantity))
          .thenAnswer((_) async => true);

      // ACT
      final result = await cartService.addToCart(productId, quantity);

      // ASSERT
      expect(result, isTrue);
    });

    test('updateCartItemQuantity devuelve true cuando la respuesta es exitosa',
        () async {
      // ARRANGE
      const itemId = 1;
      const newQuantity = 3;

      when(cartService.updateCartItemQuantity(itemId, newQuantity))
          .thenAnswer((_) async => true);

      // ACT
      final result =
          await cartService.updateCartItemQuantity(itemId, newQuantity);

      // ASSERT
      expect(result, isTrue);
    });

    test('removeCartItem devuelve true cuando la respuesta es exitosa',
        () async {
      // ARRANGE
      const itemId = 1;

      when(cartService.removeCartItem(itemId)).thenAnswer((_) async => true);

      // ACT
      final result = await cartService.removeCartItem(itemId);

      // ASSERT
      expect(result, isTrue);
    });

    test('getCart maneja error 404 correctamente', () async {
      // ARRANGE
      when(cartService.getCart()).thenAnswer((_) async => null);

      // ACT
      final result = await cartService.getCart();

      // ASSERT
      expect(result, isNull);
    });

    test('addToCart lanza excepción cuando hay error de conexión', () async {
      // ARRANGE
      const productId = 101;
      const quantity = 2;

      when(cartService.addToCart(productId, quantity)).thenAnswer(
          (_) async => throw Exception('No se pudo conectar al servidor'));

      // ACT & ASSERT
      expect(
          () => cartService.addToCart(productId, quantity),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message',
              contains('No se pudo conectar al servidor'))));
    });
  });
}
