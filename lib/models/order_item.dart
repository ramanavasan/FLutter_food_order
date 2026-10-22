// lib/models/order_item.dart

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice; // price snapshot at time of order

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      menuItemId: map['menu_item_id'] as String,
      menuItemName: map['menu_item_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'menu_item_id': menuItemId,
    'menu_item_name': menuItemName,
    'quantity': quantity,
    'unit_price': unitPrice,
  };
}
