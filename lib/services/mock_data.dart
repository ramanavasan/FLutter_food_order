// lib/services/mock_data.dart
import '../models/menu_item.dart';

class MockData {
  static const List<MenuItem> menuItems = [
    // Meals & Rice
    MenuItem(
      id: 'item-001',
      name: 'South Indian Special Meals',
      description:
          'Steamed Ponni rice, Sambar, Rasam, Kara Kuzhambu, Poriyal, Kootu, Appalam, Curd & Sweet Payasam.',
      price: 130.0,
      category: 'Meals & Rice',
      imageUrl:
          'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.8,
      prepTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item-002',
      name: 'Thalassery Chicken Dum Biryani',
      description:
          'Aromatic Jeerakasala rice slow-cooked with tender spiced chicken, caramelized onions, boiled egg & raita.',
      price: 240.0,
      category: 'Meals & Rice',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
      isVeg: false,
      rating: 4.9,
      prepTimeMinutes: 15,
    ),
    MenuItem(
      id: 'item-003',
      name: 'Hyderabadi Mutton Biryani',
      description:
          'Fragrant basmati rice layered with succulent baby lamb chunks, whole spices, served with Mirchi Ka Salan & raita.',
      price: 320.0,
      category: 'Meals & Rice',
      imageUrl:
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600&auto=format&fit=crop&q=80',
      isVeg: false,
      rating: 4.9,
      prepTimeMinutes: 20,
    ),

    // Starters & Frys
    MenuItem(
      id: 'item-004',
      name: 'Vanjaram Fish Fry (King Fish)',
      description:
          'Fresh coastal Seer fish slice coated with Chettinad masala paste and pan-roasted on an iron tawa with curry leaves.',
      price: 220.0,
      category: 'Starters & Frys',
      imageUrl:
          'https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=600&auto=format&fit=crop&q=80',
      isVeg: false,
      rating: 4.8,
      prepTimeMinutes: 15,
    ),
    MenuItem(
      id: 'item-005',
      name: 'Chicken Chukka Varuval',
      description:
          'Tender bone-in country chicken slow-roasted with shallots, crushed black pepper, garlic, and roasted spices.',
      price: 190.0,
      category: 'Starters & Frys',
      imageUrl:
          'https://images.unsplash.com/photo-1598103442097-8b74394b95c1?w=600&auto=format&fit=crop&q=80',
      isVeg: false,
      rating: 4.7,
      prepTimeMinutes: 15,
    ),
    MenuItem(
      id: 'item-006',
      name: 'Crispy Paneer 65',
      description:
          'Golden fried cottage cheese cubes tossed with fiery red chillies, ginger-garlic, curry leaves, and lemon zest.',
      price: 160.0,
      category: 'Starters & Frys',
      imageUrl:
          'https://images.unsplash.com/photo-1567184109411-b28f21ee097a?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.6,
      prepTimeMinutes: 12,
    ),

    // Breads & Tiffin
    MenuItem(
      id: 'item-007',
      name: 'Malabar Parotta (2 Pcs) with Salna',
      description:
          'Flaky, crispy layered tawa parottas served with rich spicy street-style empty salna & onion raita.',
      price: 60.0,
      category: 'Breads & Tiffin',
      imageUrl:
          'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.8,
      prepTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item-008',
      name: 'Ghee Roast Dosa',
      description:
          'Crispy golden cone dosa roasted with pure desi ghee, served with 3 varieties of chutneys and hot sambar.',
      price: 90.0,
      category: 'Breads & Tiffin',
      imageUrl:
          'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.9,
      prepTimeMinutes: 10,
    ),
    MenuItem(
      id: 'item-009',
      name: 'Button Ghee Idli (14 Pcs)',
      description:
          'Mini bite-sized melt-in-mouth steamed rice cakes soaked in piping hot sambar, drizzled with desi ghee & podi.',
      price: 80.0,
      category: 'Breads & Tiffin',
      imageUrl:
          'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.7,
      prepTimeMinutes: 8,
    ),

    // Curries & Gravies
    MenuItem(
      id: 'item-010',
      name: 'Chettinad Pepper Chicken Gravy',
      description:
          'Traditional Karaikudi style spicy thick curry with freshly ground coriander seeds, peppercorns and fennel.',
      price: 210.0,
      category: 'Curries & Gravies',
      imageUrl:
          'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600&auto=format&fit=crop&q=80',
      isVeg: false,
      rating: 4.8,
      prepTimeMinutes: 18,
    ),
    MenuItem(
      id: 'item-011',
      name: 'Paneer Butter Masala',
      description:
          'Fresh paneer cubes simmered in a silky, mildly sweet and aromatic tomato-cashew creamy gravy with kasuri methi.',
      price: 180.0,
      category: 'Curries & Gravies',
      imageUrl:
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.7,
      prepTimeMinutes: 15,
    ),

    // Beverages & Desserts
    MenuItem(
      id: 'item-012',
      name: 'Degree Filter Coffee',
      description:
          'Authentic Kumbakonam brass davarah-tumbler filter coffee brewed with fresh chicory blend and thick boiled milk.',
      price: 35.0,
      category: 'Beverages & Desserts',
      imageUrl:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.9,
      prepTimeMinutes: 5,
    ),
    MenuItem(
      id: 'item-013',
      name: 'Mango Lassi',
      description:
          'Thick chilled churned yogurt blended with sweet Alphonso mango pulp, saffron strands and crushed pistachios.',
      price: 70.0,
      category: 'Beverages & Desserts',
      imageUrl:
          'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?w=600&auto=format&fit=crop&q=80',
      isVeg: true,
      rating: 4.8,
      prepTimeMinutes: 5,
    ),
  ];

  static const List<String> categories = [
    'All',
    'Meals & Rice',
    'Starters & Frys',
    'Breads & Tiffin',
    'Curries & Gravies',
    'Beverages & Desserts',
  ];
}
