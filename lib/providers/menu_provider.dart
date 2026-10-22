// lib/providers/menu_provider.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/menu_item.dart';
import '../services/mock_data.dart';

class MenuProvider extends ChangeNotifier {
  final List<MenuItem> _items = List.from(MockData.menuItems);
  static const _uuid = Uuid();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool? _vegOnly; // null = all, true = veg only, false = non-veg only

  List<MenuItem> get allItems => List.unmodifiable(_items);

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool? get vegOnly => _vegOnly;

  List<String> get categories {
    final Set<String> cats = {'All'};
    for (final item in _items) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  /// Filtered menu items for customer menu screen
  List<MenuItem> get filteredItems {
    return _items.where((item) {
      // Category filter
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }
      // Veg filter
      if (_vegOnly != null && item.isVeg != _vegOnly) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchDesc = item.description.toLowerCase().contains(query);
        final matchCat = item.category.toLowerCase().contains(query);
        if (!matchName && !matchDesc && !matchCat) return false;
      }
      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleVegFilter(bool? value) {
    _vegOnly = value;
    notifyListeners();
  }

  // ── Admin operations ────────────────────────────────────────────────────────

  void addItem({
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    bool isVeg = true,
    int prepTimeMinutes = 15,
  }) {
    final newItem = MenuItem(
      id: _uuid.v4(),
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
      isVeg: isVeg,
      rating: 4.8,
      prepTimeMinutes: prepTimeMinutes,
      isAvailable: true,
    );
    _items.insert(0, newItem);
    notifyListeners();
  }

  void updateItem(MenuItem item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  void toggleAvailability(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(
        isAvailable: !_items[idx].isAvailable,
      );
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }
}
