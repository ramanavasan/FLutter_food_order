// lib/models/order.dart
import 'order_item.dart';

/// Valid order statuses – matches the database CHECK constraint.
enum OrderStatus {
  newOrder('new'),
  accepted('accepted'),
  preparing('preparing'),
  ready('ready'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String s) => OrderStatus.values.firstWhere(
    (e) => e.value == s,
    orElse: () => OrderStatus.newOrder,
  );

  String get label {
    switch (this) {
      case OrderStatus.newOrder:
        return 'New';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String customerName;
  final String? tableNumber; // null = takeaway
  final bool isTakeaway;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String? cancelReason;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    this.tableNumber,
    this.isTakeaway = false,
    required this.status,
    required this.items,
    required this.createdAt,
    this.cancelReason,
  });

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  /// Returns true if this order should be included in the active kitchen summary.
  bool get isActive =>
      status != OrderStatus.completed && status != OrderStatus.cancelled;

  Order copyWith({
    OrderStatus? status,
    String? cancelReason,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      tableNumber: tableNumber,
      isTakeaway: isTakeaway,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map, List<OrderItem> orderItems) {
    return Order(
      id: map['id'] as String,
      orderNumber: map['order_number'] as String,
      customerName: map['customer_name'] as String,
      tableNumber: map['table_number'] as String?,
      isTakeaway: map['is_takeaway'] as bool? ?? false,
      status: OrderStatus.fromString(map['status'] as String? ?? 'new'),
      items: orderItems,
      createdAt: DateTime.parse(map['created_at'] as String),
      cancelReason: map['cancel_reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_number': orderNumber,
    'customer_name': customerName,
    'table_number': tableNumber,
    'is_takeaway': isTakeaway,
    'status': status.value,
    'created_at': createdAt.toIso8601String(),
    'cancel_reason': cancelReason,
  };
}
