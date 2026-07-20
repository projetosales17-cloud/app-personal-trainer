import 'package:flutter/material.dart';

import 'onboarding_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Trainer Online',
      // Paleta e identidade visual ainda não definidas (ver briefing do produto).
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: OnboardingGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
