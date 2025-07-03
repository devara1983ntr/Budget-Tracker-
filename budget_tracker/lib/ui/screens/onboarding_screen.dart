import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Track Your Expenses',
      subtitle: 'Monitor every penny with smart categorization and detailed insights',
      icon: Icons.pie_chart,
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'Set Budgets & Goals',
      subtitle: 'Create budgets and savings goals to stay on track with your financial plans',
      icon: Icons.savings,
      color: const Color(0xFF3B82F6),
    ),
    OnboardingPage(
      title: 'Analyze & Improve',
      subtitle: 'Get detailed reports and insights to make better financial decisions',
      icon: Icons.analytics,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicators
            _buildPageIndicators(),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            _buildNavigationButtons(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _pages[_currentPage].color
                : _pages[_currentPage].color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Previous button
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
            ),
          
          if (_currentPage > 0) const SizedBox(width: 16),
          
          // Next/Get Started button
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _completeOnboarding
                  : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pages[_currentPage].color,
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, false);
    
    if (mounted) {
      context.go('/security-setup');
    }
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}