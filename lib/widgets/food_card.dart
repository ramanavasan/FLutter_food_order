// lib/widgets/food_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../config/app_theme.dart';

class FoodCard extends StatelessWidget {
  final MenuItem item;
  final int animationIndex;

  const FoodCard({super.key, required this.item, this.animationIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.quantityOf(item.id);
        final bool isAvailable = item.isAvailable;

        return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Opacity(
                opacity: isAvailable ? 1.0 : 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _FoodImage(imageUrl: item.imageUrl),
                        // Veg / Non-veg indicator badge
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _VegBadge(isVeg: item.isVeg),
                        ),
                        // Category chip
                        Positioned(
                          top: 10,
                          right: 10,
                          child: _CategoryChip(item.category),
                        ),
                        // Out of stock banner
                        if (!isAvailable)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'SOLD OUT',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Rating & Prep Time Row
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB300),
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${item.prepTimeMinutes} mins',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: AppTheme.textLight,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '₹${item.price.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const Spacer(),
                              if (!isAvailable)
                                Text(
                                  'Unavailable',
                                  style: GoogleFonts.outfit(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                )
                              else if (qty == 0)
                                _AddButton(onTap: () => cart.addItem(item))
                              else
                                _QuantityControl(
                                  qty: qty,
                                  onAdd: () => cart.addItem(item),
                                  onRemove: () => cart.removeItem(item.id),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: 50 * animationIndex))
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.1, end: 0, duration: 250.ms);
      },
    );
  }
}

class _FoodImage extends StatelessWidget {
  final String? imageUrl;
  const _FoodImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: 150,
        color: AppTheme.secondary.withValues(alpha: 0.2),
        child: const Center(
          child: Icon(Icons.restaurant, size: 48, color: AppTheme.secondary),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 150, color: Colors.white),
      ),
      errorWidget: (context, url, error) => Container(
        height: 150,
        color: AppTheme.secondary.withValues(alpha: 0.2),
        child: const Center(
          child: Icon(Icons.restaurant, size: 40, color: AppTheme.secondary),
        ),
      ),
    );
  }
}

class _VegBadge extends StatelessWidget {
  final bool isVeg;
  const _VegBadge({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.circle,
        size: 9,
        color: color,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleBtn(icon: Icons.remove, onTap: onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          _CircleBtn(icon: Icons.add, onTap: onAdd),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
