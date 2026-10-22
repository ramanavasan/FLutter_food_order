// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  double get totalAmount =>
      _items.values.fold(0.0, (sum, i) => sum + i.subtotal);

  int quantityOf(String menuItemId) => _items[menuItemId]?.quantity ?? 0;

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity++;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem);
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;
    if (_items[menuItemId]!.quantity > 1) {
      _items[menuItemId]!.quantity--;
    } else {
      _items.remove(menuItemId);
    }
    notifyListeners();
  }

  void deleteItem(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
