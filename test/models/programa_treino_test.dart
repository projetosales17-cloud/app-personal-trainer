import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/exercicio.dart';
import 'package:app_personal_trainer/models/programa_treino.dart';

void main() {
  test('precisaCheckin fica verdadeiro depois de ~6 semanas no bloco', () {
    final agora = DateTime(2026, 3, 1);
    final programa = ProgramaTreino(
      iniciadoEm: agora.subtract(const Duration(days: 60)),
      blocoAtual: 2,
      blocoIniciadoEm: agora.subtract(const Duration(days: 45)),
      nivelLiberado: NivelExercicio.iniciante,
    );

    expect(programa.precisaCheckin(agora), isTrue);
    expect(programa.diasParaProximoCheckin(agora), 0);
  });

  test('bloco recém-iniciado ainda não precisa de check-in', () {
    final agora = DateTime(2026, 3, 1);
    final programa = ProgramaTreino(
      iniciadoEm: agora.subtract(const Duration(days: 10)),
      blocoAtual: 1,
      blocoIniciadoEm: agora.subtract(const Duration(days: 10)),
      nivelLiberado: NivelExercicio.iniciante,
    );

    expect(programa.precisaCheckin(agora), isFalse);
    expect(programa.semanasParaProximoCheckin(agora), greaterThan(0));
    expect(programa.semanaAtual(agora), 2);
  });

  test('toJson/fromJson preserva o estado', () {
    final programa = ProgramaTreino(
      iniciadoEm: DateTime(2026, 1, 1),
      blocoAtual: 4,
      blocoIniciadoEm: DateTime(2026, 3, 12),
      nivelLiberado: NivelExercicio.avancado,
    );
    final ida = ProgramaTreino.fromJson(programa.toJson());
    expect(ida.blocoAtual, 4);
    expect(ida.nivelLiberado, NivelExercicio.avancado);
    expect(ida.blocoIniciadoEm, DateTime(2026, 3, 12));
  });
}
