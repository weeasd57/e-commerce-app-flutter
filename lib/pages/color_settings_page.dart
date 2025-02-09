import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/color_provider.dart';

class ColorSettingsPage extends StatelessWidget {
  const ColorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تغيير لون التطبيق'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
            ),
            tabs: const [
              Tab(
                child: Text('الألوان الأساسية'),
              ),
              Tab(
                child: Text('التدرجات اللونية'),
              ),
            ],
          ),
        ),
        body: Consumer<ColorProvider>(
          builder: (context, colorProvider, _) {
            return TabBarView(
              children: [
                // Solid Colors Grid
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: colorProvider.solidColorOptions.length,
                  itemBuilder: (context, index) {
                    final option = colorProvider.solidColorOptions[index];
                    final isSelected =
                        colorProvider.selectedColorOption == option;

                    return InkWell(
                      onTap: () {
                        colorProvider.setColor(option);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم تغيير اللون بنجاح'),
                            backgroundColor: option.solidColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: option.solidColor,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                // Gradient Colors Grid
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: colorProvider.gradientOptions.length,
                  itemBuilder: (context, index) {
                    final option = colorProvider.gradientOptions[index];
                    final isSelected =
                        colorProvider.selectedColorOption == option;

                    return InkWell(
                      onTap: () {
                        colorProvider.setColor(option);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم تغيير التدرج اللوني بنجاح'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: option.gradientColors!,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            option.name!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
