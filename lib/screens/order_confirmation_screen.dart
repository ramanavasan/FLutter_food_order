// lib/screens/order_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../services/whatsapp_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  final String? customerPhone;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
    this.customerPhone,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantConfig>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Placed'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Text('Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Success icon
                Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 56,
                        color: AppTheme.success,
                      ),
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 250.ms),
                const SizedBox(height: 16),
                Text(
                  'Order Received!',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 6),
                Text(
                  'Your food is being prepared at ${restaurant.hotelName} 🍽️',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 24),

                // WhatsApp Dispatch Banner Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF25D366).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Color(0xFF128C7E),
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WhatsApp Order Dispatch',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: const Color(0xFF075E54),
                                  ),
                                ),
                                Text(
                                  'Notify the kitchen or check order status via WhatsApp',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            'Send Details to WhatsApp (+${restaurant.whatsappNumber})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            WhatsAppService.sendOrderViaWhatsApp(
                              order: order,
                              whatsappNumber: restaurant.whatsappNumber,
                              restaurantName: restaurant.hotelName,
                              restaurantLocation: restaurant.location,
                              customerPhone: customerPhone,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),
                // Order details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.orderNumber,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _StatusPill(order.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        Icons.person_outline,
                        'Customer',
                        order.customerName,
                      ),
                      if (customerPhone != null &&
                          customerPhone!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          Icons.phone_outlined,
                          'Phone',
                          customerPhone!,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _InfoRow(
                        order.isTakeaway
                            ? Icons.takeout_dining
                            : Icons.table_restaurant,
                        order.isTakeaway ? 'Type' : 'Table',
                        order.isTakeaway
                            ? 'Takeaway / Parcel'
                            : 'Table ${order.tableNumber}',
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        'Items Ordered',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${item.quantity}×',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menuItemName,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${item.subtotal.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${order.total.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Order More / Back to Menu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(color: AppTheme.textLight, fontSize: 13.5),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;
  const _StatusPill(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.statusColor(status.value).withValues(alpha: 0.12),
        border: Border.all(color: AppTheme.statusColor(status.value)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.outfit(
          color: AppTheme.statusColor(status.value),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
