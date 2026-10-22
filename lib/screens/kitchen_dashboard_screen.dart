// lib/screens/kitchen_dashboard_screen.dart
// ── Cook's live kitchen dashboard (Phase 1: mock data) ────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../config/app_theme.dart';
import '../services/mock_data.dart';
import '../widgets/order_ticket.dart';

class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({super.key});

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Seed demo orders once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().seedDemoOrders(MockData.menuItems);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _filteredOrders(List<Order> all) {
    if (_selectedStatus == 'All') return all;
    final status = _selectedStatus.toLowerCase();
    return all
        .where((o) => o.status.value == (status == 'new' ? 'new' : status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kitchenBg,
      appBar: AppBar(
        backgroundColor: AppTheme.kitchenBg,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: AppTheme.kitchenAccent,
            ),
            const SizedBox(width: 8),
            Text(
              'Kitchen Dashboard',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.kitchenAccent,
          labelColor: AppTheme.kitchenAccent,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.summarize_outlined), text: 'Summary'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SummaryTab(),
          _OrdersTab(
            selectedStatus: _selectedStatus,
            onStatusChanged: (s) => setState(() => _selectedStatus = s),
            filteredOrders: (all) => _filteredOrders(all),
          ),
        ],
      ),
    );
  }
}

// ── Summary Tab ───────────────────────────────────────────────────────────────
class _SummaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, orders, _) {
        final summary = orders.kitchenSummary;
        final totalItems = orders.totalActiveItems;
        final activeCount = orders.activeOrders.length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _StatCard(
                          'Active Orders',
                          '$activeCount',
                          Icons.receipt_outlined,
                          AppTheme.statusNew,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          'Total Items',
                          '$totalItems',
                          Icons.fastfood_outlined,
                          AppTheme.kitchenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Section header
                    Row(
                      children: [
                        const Icon(
                          Icons.summarize,
                          color: AppTheme.kitchenAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Items to Prepare',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active orders only',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (summary.isEmpty)
              SliverFillRemaining(child: _EmptyKitchenState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final entry = summary.values.toList()[i];
                    return _SummaryTile(entry: entry, index: i);
                  }, childCount: summary.length),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final KitchenSummaryEntry entry;
  final int index;

  const _SummaryTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.kitchenCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              // Big qty badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.kitchenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.kitchenAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${entry.totalQuantity}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.kitchenAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.menuItemName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      entry.totalQuantity == 1
                          ? '1 portion needed'
                          : '${entry.totalQuantity} portions needed',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.primary,
                size: 22,
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0, duration: 300.ms);
  }
}

class _EmptyKitchenState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No active orders',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here in real time.',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final List<Order> Function(List<Order>) filteredOrders;

  const _OrdersTab({
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.filteredOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, orders, _) {
        final all = orders.allOrdersSorted;
        final filtered = filteredOrders(all);

        return Column(
          children: [
            // Status filter chips
            _StatusFilterBar(
              selected: selectedStatus,
              onSelected: onStatusChanged,
            ),
            // Order list
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyKitchenState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final order = filtered[i];
                        return OrderTicket(
                          key: ValueKey(order.id),
                          order: order,
                          onStatusChange: (newStatus, {cancelReason}) {
                            orders.updateOrderStatus(
                              order.id,
                              newStatus,
                              cancelReason: cancelReason,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  static const _options = [
    'All',
    'New',
    'Accepted',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled',
  ];

  const _StatusFilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.kitchenBg,
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: _options.map((opt) {
          final isSelected = opt == selected;
          final color = opt == 'All'
              ? Colors.white
              : AppTheme.statusColor(
                  opt.toLowerCase() == 'new' ? 'new' : opt.toLowerCase(),
                );
          return GestureDetector(
            onTap: () => onSelected(opt),
            child: AnimatedContainer(
              duration: 200.ms,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? color : Colors.white24),
              ),
              child: Text(
                opt,
                style: GoogleFonts.outfit(
                  color: isSelected ? color : Colors.white54,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
