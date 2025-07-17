import 'package:flutter_test/flutter_test.dart';
import 'package:exam1_software_movil/src/models/book_model.dart';
import 'package:exam1_software_movil/src/constants/api_constants.dart';

void main() {
  group('Library API Tests', () {
    test('Book model should correctly parse JSON data with new structure', () {
      final Map<String, dynamic> jsonData = {
        "id": 1,
        "nombre": "Cien Años de Soledad",
        "descripcion": "Novela de Gabriel García Márquez",
        "stock": 30,
        "imagen": "https://ejemplo.com/libro.jpg",
        "precio": "49.99",
        "categoria": {"id": 2, "nombre": "Libros", "is_active": true},
        "genero": {"id": 2, "nombre": "COMEDIA", "is_active": true},
        "autor": {"id": 1, "nombre": "edgar alan poe", "is_active": true},
        "editorial": {"id": 1, "nombre": "CASAARENA", "is_active": true},
        "is_active": true
      };

      final book = Book.fromJson(jsonData);

      // Verificar propiedades principales
      expect(book.id, 1);
      expect(book.nombre, "Cien Años de Soledad");
      expect(book.descripcion, "Novela de Gabriel García Márquez");
      expect(book.stock, 30);
      expect(book.imagen, "https://ejemplo.com/libro.jpg");
      expect(book.precio, "49.99");
      expect(book.isActive, true);

      // Verificar objetos relacionados
      expect(book.categoria?.id, 2);
      expect(book.categoria?.nombre, "Libros");
      expect(book.categoria?.isActive, true);

      expect(book.genero?.id, 2);
      expect(book.genero?.nombre, "COMEDIA");
      expect(book.genero?.isActive, true);

      expect(book.autor?.id, 1);
      expect(book.autor?.nombre, "edgar alan poe");
      expect(book.autor?.isActive, true);

      expect(book.editorial?.id, 1);
      expect(book.editorial?.nombre, "CASAARENA");
      expect(book.editorial?.isActive, true);
    });

    test('Book model should handle missing related objects', () {
      final Map<String, dynamic> jsonData = {
        "id": 1,
        "nombre": "Test Book",
        "descripcion": "Test Description",
        "stock": 10,
        "imagen": "http://example.com/image.jpg",
        "precio": "29.99",
        "is_active": true
      };

      final book = Book.fromJson(jsonData);

      expect(book.categoria, isNull);
      expect(book.genero, isNull);
      expect(book.autor, isNull);
      expect(book.editorial, isNull);
    });

    test('Book model should convert to JSON correctly with related objects',
        () {
      final book = Book(
        id: 1,
        nombre: "Test Book",
        descripcion: "Test Description",
        stock: 10,
        imagen: "http://example.com/image.jpg",
        precio: "29.99",
        isActive: true,
        categoria: Categoria(id: 1, nombre: "Ficción", isActive: true),
        genero: Genero(id: 2, nombre: "Aventura", isActive: true),
        autor: Autor(id: 3, nombre: "Test Author", isActive: true),
        editorial: Editorial(id: 4, nombre: "Test Publisher", isActive: true),
      );

      final json = book.toJson();

      expect(json['id'], 1);
      expect(json['nombre'], "Test Book");
      expect(json['descripcion'], "Test Description");
      expect(json['stock'], 10);
      expect(json['imagen'], "http://example.com/image.jpg");
      expect(json['precio'], "29.99");
      expect(json['is_active'], true);

      expect(json['categoria']['id'], 1);
      expect(json['categoria']['nombre'], "Ficción");
      expect(json['categoria']['is_active'], true);

      expect(json['genero']['id'], 2);
      expect(json['genero']['nombre'], "Aventura");
      expect(json['genero']['is_active'], true);

      expect(json['autor']['id'], 3);
      expect(json['autor']['nombre'], "Test Author");
      expect(json['autor']['is_active'], true);

      expect(json['editorial']['id'], 4);
      expect(json['editorial']['nombre'], "Test Publisher");
      expect(json['editorial']['is_active'], true);
    });

    test('ApiEndpoints should correctly define the products endpoint', () {
      expect(ApiEndpoints.products, '/Libreria/productos/');
    });
  });
}
