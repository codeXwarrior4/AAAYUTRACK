// lib/screens/onboarding_flow.dart
import 'package:flutter/material.dart';

class OnboardingFlow extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _page = 0;

  // step 1
  String? _profession;

  // step 2 (many choices)
  final Map<String, bool> _conditions = {
    'Diabetes': false,
    'Hypertension': false,
    'Heart Disease': false,
    'Asthma': false,
    'Thyroid': false,
    'Arthritis': false,
    'Obesity': false,
  };

  void _next() {
    if (_page < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.ease,
      );
    } else {
      // finish onboarding
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Widget _buildCard({required Widget child}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF0E9E89);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Onboarding'),
        centerTitle: true,
        backgroundColor: teal,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 18),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      // Step 1
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Help us personalize your health experience',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'What best describes you?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...[
                              'Working Professional',
                              'Retired',
                              'Student',
                              'Homemaker',
                              'Self-employed',
                              'Unemployed',
                            ].map((p) {
                              return RadioListTile<String>(
                                value: p,
                                groupValue: _profession,
                                title: Text(p),
                                onChanged: (v) =>
                                    setState(() => _profession = v),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Step 2
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select any chronic conditions you have:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView(
                                children: _conditions.keys.map((k) {
                                  return CheckboxListTile(
                                    title: Text(k),
                                    value: _conditions[k],
                                    onChanged: (v) => setState(
                                      () => _conditions[k] = v ?? false,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // bottom actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _page == 0
                          ? () => Navigator.pop(context)
                          : () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                      child: const Text('Back'),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_page + 1}/2',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          child: Text(_page == 1 ? 'Finish' : 'Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
