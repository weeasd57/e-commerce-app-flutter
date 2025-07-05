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
    final languageProvider = context.read<LanguageProvider>();
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
                  return Consumer2<ThemeProvider, ColorProvider>(
                    builder: (context, themeProvider, colorProvider, child) {
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localization.welcome,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                localization.selectLanguage,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      languageProvider
                                          .changeLanguage(const Locale('en'));
                                      // Stay on the same page, language changed
                                      // _pageController.nextPage(
                                      //     duration: const Duration(milliseconds: 300),
                                      //     curve: Curves.easeIn);
                                    },
                                    child: const Text('English'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      languageProvider
                                          .changeLanguage(const Locale('ar'));
                                      // Stay on the same page, language changed
                                      // _pageController.nextPage(
                                      //     duration: const Duration(milliseconds: 300),
                                      //     curve: Curves.easeIn);
                                    },
                                    child: const Text('العربية'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Theme Mode Selection
                              Text(
                                localization.themeMode,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(localization.lightMode),
                                  Switch(
                                    value: themeProvider.isDarkMode,
                                    onChanged: (value) {
                                      themeProvider.toggleTheme();
                                    },
                                  ),
                                  Text(localization.darkMode),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Gradient Color Selection
                              Text(
                                localization.chooseAppColor,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: colorProvider.gradientOptions
                                    .sublist(0, 4)
                                    .map((option) {
                                  bool isSelected =
                                      colorProvider.selectedColorOption ==
                                          option;
                                  return GestureDetector(
                                    onTap: () {
                                      colorProvider.setColor(option);
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: option.gradientColors!,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.black,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.white)
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Tutorial pages
                  final pageData = tutorialPages[index - 1];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          pageData['image']!,
                          height: 200,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          pageData['title']!,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pageData['description']!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button for tutorial pages
                if (_currentPage > 0 &&
                    _currentPage <
                        tutorialPages.length) // Skip button for tutorial pages
                  TextButton(
                    onPressed: () {
                      _setLandingPageSeen();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const Home()));
                    },
                    child: Text(localization.skip),
                  ),
                // Get Started button on the last page or Next button
                Expanded(
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
                    child: Text(_currentPage < tutorialPages.length
                        ? localization.next
                        : localization.getStarted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _setLandingPageSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('landingPageSeen', true);
  }
}
