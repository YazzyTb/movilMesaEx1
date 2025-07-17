import 'dart:convert';

class Categoria {
  final int id;
  final String nombre;
  final bool isActive;

  Categoria({
    required this.id,
    required this.nombre,
    required this.isActive,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json["id"],
        nombre: json["nombre"],
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "is_active": isActive,
      };
}

class Genero {
  final int id;
  final String nombre;
  final bool isActive;

  Genero({
    required this.id,
    required this.nombre,
    required this.isActive,
  });

  factory Genero.fromJson(Map<String, dynamic> json) => Genero(
        id: json["id"],
        nombre: json["nombre"],
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "is_active": isActive,
      };
}

class Autor {
  final int id;
  final String nombre;
  final bool isActive;

  Autor({
    required this.id,
    required this.nombre,
    required this.isActive,
  });

  factory Autor.fromJson(Map<String, dynamic> json) => Autor(
        id: json["id"],
        nombre: json["nombre"],
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "is_active": isActive,
      };
}

class Editorial {
  final int id;
  final String nombre;
  final bool isActive;

  Editorial({
    required this.id,
    required this.nombre,
    required this.isActive,
  });

  factory Editorial.fromJson(Map<String, dynamic> json) => Editorial(
        id: json["id"],
        nombre: json["nombre"],
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "is_active": isActive,
      };
}

class Book {
  final int id;
  final String nombre;
  final String descripcion;
  final int stock;
  final String imagen;
  final String precio;
  final bool isActive;
  final Categoria? categoria;
  final Genero? genero;
  final Autor? autor;
  final Editorial? editorial;

  Book({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.stock,
    required this.imagen,
    required this.precio,
    required this.isActive,
    this.categoria,
    this.genero,
    this.autor,
    this.editorial,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        stock: json["stock"],
        imagen: json["imagen"],
        precio: json["precio"],
        isActive: json["is_active"] ?? true,
        categoria: json["categoria"] != null
            ? Categoria.fromJson(json["categoria"])
            : null,
        genero: json["genero"] != null ? Genero.fromJson(json["genero"]) : null,
        autor: json["autor"] != null ? Autor.fromJson(json["autor"]) : null,
        editorial: json["editorial"] != null
            ? Editorial.fromJson(json["editorial"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "stock": stock,
        "imagen": imagen,
        "precio": precio,
        "is_active": isActive,
        "categoria": categoria?.toJson(),
        "genero": genero?.toJson(),
        "autor": autor?.toJson(),
        "editorial": editorial?.toJson(),
      };
}
