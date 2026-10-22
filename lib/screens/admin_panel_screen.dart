// lib/screens/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/menu_item.dart';
import '../models/order.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../services/whatsapp_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, size: 24),
            const SizedBox(width: 8),
            Text(
              'Restaurant Admin Panel',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu Items'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders & Kitchen'),
            Tab(icon: Icon(Icons.storefront), text: 'Hotel Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AdminMenuTab(),
          _AdminOrdersTab(),
          _AdminSettingsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: Menu Management
// ─────────────────────────────────────────────────────────────────────────────
class _AdminMenuTab extends StatelessWidget {
  const _AdminMenuTab();

  void _showAddEditDialog(BuildContext context, [MenuItem? existingItem]) {
    final menuProvider = context.read<MenuProvider>();
    final nameCtrl = TextEditingController(text: existingItem?.name ?? '');
    final descCtrl = TextEditingController(text: existingItem?.description ?? '');
    final priceCtrl = TextEditingController(
      text: existingItem != null ? existingItem.price.toStringAsFixed(0) : '',
    );
    final imgCtrl = TextEditingController(text: existingItem?.imageUrl ?? '');
    final prepCtrl = TextEditingController(
      text: existingItem != null ? '${existingItem.prepTimeMinutes}' : '15',
    );
    String selectedCategory = existingItem?.category ?? 'Meals & Rice';
    bool isVeg = existingItem?.isVeg ?? true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                existingItem == null ? 'Add Food Dish' : 'Edit Dish',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Dish Name *',
                          hintText: 'e.g. Chicken 65, Paneer Tikka',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹) *',
                                prefixText: '₹ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: prepCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Prep Time (mins)',
                                suffixText: 'min',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Meals & Rice',
                            child: Text('Meals & Rice'),
                          ),
                          DropdownMenuItem(
                            value: 'Starters & Frys',
                            child: Text('Starters & Frys'),
                          ),
                          DropdownMenuItem(
                            value: 'Breads & Tiffin',
                            child: Text('Breads & Tiffin'),
                          ),
                          DropdownMenuItem(
                            value: 'Curries & Gravies',
                            child: Text('Curries & Gravies'),
                          ),
                          DropdownMenuItem(
                            value: 'Beverages & Desserts',
                            child: Text('Beverages & Desserts'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imgCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                          hintText: 'https://images.unsplash.com/...',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Ingredients, flavor and preparation notes',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: Text(
                          isVeg ? 'Vegetarian Dish (Veg)' : 'Non-Vegetarian (Non-Veg)',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: isVeg
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                        ),
                        secondary: Icon(
                          Icons.circle,
                          color: isVeg
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          size: 16,
                        ),
                        value: isVeg,
                        onChanged: (val) => setState(() => isVeg = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                    if (name.isEmpty || price <= 0) return;

                    if (existingItem == null) {
                      menuProvider.addItem(
                        name: name,
                        description: descCtrl.text.trim(),
                        price: price,
                        category: selectedCategory,
                        imageUrl: imgCtrl.text.trim().isNotEmpty
                            ? imgCtrl.text.trim()
                            : null,
                        isVeg: isVeg,
                        prepTimeMinutes: int.tryParse(prepCtrl.text) ?? 15,
                      );
                    } else {
                      menuProvider.updateItem(
                        existingItem.copyWith(
                          name: name,
                          description: descCtrl.text.trim(),
                          price: price,
                          category: selectedCategory,
                          imageUrl: imgCtrl.text.trim().isNotEmpty
                              ? imgCtrl.text.trim()
                              : null,
                          isVeg: isVeg,
                          prepTimeMinutes: int.tryParse(prepCtrl.text) ?? 15,
                        ),
                      );
                    }
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(existingItem == null ? 'Add Dish' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final items = menuProvider.allItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu Inventory (${items.length} items)',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Add, edit, or toggle availability of dishes in real-time',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Dish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: item.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.restaurant),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.restaurant),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: item.isVeg
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFC62828),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppTheme.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.category} • ₹${item.price.toStringAsFixed(0)} • ${item.prepTimeMinutes} mins',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppTheme.textMedium,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppTheme.textLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // In Stock Switch
                            Column(
                              children: [
                                Switch(
                                  value: item.isAvailable,
                                  activeThumbColor: AppTheme.success,
                                  onChanged: (_) =>
                                      menuProvider.toggleAvailability(item.id),
                                ),
                                Text(
                                  item.isAvailable ? 'In Stock' : 'Sold Out',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.isAvailable
                                        ? AppTheme.success
                                        : Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                            // Actions
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showAddEditDialog(context, item);
                                } else if (val == 'delete') {
                                  menuProvider.deleteItem(item.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Dish'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: Live Orders & Kitchen Control
// ─────────────────────────────────────────────────────────────────────────────
class _AdminOrdersTab extends StatefulWidget {
  const _AdminOrdersTab();

  @override
  State<_AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<_AdminOrdersTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final restaurant = context.watch<RestaurantConfig>();
    final allOrders = ordersProvider.allOrdersSorted;

    final filtered = _selectedFilter == 'All'
        ? allOrders
        : allOrders
            .where((o) =>
                o.status.label.toLowerCase() == _selectedFilter.toLowerCase())
            .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            // Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'New',
                    'Accepted',
                    'Preparing',
                    'Ready',
                    'Completed',
                    'Cancelled',
                  ].map((status) {
                    final isSel = _selectedFilter == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSel,
                        selectedColor: AppTheme.primary,
                        labelStyle: GoogleFonts.outfit(
                          color: isSel ? Colors.white : AppTheme.textDark,
                          fontWeight:
                              isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedFilter = status),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'No orders in this category',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final order = filtered[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.orderNumber,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.isTakeaway
                                      ? 'Takeaway'
                                      : 'Table ${order.tableNumber}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusColor(
                                      order.status.value,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    order.status.label,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.statusColor(
                                        order.status.value,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer: ${order.customerName}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMedium,
                                fontSize: 13,
                              ),
                            ),
                            const Divider(height: 18),
                            ...order.items.map(
                              (it) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text(
                                      '${it.quantity}×',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        it.menuItemName,
                                        style: GoogleFonts.outfit(
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${it.subtotal.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 18),
                            Row(
                              children: [
                                Text(
                                  'Total: ₹${order.total.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const Spacer(),
                                // WhatsApp share button
                                IconButton(
                                  icon: const Icon(
                                    Icons.chat,
                                    color: Color(0xFF25D366),
                                  ),
                                  tooltip: 'Send to WhatsApp',
                                  onPressed: () {
                                    WhatsAppService.sendOrderViaWhatsApp(
                                      order: order,
                                      whatsappNumber: restaurant.whatsappNumber,
                                      restaurantName: restaurant.hotelName,
                                      restaurantLocation: restaurant.location,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                // Change status popup
                                PopupMenuButton<OrderStatus>(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Change Status',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onSelected: (newSt) {
                                    ordersProvider.updateOrderStatus(
                                      order.id,
                                      newSt,
                                    );
                                  },
                                  itemBuilder: (_) => OrderStatus.values.map(
                                    (st) => PopupMenuItem(
                                      value: st,
                                      child: Text(st.label),
                                    ),
                                  ).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: Hotel & WhatsApp Settings
// ─────────────────────────────────────────────────────────────────────────────
class _AdminSettingsTab extends StatefulWidget {
  const _AdminSettingsTab();

  @override
  State<_AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<_AdminSettingsTab> {
  final _hotelNameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = context.read<RestaurantConfig>();
    _hotelNameCtrl.text = r.hotelName;
    _taglineCtrl.text = r.tagline;
    _locationCtrl.text = r.location;
    _whatsappCtrl.text = r.whatsappNumber;
  }

  @override
  void dispose() {
    _hotelNameCtrl.dispose();
    _taglineCtrl.dispose();
    _locationCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final r = context.read<RestaurantConfig>();
    r.updateSettings(
      hotelName: _hotelNameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restaurant settings & WhatsApp number updated!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hotel & WhatsApp Configuration',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Update your restaurant brand details, location, and the WhatsApp number where incoming orders will be delivered.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _hotelNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hotel / Restaurant Name',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taglineCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tagline / Slogan',
                  prefixIcon: Icon(Icons.subtitles_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hotel Location & Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _whatsappCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Restaurant WhatsApp Phone Number',
                  hintText: 'e.g. 918870804734 (with country code)',
                  prefixIcon: Icon(Icons.chat, color: Color(0xFF25D366)),
                  helperText:
                      'Customer orders will automatically open WhatsApp directed to this number.',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save Restaurant Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saveSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
