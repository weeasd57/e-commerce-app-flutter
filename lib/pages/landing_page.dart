import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/main.dart'; // Import Home from main.dart
// For animations
import 'package:ecommerce/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:ecommerce/providers/color_provider.dart'; // Import ColorProvider
// Import ColorOption

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getTutorialPages(AppLocalizations localization) {
    return [
      {
        'image':
            'assets/images/logo.png', // Placeholder, replace with actual asset
        'title': localization.tutorialTitle1,
        'description': localization.tutorialDescription1,
      },
      {
        'image':
            'assets/images/google_logo.png', // Placeholder, replace with actual asset
        'title': localization.tutorialTitle2,
        'description': localization.tutorialDescription2,
      },
      {
        'image':
            'assets/images/logo.png', // Placeholder, replace with actual asset
        'title': localization.tutorialTitle3,
        'description': localization.tutorialDescription3,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final tutorialPages = _getTutorialPages(localization);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: tutorialPages.length + 1, // +1 for language selection
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Language, Theme, and Color selection page
                  return Consumer3<ThemeProvider, ColorProvider,
                      LanguageProvider>(
                    builder: (context, themeProvider, colorProvider,
                        languageProvider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              themeProvider.isDarkMode
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFFF8F9FA),
                              themeProvider.isDarkMode
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).padding.top -
                                    MediaQuery.of(context).padding.bottom,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width > 600
                                          ? 48.0
                                          : 24.0,
                                  vertical: 24.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // App Icon
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: colorProvider.selectedColorOption
                                                ?.solidColor ??
                                            Colors.blue,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (colorProvider
                                                        .selectedColorOption
                                                        ?.solidColor ??
                                                    Colors.blue)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Welcome text
                                    Text(
                                      localization.welcome,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      languageProvider.locale.languageCode ==
                                              'ar'
                                          ? 'اختر تفضيلاتك لتخصيص تجربة التسوق'
                                          : 'Choose your preferences to customize your shopping experience',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 48),

                                    // Language selection card
                                    _buildSettingCard(
                                      context,
                                      title: localization.selectLanguage,
                                      icon: Icons.language,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildLanguageButton(
                                            'English',
                                            const Locale('en'),
                                            languageProvider,
                                          ),
                                          _buildLanguageButton(
                                            'العربية',
                                            const Locale('ar'),
                                            languageProvider,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Theme selection card
                                    _buildSettingCard(
                                      context,
                                      title: localization.themeMode,
                                      icon: themeProvider.isDarkMode
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            themeProvider.isDarkMode
                                                ? localization.darkMode
                                                : localization.lightMode,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          Switch(
                                            value: themeProvider.isDarkMode,
                                            onChanged: (value) {
                                              themeProvider.toggleTheme();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Color selection card
                                    _buildSettingCard(
                                      context,
                                      title: localization.chooseAppColor,
                                      icon: Icons.palette,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: colorProvider.gradientOptions
                                            .sublist(0, 6)
                                            .map((option) {
                                          bool isSelected = colorProvider
                                                  .selectedColorOption ==
                                              option;
                                          return GestureDetector(
                                            onTap: () {
                                              colorProvider.setColor(option);
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: option
                                                            .gradientColors !=
                                                        null
                                                    ? LinearGradient(
                                                        colors: option
                                                            .gradientColors!,
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      )
                                                    : null,
                                                color: option.gradientColors ==
                                                        null
                                                    ? option.solidColor
                                                    : null,
                                                shape: BoxShape.circle,
                                                border: isSelected
                                                    ? Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        width: 3,
                                                      )
                                                    : Border.all(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.3),
                                                        width: 1,
                                                      ),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: (option
                                                                      .solidColor ??
                                                                  option
                                                                      .gradientColors!
                                                                      .first)
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 24,
                                                    )
                                                  : null,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Tutorial pages - Responsive design
                  final pageData = tutorialPages[index - 1];
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;
                  final isSmallScreen = screenWidth < 600;

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24.0 : 48.0,
                              vertical: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Responsive image container
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        isSmallScreen ? screenWidth * 0.7 : 300,
                                    maxHeight: isSmallScreen ? 180 : 250,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          pageData['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: isSmallScreen ? 60 : 80,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 24 : 40),

                                // Responsive title
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 0 : 20,
                                  ),
                                  child: Text(
                                    pageData['title']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: isSmallScreen ? 24 : 28,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 16 : 24),

                                // Responsive description
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 0 : 40,
                                  ),
                                  child: Text(
                                    pageData['description']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          height: 1.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                SizedBox(height: isSmallScreen ? 24 : 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          // Page indicators
          Visibility(
            visible:
                _currentPage > 0, // Hide indicators on language selection page
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tutorialPages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 10,
                  width: _currentPage == index + 1 ? 30 : 10,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: _currentPage == index + 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 600
                    ? 600
                    : double.infinity,
              ),
              margin: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width > 600 ? 48.0 : 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button for tutorial pages
                  if (_currentPage > 0 && _currentPage < tutorialPages.length)
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          _setLandingPageSeen();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const Home()));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localization.skip,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? 16
                                : 18,
                          ),
                        ),
                      ),
                    ),

                  if (_currentPage > 0 && _currentPage < tutorialPages.length)
                    const SizedBox(width: 16),

                  // Get Started button on the last page or Next button
                  Expanded(
                    flex:
                        _currentPage > 0 && _currentPage < tutorialPages.length
                            ? 3
                            : 1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < tutorialPages.length) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          // Last page, navigate to Home
                          _setLandingPageSeen();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const Home()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical:
                              MediaQuery.of(context).size.width < 600 ? 16 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage < tutorialPages.length
                            ? localization.next
                            : localization.getStarted,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 600 ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _setLandingPageSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('landingPageSeen', true);
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    String text,
    Locale locale,
    LanguageProvider languageProvider,
  ) {
    final isSelected = languageProvider.locale == locale;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: () {
            languageProvider.changeLanguage(locale);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
