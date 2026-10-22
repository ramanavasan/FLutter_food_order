// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../services/whatsapp_service.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tableController = TextEditingController();
  bool _isTakeaway = false;
  bool _openWhatsAppOnOrder = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final cart = context.read<CartProvider>();
      final orders = context.read<OrdersProvider>();
      final restaurant = context.read<RestaurantConfig>();

      final order = await orders.placeOrder(
        customerName: _nameController.text.trim(),
        tableNumber: _isTakeaway ? null : _tableController.text.trim(),
        isTakeaway: _isTakeaway,
        cartItems: cart.items,
      );

      final phone = _phoneController.text.trim();

      // Open WhatsApp automatically if selected
      if (_openWhatsAppOnOrder) {
        await WhatsAppService.sendOrderViaWhatsApp(
          order: order,
          whatsappNumber: restaurant.whatsappNumber,
          restaurantName: restaurant.hotelName,
          restaurantLocation: restaurant.location,
          customerPhone: phone.isNotEmpty ? phone : null,
        );
      }

      cart.clear();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            order: order,
            customerPhone: phone.isNotEmpty ? phone : null,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final restaurant = context.watch<RestaurantConfig>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Your Details'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone / WhatsApp Number (Optional)',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Order Type Selection
                  _SectionTitle('Order Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _OrderTypeBtn(
                          title: 'Dine-In',
                          subtitle: 'Serve at table',
                          icon: Icons.table_restaurant,
                          isSelected: !_isTakeaway,
                          onTap: () => setState(() => _isTakeaway = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OrderTypeBtn(
                          title: 'Takeaway',
                          subtitle: 'Pack for parcel',
                          icon: Icons.takeout_dining,
                          isSelected: _isTakeaway,
                          onTap: () => setState(() => _isTakeaway = true),
                        ),
                      ),
                    ],
                  ),
                  if (!_isTakeaway) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tableController,
                      decoration: const InputDecoration(
                        labelText: 'Table Number *',
                        hintText: 'e.g. 4, 12, Outdoor-2',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (v) {
                        if (!_isTakeaway && (v == null || v.trim().isEmpty)) {
                          return 'Please enter your table number';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  // WhatsApp Notification Toggle
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF25D366).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF25D366),
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Send Order to Restaurant WhatsApp',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Instantly sends receipt to ${restaurant.hotelName} (+${restaurant.whatsappNumber})',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _openWhatsAppOnOrder,
                          activeThumbColor: const Color(0xFF25D366),
                          onChanged: (val) =>
                              setState(() => _openWhatsAppOnOrder = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Order Summary'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(
                                  '${item.quantity}×',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.menuItem.name,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textDark,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${item.subtotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Text(
                              'Total Pay',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || cart.itemCount == 0
                          ? null
                          : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirm & Place Order (₹${cart.totalAmount.toStringAsFixed(0)})',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _OrderTypeBtn extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeBtn({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.textMedium,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.primary : AppTheme.textDark,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: AppTheme.textLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
