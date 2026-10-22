// lib/services/supabase_service.dart
// ---------------------------------------------------------------------------
// Phase 2 – Supabase backend integration.
// All methods currently throw UnimplementedError so Phase 1 still uses
// OrdersProvider's in-memory implementation.
// ---------------------------------------------------------------------------
//
// HOW TO ACTIVATE (Phase 2):
// 1. Copy your Supabase URL and anon key into lib/config/app_config.dart
// 2. Uncomment Supabase.initialize() in lib/main.dart
// 3. Replace the OrdersProvider placeOrder() body with a call to
//    SupabaseService.placeOrder() below.
// 4. Add Realtime subscriptions in the provider.
//
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/order.dart';
// import '../models/order_item.dart';
// import '../models/cart_item.dart';
// import '../models/menu_item.dart';

// class SupabaseService {
//   static SupabaseClient get _client => Supabase.instance.client;
//
//   // ── Menu ────────────────────────────────────────────────────────────────
//   static Future<List<MenuItem>> fetchMenuItems() async {
//     final data = await _client
//         .from('menu_items')
//         .select()
//         .eq('is_available', true)
//         .order('sort_order');
//     return (data as List).map((m) => MenuItem.fromMap(m)).toList();
//   }
//
//   // ── Orders ──────────────────────────────────────────────────────────────
//   static Future<Order> placeOrder({
//     required String customerName,
//     required String? tableNumber,
//     required bool isTakeaway,
//     required List<CartItem> cartItems,
//   }) async {
//     final user = _client.auth.currentUser;
//     final orderNumber = await _client.rpc('generate_order_number') as String;
//
//     final orderData = await _client.from('orders').insert({
//       'order_number': orderNumber,
//       'customer_id': user?.id,
//       'customer_name': customerName,
//       'table_number': isTakeaway ? null : tableNumber,
//       'is_takeaway': isTakeaway,
//       'total_amount': cartItems.fold(0.0, (s, i) => s + i.subtotal),
//     }).select().single();
//
//     final orderId = orderData['id'] as String;
//
//     final itemRows = cartItems.map((ci) => {
//       'order_id': orderId,
//       'menu_item_id': ci.menuItem.id,
//       'menu_item_name': ci.menuItem.name,
//       'quantity': ci.quantity,
//       'unit_price': ci.menuItem.price,
//     }).toList();
//
//     await _client.from('order_items').insert(itemRows);
//
//     final items = await _client
//         .from('order_items')
//         .select()
//         .eq('order_id', orderId);
//
//     return Order.fromMap(orderData, (items as List).map((i) => OrderItem.fromMap(i)).toList());
//   }
//
//   // ── Realtime ─────────────────────────────────────────────────────────────
//   static RealtimeChannel subscribeToOrders(void Function() onUpdate) {
//     return _client
//         .channel('kitchen-orders')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.all,
//           schema: 'public',
//           table: 'orders',
//           callback: (_) => onUpdate(),
//         )
//         .onPostgresChanges(
//           event: PostgresChangeEvent.all,
//           schema: 'public',
//           table: 'order_items',
//           callback: (_) => onUpdate(),
//         )
//         .subscribe();
//   }
//
//   static Future<void> updateOrderStatus(
//       String orderId, String status, {String? cancelReason}) async {
//     await _client.from('orders').update({
//       'status': status,
//       if (cancelReason != null) 'cancel_reason': cancelReason,
//     }).eq('id', orderId);
//   }
// }

// Placeholder to satisfy import analysis in Phase 1:
class SupabaseService {
  const SupabaseService._();
}
