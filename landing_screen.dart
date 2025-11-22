// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../localization.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t =
        AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'))
          ..load();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7AD0E3), Color(0xFF72C3D9), Color(0xFF66B9D0)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Lottie animation (make sure asset exists)
              Lottie.asset("assets/animations/health.json", height: 220),
              const SizedBox(height: 20),
              Text(
                t.t('appName', 'AayuTrack'),
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(22)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.verified, color: Colors.yellow, size: 20),
                  const SizedBox(width: 6),
                  Text(t.t('trustedUsers', 'Trusted by thousands of users'),
                      style: const TextStyle(color: Colors.white)),
                ]),
              ),
              const SizedBox(height: 20),
              Text(t.t('quote', 'Your health is your real wealth.'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/login"),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4)),
                      ]),
                  child: Text(t.t('getStarted', 'Get Started'),
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/login"),
                    child: Text(t.t('login', 'Login'),
                        style: const TextStyle(color: Colors.white))),
                const Text("|", style: TextStyle(color: Colors.white)),
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, "/signup"),
                    child: Text(t.t('register', 'Register'),
                        style: const TextStyle(color: Colors.white))),
              ]),
              const SizedBox(height: 20),
              _featureCard(
                  icon: Icons.auto_graph,
                  title: t.t('trackProgress', 'Track Your Progress'),
                  subtitle: t.t('trackProgressDesc',
                      'Monitor daily tasks and visualize your wellness journey.')),
              _featureCard(
                  icon: Icons.psychology,
                  title: t.t('aiRecommendations', 'AI Recommendations'),
                  subtitle: t.t('aiRecommendationsDesc',
                      'Personalized suggestions from your AI wellness guide.')),
              _featureCard(
                  icon: Icons.emoji_events,
                  title: t.t('gamifiedExperience', 'Gamified Experience'),
                  subtitle: t.t('gamifiedExperienceDesc',
                      'Achieve health goals through fun challenges and rewards.')),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        )
      ]),
    );
  }
}
