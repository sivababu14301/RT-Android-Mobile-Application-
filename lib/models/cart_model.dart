class CartItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;
  final String size;
  final String color;
  final String fabric;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    required this.size,
    required this.color,
    required this.fabric,
  });

  double get total => price * quantity;
}
