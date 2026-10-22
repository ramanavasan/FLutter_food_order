// lib/widgets/order_ticket.dart
// ── Individual order ticket card used on the cook dashboard. ──────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';
import '../config/app_theme.dart';

class OrderTicket extends StatelessWidget {
  final Order order;
  final void Function(OrderStatus newStatus, {String? cancelReason})
  onStatusChange;

  const OrderTicket({
    super.key,
    required this.order,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNew = order.status == OrderStatus.newOrder;
    return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppTheme.kitchenCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isNew
                ? const BorderSide(color: AppTheme.kitchenAccent, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TicketHeader(order: order),
                const SizedBox(height: 12),
                _ItemsList(order: order),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                _ActionButtons(order: order, onStatusChange: onStatusChange),
              ],
            ),
          ),
        )
        .animate(key: ValueKey(order.id))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}

class _TicketHeader extends StatelessWidget {
  final Order order;
  const _TicketHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order number & customer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber,
                style: GoogleFonts.outfit(
                  color: AppTheme.kitchenAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.customerName,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    order.isTakeaway
                        ? Icons.takeout_dining
                        : Icons.table_restaurant,
                    size: 14,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isTakeaway
                        ? 'Takeaway'
                        : 'Table ${order.tableNumber}',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusBadge(order.status),
            const SizedBox(height: 6),
            Text(
              DateFormat('hh:mm a').format(order.createdAt),
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${order.total.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.statusColor(status.value).withValues(alpha: 0.2),
        border: Border.all(
          color: AppTheme.statusColor(status.value),
          width: 1.2,
        ),
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

class _ItemsList extends StatelessWidget {
  final Order order;
  const _ItemsList({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: order.items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.menuItemName,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '₹${item.subtotal.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Order order;
  final void Function(OrderStatus, {String? cancelReason}) onStatusChange;

  const _ActionButtons({required this.order, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case OrderStatus.newOrder:
        return Row(
          children: [
            _KitchenBtn(
              'Accept',
              Icons.check_circle_outline,
              AppTheme.statusAccepted,
              () => onStatusChange(OrderStatus.accepted),
            ),
            const SizedBox(width: 8),
            _KitchenBtn(
              'Cancel',
              Icons.cancel_outlined,
              AppTheme.statusCancelled,
              () => _showCancelDialog(context),
            ),
          ],
        );
      case OrderStatus.accepted:
        return Row(
          children: [
            _KitchenBtn(
              'Start Preparing',
              Icons.local_fire_department,
              AppTheme.statusPreparing,
              () => onStatusChange(OrderStatus.preparing),
            ),
            const SizedBox(width: 8),
            _KitchenBtn(
              'Cancel',
              Icons.cancel_outlined,
              AppTheme.statusCancelled,
              () => _showCancelDialog(context),
            ),
          ],
        );
      case OrderStatus.preparing:
        return _KitchenBtn(
          'Mark Ready',
          Icons.restaurant,
          AppTheme.statusReady,
          () => onStatusChange(OrderStatus.ready),
        );
      case OrderStatus.ready:
        return _KitchenBtn(
          'Complete',
          Icons.done_all,
          AppTheme.statusCompleted,
          () => onStatusChange(OrderStatus.completed),
        );
      case OrderStatus.completed:
        return Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.statusCompleted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Completed',
              style: GoogleFonts.outfit(
                color: AppTheme.statusCompleted,
                fontSize: 14,
              ),
            ),
          ],
        );
      case OrderStatus.cancelled:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cancel,
                  color: AppTheme.statusCancelled,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cancelled',
                  style: GoogleFonts.outfit(
                    color: AppTheme.statusCancelled,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (order.cancelReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Reason: ${order.cancelReason}',
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
              ),
            ],
          ],
        );
    }
  }

  void _showCancelDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.kitchenCard,
        title: Text(
          'Cancel Order',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Reason (optional)',
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Back',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusCancelled,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onStatusChange(
                OrderStatus.cancelled,
                cancelReason: controller.text.trim().isEmpty
                    ? null
                    : controller.text.trim(),
              );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }
}

class _KitchenBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _KitchenBtn(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
