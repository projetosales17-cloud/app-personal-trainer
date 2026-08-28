import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/registro_carga.dart';
import 'package:app_personal_trainer/saude/progressao_carga.dart';

RegistroCarga _r(String id, int diasAtras, double peso, {int series = 3, int reps = 10}) =>
    RegistroCarga(
      exercicioId: id,
      data: DateTime.now().subtract(Duration(days: diasAtras)),
      pesoKg: peso,
      series: series,
      repeticoes: reps,
    );

void main() {
  group('resumirEvolucao', () {
    test('menos de 2 registros não gera resumo', () {
      expect(resumirEvolucao('agachamento', [_r('agachamento', 0, 20)]), isNull);
      expect(resumirEvolucao('agachamento', const []), isNull);
    });

    test('resume peso inicial, atual, série e semanas', () {
      final evolucao = resumirEvolucao('agachamento', [
        _r('agachamento', 42, 20),
        _r('agachamento', 21, 24),
        _r('agachamento', 0, 30),
        _r('supino', 0, 40), // outro exercício, ignorado
      ])!;

      expect(evolucao.pesos, [20, 24, 30]);
      expect(evolucao.pesoInicial, 20);
      expect(evolucao.pesoAtual, 30);
      expect(evolucao.totalRegistros, 3);
      expect(evolucao.progrediu, isTrue);
      expect(evolucao.ganhoKg, 10);
      expect(evolucao.ganhoPercentual, 50);
      expect(evolucao.semanas, 6);
    });

    test('ordena por data mesmo se vier fora de ordem', () {
      final evolucao = resumirEvolucao('x', [
        _r('x', 0, 30),
        _r('x', 40, 20),
      ])!;
      expect(evolucao.pesoInicial, 20);
      expect(evolucao.pesoAtual, 30);
    });

    test('peso do corpo (0 kg) não quebra o percentual', () {
      final evolucao = resumirEvolucao('prancha', [
        _r('prancha', 20, 0),
        _r('prancha', 0, 0),
      ])!;
      expect(evolucao.ganhoPercentual, 0);
      expect(evolucao.progrediu, isFalse);
    });
  });

  group('resumirTodasAsEvolucoes', () {
    test('um resumo por exercício com histórico, mais recente primeiro', () {
      final lista = resumirTodasAsEvolucoes([
        _r('a', 30, 10),
        _r('a', 20, 12),
        _r('b', 5, 40),
        _r('b', 1, 45),
        _r('c', 0, 5), // só 1 registro -> fora
      ]);
      expect(lista.map((e) => e.exercicioId), ['b', 'a']);
    });
  });

  group('destaqueNovoRecorde', () {
    test('novo peso máximo com repetições mantidas gera destaque', () {
      final msg = destaqueNovoRecorde('agachamento', [
        _r('agachamento', 14, 20, reps: 10),
        _r('agachamento', 7, 22, reps: 10),
        _r('agachamento', 0, 25, reps: 10),
      ]);
      expect(msg, contains('Nuevo récord'));
      expect(msg, contains('25 kg'));
      expect(msg, contains('22 kg'));
    });

    test('peso maior mas com muito menos repetição não conta', () {
      final msg = destaqueNovoRecorde('agachamento', [
        _r('agachamento', 7, 20, reps: 12),
        _r('agachamento', 0, 25, reps: 5),
      ]);
      expect(msg, isNull);
    });

    test('sem novo recorde não gera destaque', () {
      final msg = destaqueNovoRecorde('agachamento', [
        _r('agachamento', 7, 25, reps: 10),
        _r('agachamento', 0, 22, reps: 10),
      ]);
      expect(msg, isNull);
    });

    test('primeiro registro do exercício não gera destaque', () {
      expect(destaqueNovoRecorde('agachamento', [_r('agachamento', 0, 20)]), isNull);
    });
  });
}
