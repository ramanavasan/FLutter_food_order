// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_theme.dart';
import 'menu_screen.dart';
import 'kitchen_dashboard_screen.dart';
import 'admin_panel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _pages = const [
    MenuScreen(),
    KitchenDashboardScreen(),
    AdminPanelScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          // Desktop & Tablet Navigation Rail layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
                  selectedLabelTextStyle: GoogleFonts.outfit(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelTextStyle: GoogleFonts.outfit(
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.restaurant_menu_outlined),
                      selectedIcon: Icon(
                        Icons.restaurant_menu,
                        color: AppTheme.primary,
                      ),
                      label: Text('Menu'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_fire_department_outlined),
                      selectedIcon: Icon(
                        Icons.local_fire_department,
                        color: AppTheme.primary,
                      ),
                      label: Text('Kitchen'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      selectedIcon: Icon(
                        Icons.admin_panel_settings,
                        color: AppTheme.primary,
                      ),
                      label: Text('Admin'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Bottom Navigation Bar layout
        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.white,
            indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.primary,
                ),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_fire_department_outlined),
                selectedIcon: Icon(
                  Icons.local_fire_department,
                  color: AppTheme.primary,
                ),
                label: 'Kitchen',
              ),
              NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.primary,
                ),
                label: 'Admin',
              ),
            ],
          ),
        );
      },
    );
  }
}
