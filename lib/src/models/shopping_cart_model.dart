import 'dart:convert';

class ShoppingCart {
  ShoppingCart({
    // this.id,
    required this.clientId,
    required this.productId,
    required this.productImageUrl,
    required this.productPrice,
    required this.productName,
  });

  // int? id;
  int clientId;
  int productId;
  String productImageUrl;
  double productPrice;
  String productName;

  factory ShoppingCart.fromJson(String str) =>
      ShoppingCart.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ShoppingCart.fromMap(Map<String, dynamic> json) => ShoppingCart(
        // id: json["id"],
        clientId: json["clientId"],
        productId: json["productId"],
        productImageUrl: json["productImageUrl"],
        productPrice: json["productPrice"].toDouble(),
        productName: json["productName"],
      );

  Map<String, dynamic> toMap() => {
        // "id": id,
        "clientId": clientId,
        "productId": productId,
        "productImageUrl": productImageUrl,
        "productPrice": productPrice,
        "productName": productName
      };
}
