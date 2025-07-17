import 'dart:convert';

class OrderDetail {
  final int? id;
  final int? pedidoId;
  final Producto producto;
  final int productoId;
  final int cantidad;
  final String precioUnitario;
  final String subtotal;

  OrderDetail({
    this.id,
    this.pedidoId,
    required this.producto,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        id: json["id"],
        pedidoId: json["pedido"],
        producto: Producto.fromJson(json["producto"]),
        productoId: json["producto_id"] ?? Producto.fromJson(json["producto"]).id,
        cantidad: json["cantidad"],
        precioUnitario: json["precio_unitario"],
        subtotal: json["subtotal"],
      );
}

class Producto {
  final int id;
  final String nombre;
  final int stock;
  final String precio;
  final String? imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.stock,
    required this.precio,
    this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json["id"],
        nombre: json["nombre"],
        stock: json["stock"],
        precio: json["precio"],
        imagen: json["imagen"],
      );
}

class Order {
  final int id;
  final int usuarioId;
  final List<OrderDetail> detalles;
  final String? descuento;
  final String total;
  final DateTime fechaPedido;
  final int? calificacion;
  final bool activo;

  Order({
    required this.id,
    required this.usuarioId,
    required this.detalles,
    this.descuento,
    required this.total,
    required this.fechaPedido,
    this.calificacion,
    required this.activo,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        usuarioId: json["usuario"],
        detalles: List<OrderDetail>.from(
            json["detalles"].map((x) => OrderDetail.fromJson(x))),
        descuento: json["descuento"],
        total: json["total"],
        fechaPedido: DateTime.parse(json["fecha_pedido"]),
        calificacion: json["calificacion"],
        activo: json["activo"],
      );

  String get formattedDate {
    return "${fechaPedido.day}/${fechaPedido.month}/${fechaPedido.year} ${fechaPedido.hour}:${fechaPedido.minute.toString().padLeft(2, '0')}";
  }
}
