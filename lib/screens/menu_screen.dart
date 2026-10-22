// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../widgets/food_card.dart';
import '../widgets/cart_bottom_sheet.dart';
import 'checkout_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartBottomSheet(
        onCheckout: () {
          Navigator.pop(context); // close sheet
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final items = menuProvider.filteredItems;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _HeroAppBar(isWide: isWide),
                  // Search & Quick Dietary Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: Column(
                        children: [
                          _SearchBar(controller: _searchController),
                          const SizedBox(height: 10),
                          _FilterRow(),
                        ],
                      ),
                    ),
                  ),
                  // Category Bar
                  SliverToBoxAdapter(
                    child: _CategoryBar(
                      categories: menuProvider.categories,
                      selected: menuProvider.selectedCategory,
                      onSelect: menuProvider.setCategory,
                    ),
                  ),
                  // Items Grid
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No dishes found',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for something else or change filters',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (crossAxisCount == 1)
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 110,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              FoodCard(item: items[i], animationIndex: i),
                          childCount: items.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.82,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              FoodCard(item: items[i], animationIndex: i),
                          childCount: items.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _CartFab(onTap: _openCart),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Hero App Bar ──────────────────────────────────────────────────────────────
class _HeroAppBar extends StatelessWidget {
  final bool isWide;
  const _HeroAppBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantConfig>();

    return SliverAppBar(
      expandedHeight: isWide ? 180 : 210,
      pinned: true,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFBF360C), AppTheme.primary, Color(0xFFE64A19)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          restaurant.hotelName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: isWide ? 28 : 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.tagline,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFFD54F),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            restaurant.location,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          restaurant.hotelName,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final menu = context.read<MenuProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: menu.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search biryani, dosa, curries, meals...',
          hintStyle: GoogleFonts.outfit(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    menu.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ── Dietary Filters Row ───────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final vegState = menu.vegOnly;

    return Row(
      children: [
        _DietChoiceChip(
          label: 'All Items',
          isSelected: vegState == null,
          onTap: () => menu.toggleVegFilter(null),
        ),
        const SizedBox(width: 8),
        _DietChoiceChip(
          label: 'Veg Only',
          icon: Icons.eco_rounded,
          iconColor: const Color(0xFF2E7D32),
          isSelected: vegState == true,
          onTap: () => menu.toggleVegFilter(vegState == true ? null : true),
        ),
        const SizedBox(width: 8),
        _DietChoiceChip(
          label: 'Non-Veg',
          icon: Icons.set_meal_rounded,
          iconColor: const Color(0xFFC62828),
          isSelected: vegState == false,
          onTap: () => menu.toggleVegFilter(vegState == false ? null : false),
        ),
      ],
    );
  }
}

class _DietChoiceChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietChoiceChip({
    required this.label,
    this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category bar ──────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: 200.ms,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : AppTheme.textMedium,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Cart Floating Bar ─────────────────────────────────────────────────────────
class _CartFab extends StatelessWidget {
  final VoidCallback onTap;
  const _CartFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.itemCount == 0) return const SizedBox.shrink();
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'View Cart',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${cart.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 1, end: 0, duration: 250.ms).fadeIn();
      },
    );
  }
}
