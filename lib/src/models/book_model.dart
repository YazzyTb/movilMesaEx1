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

class Oferta {
  final int id;
  final String nombre;
  final String? descripcion;
  final String descuento; // Descuento en valor absoluto
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool isActive;
  final bool isVigente;
  final int productosCount;

  Oferta({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.isActive,
    required this.isVigente,
    required this.productosCount,
  });

  factory Oferta.fromJson(Map<String, dynamic> json) => Oferta(
        id: json["id"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        descuento: json["descuento"],
        fechaInicio: DateTime.parse(json["fecha_inicio"]),
        fechaFin: DateTime.parse(json["fecha_fin"]),
        isActive: json["is_active"] ?? true,
        isVigente: json["is_vigente"] ?? false,
        productosCount: json["productos_count"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "descuento": descuento,
        "fecha_inicio": fechaInicio.toIso8601String(),
        "fecha_fin": fechaFin.toIso8601String(),
        "is_active": isActive,
        "is_vigente": isVigente,
        "productos_count": productosCount,
      };

  // Helpers para UI
  double get descuentoNumerico => double.tryParse(descuento) ?? 0.0;

  String get fechaInicioFormateada {
    return "${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}";
  }

  String get fechaFinFormateada {
    return "${fechaFin.day}/${fechaFin.month}/${fechaFin.year}";
  }
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
  final Oferta? oferta;

  // Nuevos campos de ofertas
  final String precioConDescuento;
  final String descuentoAplicado;
  final bool tieneOfertaVigente;

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
    this.oferta,
    required this.precioConDescuento,
    required this.descuentoAplicado,
    required this.tieneOfertaVigente,
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
        oferta: json["oferta"] != null ? Oferta.fromJson(json["oferta"]) : null,
        precioConDescuento: json["precio_con_descuento"] ?? json["precio"],
        descuentoAplicado: json["descuento_aplicado"] ?? "0.00",
        tieneOfertaVigente: json["tiene_oferta_vigente"] ?? false,
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
        "oferta": oferta?.toJson(),
        "precio_con_descuento": precioConDescuento,
        "descuento_aplicado": descuentoAplicado,
        "tiene_oferta_vigente": tieneOfertaVigente,
      };

  // Helpers para UI
  double get precioNumerico => double.tryParse(precio) ?? 0.0;
  double get precioConDescuentoNumerico =>
      double.tryParse(precioConDescuento) ?? 0.0;
  double get descuentoNumerico => double.tryParse(descuentoAplicado) ?? 0.0;

  bool get estaEnOferta => tieneOfertaVigente && descuentoNumerico > 0;

  double get porcentajeDescuento {
    if (!estaEnOferta || precioNumerico == 0) return 0.0;
    return (descuentoNumerico / precioNumerico) * 100;
  }

  String get precioMostrar => estaEnOferta ? precioConDescuento : precio;

  // Para mostrar el ahorro total
  String get ahorroTotal {
    if (!estaEnOferta) return "0.00";
    return descuentoAplicado;
  }
}
