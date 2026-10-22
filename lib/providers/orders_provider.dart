// lib/providers/orders_provider.dart
// ---------------------------------------------------------------------------
// Phase 1: pure in-memory order store (simulates Supabase backend).
// Phase 2: replace _placeOrderMock with actual Supabase calls.
// ---------------------------------------------------------------------------
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrdersProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  static const _uuid = Uuid();

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get activeOrders =>
      _orders.where((o) => o.isActive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Order> get allOrdersSorted =>
      List.from(_orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Returns the aggregated kitchen summary:
  /// `Map<menuItemId, {name, totalQty}>`
  /// Only active (non-cancelled, non-completed) orders are included.
  Map<String, KitchenSummaryEntry> get kitchenSummary {
    final Map<String, KitchenSummaryEntry> summary = {};
    for (final order in activeOrders) {
      for (final item in order.items) {
        if (summary.containsKey(item.menuItemId)) {
          summary[item.menuItemId] = summary[item.menuItemId]!.addQty(
            item.quantity,
          );
        } else {
          summary[item.menuItemId] = KitchenSummaryEntry(
            menuItemId: item.menuItemId,
            menuItemName: item.menuItemName,
            totalQuantity: item.quantity,
          );
        }
      }
    }
    return summary;
  }

  int get totalActiveItems =>
      kitchenSummary.values.fold(0, (sum, e) => sum + e.totalQuantity);

  // ── Order lifecycle ────────────────────────────────────────────────────────

  /// Place a new order from the current cart.
  Future<Order> placeOrder({
    required String customerName,
    required String? tableNumber,
    required bool isTakeaway,
    required List<CartItem> cartItems,
  }) async {
    // Simulate a short async call (will be Supabase insert in Phase 2)
    await Future.delayed(const Duration(milliseconds: 400));

    final orderId = _uuid.v4();
    final orderItems = cartItems
        .map(
          (ci) => OrderItem(
            id: _uuid.v4(),
            orderId: orderId,
            menuItemId: ci.menuItem.id,
            menuItemName: ci.menuItem.name,
            quantity: ci.quantity,
            unitPrice: ci.menuItem.price,
          ),
        )
        .toList();

    final order = Order(
      id: orderId,
      orderNumber: _generateOrderNumber(),
      customerName: customerName,
      tableNumber: isTakeaway ? null : tableNumber,
      isTakeaway: isTakeaway,
      status: OrderStatus.newOrder,
      items: orderItems,
      createdAt: DateTime.now(),
    );

    _orders.add(order);
    notifyListeners();
    return order;
  }

  /// Update the status of an order (cook dashboard action).
  void updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancelReason,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(
      status: newStatus,
      cancelReason: cancelReason,
    );
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _generateOrderNumber() {
    final now = DateTime.now();
    final seq = (_orders.length + 1).toString().padLeft(3, '0');
    return 'ORD-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$seq';
  }

  /// Seeds two demo orders to prove the aggregation (used in Phase 1 demo).
  void seedDemoOrders(List<dynamic> allMenuItems) {
    if (_orders.isNotEmpty) return; // don't seed twice

    final meals = allMenuItems.firstWhere((m) => m.name == 'Meals');
    final fishFry = allMenuItems.firstWhere((m) => m.name == 'Fish Fry');

    // Customer A: 1 Meals + 1 Fish Fry
    final idA = _uuid.v4();
    _orders.add(
      Order(
        id: idA,
        orderNumber: 'ORD-DEMO-001',
        customerName: 'Customer A',
        tableNumber: '3',
        isTakeaway: false,
        status: OrderStatus.newOrder,
        items: [
          OrderItem(
            id: _uuid.v4(),
            orderId: idA,
            menuItemId: meals.id,
            menuItemName: meals.name,
            quantity: 1,
            unitPrice: meals.price,
          ),
          OrderItem(
            id: _uuid.v4(),
            orderId: idA,
            menuItemId: fishFry.id,
            menuItemName: fishFry.name,
            quantity: 1,
            unitPrice: fishFry.price,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );

    // Customer B: 1 Meals
    final idB = _uuid.v4();
    _orders.add(
      Order(
        id: idB,
        orderNumber: 'ORD-DEMO-002',
        customerName: 'Customer B',
        tableNumber: null,
        isTakeaway: true,
        status: OrderStatus.newOrder,
        items: [
          OrderItem(
            id: _uuid.v4(),
            orderId: idB,
            menuItemId: meals.id,
            menuItemName: meals.name,
            quantity: 1,
            unitPrice: meals.price,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    );

    notifyListeners();
  }
}

// ── Value object for kitchen summary ──────────────────────────────────────────
class KitchenSummaryEntry {
  final String menuItemId;
  final String menuItemName;
  final int totalQuantity;

  const KitchenSummaryEntry({
    required this.menuItemId,
    required this.menuItemName,
    required this.totalQuantity,
  });

  KitchenSummaryEntry addQty(int qty) => KitchenSummaryEntry(
    menuItemId: menuItemId,
    menuItemName: menuItemName,
    totalQuantity: totalQuantity + qty,
  );
}
