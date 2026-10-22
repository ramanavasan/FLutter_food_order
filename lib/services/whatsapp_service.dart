// lib/services/whatsapp_service.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/order.dart';

class WhatsAppService {
  /// Builds the formatted order text suitable for WhatsApp.
  static String buildOrderMessage({
    required Order order,
    required String restaurantName,
    required String restaurantLocation,
    String? customerPhone,
  }) {
    final buffer = StringBuffer();
    final timeStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    buffer.writeln('🛎️ *NEW ORDER - ${restaurantName.toUpperCase()}*');
    buffer.writeln('📍 _${restaurantLocation}_');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🔖 *Order ID*: ${order.orderNumber}');
    buffer.writeln('🕒 *Placed At*: $timeStr');
    buffer.writeln('👤 *Customer*: ${order.customerName}');
    if (customerPhone != null && customerPhone.isNotEmpty) {
      buffer.writeln('📞 *Phone*: $customerPhone');
    }
    buffer.writeln(
      order.isTakeaway
          ? '📦 *Type*: Takeaway / Parcel'
          : '🍽️ *Type*: Dine-In (Table ${order.tableNumber ?? 'N/A'})',
    );
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📋 *ORDER ITEMS*:');

    for (var i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      buffer.writeln(
        '  ${i + 1}. *${item.menuItemName}* × ${item.quantity}  =  ₹${item.subtotal.toStringAsFixed(0)}',
      );
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💰 *TOTAL AMOUNT*: ₹${order.total.toStringAsFixed(0)}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✨ _Please confirm this order. Thank you!_');

    return buffer.toString();
  }

  /// Launches WhatsApp with the formatted order text.
  static Future<bool> sendOrderViaWhatsApp({
    required Order order,
    required String whatsappNumber,
    required String restaurantName,
    required String restaurantLocation,
    String? customerPhone,
  }) async {
    final cleanPhone = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final message = buildOrderMessage(
      order: order,
      restaurantName: restaurantName,
      restaurantLocation: restaurantLocation,
      customerPhone: customerPhone,
    );

    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$cleanPhone?text=$encodedMessage';
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      return false;
    }
  }
}
