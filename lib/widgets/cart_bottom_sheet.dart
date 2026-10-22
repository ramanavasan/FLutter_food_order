// lib/widgets/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import '../config/app_theme.dart';

class CartBottomSheet extends StatelessWidget {
  final VoidCallback onCheckout;

  const CartBottomSheet({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Your Cart',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: cart.itemCount > 0 ? cart.clear : null,
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.outfit(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (cart.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your cart is empty',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final ci = cart.items[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        title: Text(
                          ci.menuItem.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '₹${ci.menuItem.price.toStringAsFixed(0)} each',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${ci.subtotal.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _MiniQtyControl(
                              qty: ci.quantity,
                              onAdd: () => cart.addItem(ci.menuItem),
                              onRemove: () => cart.removeItem(ci.menuItem.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total (${cart.itemCount} items)',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: cart.itemCount > 0 ? onCheckout : null,
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }
}

class _MiniQtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MiniQtyControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallBtn(icon: Icons.remove, onTap: onRemove),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$qty',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        _SmallBtn(icon: Icons.add, onTap: onAdd),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}
