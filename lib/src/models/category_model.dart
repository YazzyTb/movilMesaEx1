import 'dart:convert';

class Category {
  final int id;
  final String nombre;
  final bool isActive;

  Category({
    required this.id,
    required this.nombre,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        nombre: json["nombre"],
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "is_active": isActive,
      };

  @override
  String toString() {
    return nombre;
  }
}

// Helper to convert a list of categories from JSON
List<Category> categoriesFromJson(String str) {
  final List<dynamic> jsonList = json.decode(str);
  return jsonList.map((x) => Category.fromJson(x)).toList();
}
