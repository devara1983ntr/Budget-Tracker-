import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Transactions',
      route: '/transactions',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Reports',
      route: '/reports',
    ),
    NavigationItem(
      icon: Icons.savings_outlined,
      activeIcon: Icons.savings,
      label: 'Budgets',
      route: '/budgets',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    final index = _navigationItems.indexWhere((item) => item.route == location);
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) {
          final isSelected = _navigationItems.indexOf(item) == _currentIndex;
          return BottomNavigationBarItem(
            icon: Icon(isSelected ? item.activeIcon : item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      context.go(_navigationItems[index].route);
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}