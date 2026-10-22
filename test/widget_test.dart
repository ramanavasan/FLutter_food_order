// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:food_order/models/menu_item.dart';
import 'package:food_order/providers/cart_provider.dart';
import 'package:food_order/providers/orders_provider.dart';
import 'package:food_order/providers/menu_provider.dart';

void main() {
  group('CartProvider tests', () {
    test('add and remove items from cart', () {
      final cart = CartProvider();
      const item = MenuItem(
        id: '1',
        name: 'Dosa',
        description: 'Crispy dosa',
        price: 70.0,
        category: 'Breakfast',
      );

      cart.addItem(item);
      expect(cart.itemCount, 1);
      expect(cart.totalAmount, 70.0);

      cart.addItem(item);
      expect(cart.itemCount, 2);
      expect(cart.totalAmount, 140.0);

      cart.removeItem(item.id);
      expect(cart.itemCount, 1);

      cart.removeItem(item.id);
      expect(cart.itemCount, 0);
      expect(cart.items.isEmpty, isTrue);
    });
  });

  group('OrdersProvider tests', () {
    test('place order and calculate kitchen summary', () async {
      final ordersProvider = OrdersProvider();
      const item = MenuItem(
        id: '1',
        name: 'Dosa',
        description: 'Crispy dosa',
        price: 70.0,
        category: 'Breakfast',
      );

      final cart = CartProvider();
      cart.addItem(item);
      cart.addItem(item);

      final order = await ordersProvider.placeOrder(
        customerName: 'Alice',
        tableNumber: '4',
        isTakeaway: false,
        cartItems: cart.items,
      );

      expect(order.customerName, 'Alice');
      expect(order.tableNumber, '4');
      expect(order.items.length, 1);
      expect(order.items.first.quantity, 2);
      expect(ordersProvider.activeOrders.length, 1);
      expect(ordersProvider.totalActiveItems, 2);
    });
  });

  group('MenuProvider tests', () {
    test('add, search, toggle availability and filter menu items', () {
      final menu = MenuProvider();
      final initialCount = menu.allItems.length;

      menu.addItem(
        name: 'Special Mutton Sukka',
        description: 'Chettinad spiced tender mutton',
        price: 280.0,
        category: 'Starters & Frys',
        isVeg: false,
      );

      expect(menu.allItems.length, initialCount + 1);

      // Search
      menu.setSearchQuery('sukka');
      expect(menu.filteredItems.length, 1);
      expect(menu.filteredItems.first.name, 'Special Mutton Sukka');

      // Reset search
      menu.setSearchQuery('');

      // Toggle availability
      final addedId = menu.allItems.first.id;
      expect(menu.allItems.first.isAvailable, isTrue);
      menu.toggleAvailability(addedId);
      expect(menu.allItems.first.isAvailable, isFalse);
    });
  });
}
