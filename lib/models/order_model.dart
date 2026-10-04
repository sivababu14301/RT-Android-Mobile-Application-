import '../config/api_config.dart';
import 'user_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> orderItems;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final double itemsPrice;
  final double shippingPrice;
  final double totalPrice;
  final bool isPaid;
  final DateTime? paidAt;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final String status;
  final DateTime createdAt;
  final List<StatusHistoryItem> statusHistory;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.itemsPrice,
    required this.shippingPrice,
    required this.totalPrice,
    required this.isPaid,
    this.paidAt,
    required this.isDelivered,
    this.deliveredAt,
    required this.status,
    required this.createdAt,
    this.statusHistory = const [],
  });

  // Aliases for compatibility with old UI code
  String get orderStatus => status;
  List<OrderItem> get products => orderItems;
  double get totalAmount => totalPrice;
  AddressModel get address => shippingAddress;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] is Map ? (json['user']['_id'] ?? json['user']['id'] ?? '') : (json['user'] ?? ''),
      orderItems: json['orderItems'] != null 
          ? (json['orderItems'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : [],
      shippingAddress: AddressModel.fromJson(json['shippingAddress'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? '',
      itemsPrice: (json['itemsPrice'] ?? 0).toDouble(),
      shippingPrice: (json['shippingPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
      isDelivered: json['isDelivered'] ?? false,
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt'].toString()) : null,
      status: json['status'] ?? 'Order Placed',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List)
              .map((item) => StatusHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class StatusHistoryItem {
  final String status;
  final String date;
  final String time;
  final DateTime? updatedAt;

  StatusHistoryItem({
    required this.status,
    required this.date,
    required this.time,
    this.updatedAt,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final String image;
  final double price;
  final String? size;
  final String? color;
  final String product;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.image,
    required this.price,
    this.size,
    this.color,
    required this.product,
  });

  // Alias for compatibility
  String get imageUrl => image.startsWith('http') ? image : '${ApiConfig.baseServerUrl}${image.startsWith('/') ? '' : '/'}$image';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      size: json['size'],
      color: json['color'],
      product: json['product'] ?? '',
    );
  }
}
