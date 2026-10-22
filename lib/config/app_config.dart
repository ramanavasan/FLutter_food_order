// lib/config/app_config.dart
import 'package:flutter/foundation.dart';

class RestaurantConfig extends ChangeNotifier {
  String _hotelName = 'Spice Garden & Dhaba';
  String _tagline = 'Authentic South Indian & Multi-Cuisine Delicacies';
  String _location = 'Main Road, Near Bus Stand, Thanjavur / Orathanadu';
  String _whatsappNumber = '918870804734'; // International format without +
  final String _currency = '₹';

  String get hotelName => _hotelName;
  String get tagline => _tagline;
  String get location => _location;
  String get whatsappNumber => _whatsappNumber;
  String get currency => _currency;

  void updateSettings({
    String? hotelName,
    String? tagline,
    String? location,
    String? whatsappNumber,
  }) {
    if (hotelName != null && hotelName.isNotEmpty) _hotelName = hotelName;
    if (tagline != null) _tagline = tagline;
    if (location != null) _location = location;
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      _whatsappNumber = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    }
    notifyListeners();
  }
}

class AppConfig {
  static const String appName = 'Spice Garden & Dhaba';
  static const String restaurantTagline = 'Authentic Flavours • Fresh • Fast';
  static const String defaultLocation = 'Main Road, Orathanadu, TN';
  static const String defaultWhatsapp = '918870804734';
  
  // Supabase placeholders
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
