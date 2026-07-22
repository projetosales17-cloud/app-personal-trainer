import 'package:flutter/material.dart';

import 'screens/onboarding/onboarding_flow.dart';
import 'services/anamnese_repository.dart';
import 'services/auth_repository.dart';
import 'widgets/main_navigation.dart';

/// Decide, na abertura do app, se mostra o onboarding (primeira vez) ou
/// direto a navegação principal (anamnese já preenchida anteriormente).
class OnboardingGate extends StatefulWidget {
  OnboardingGate({super.key, AnamneseRepository? repositorio, AuthRepository? authRepositorio})
    : repositorio = repositorio ?? AnamneseRepository(),
      authRepositorio = authRepositorio ?? AuthRepository();

  final AnamneseRepository repositorio;
  final AuthRepository authRepositorio;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  late Future<bool> _onboardingConcluido;

  @override
  void initState() {
    super.initState();
    _onboardingConcluido = widget.repositorio.onboardingConcluido();
  }

  void _concluirOnboarding() {
    setState(() => _onboardingConcluido = Future.value(true));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingConcluido,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return MainNavigation(authRepositorio: widget.authRepositorio);
        }
        return OnboardingFlow(
          repositorio: widget.repositorio,
          onConcluido: _concluirOnboarding,
        );
      },
    );
  }
}
