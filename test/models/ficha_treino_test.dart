import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/ficha_treino.dart';

void main() {
  test('expirada é falsa quando validaAte está no futuro', () {
    final ficha = FichaTreino(
      dias: const [],
      geradaEm: DateTime.now(),
      validaAte: DateTime.now().add(const Duration(days: 10)),
    );
    expect(ficha.expirada, isFalse);
  });

  test('expirada é verdadeira quando validaAte já passou', () {
    final ficha = FichaTreino(
      dias: const [],
      geradaEm: DateTime.now().subtract(const Duration(days: 40)),
      validaAte: DateTime.now().subtract(const Duration(days: 10)),
    );
    expect(ficha.expirada, isTrue);
  });

  group('datasPara', () {
    const dia1 = DiaDeTreino(dia: 1, gruposMusculares: [], exercicios: []);
    const dia2 = DiaDeTreino(dia: 2, gruposMusculares: [], exercicios: []);
    const dia3 = DiaDeTreino(dia: 3, gruposMusculares: [], exercicios: []);

    test('retorna vazio para um dia que não pertence à ficha', () {
      final ficha = FichaTreino(
        dias: const [dia1],
        geradaEm: DateTime(2026, 1, 1),
        validaAte: DateTime(2026, 1, 31),
      );
      expect(ficha.datasPara(dia2), isEmpty);
    });

    test('a primeira data do primeiro dia é a data de geração', () {
      final ficha = FichaTreino(
        dias: const [dia1, dia2, dia3],
        geradaEm: DateTime(2026, 1, 5),
        validaAte: DateTime(2026, 1, 31),
      );
      expect(ficha.datasPara(dia1).first, DateTime(2026, 1, 5));
    });

    test('cada dia da ficha tem uma primeira data diferente dentro da semana', () {
      final ficha = FichaTreino(
        dias: const [dia1, dia2, dia3],
        geradaEm: DateTime(2026, 1, 5),
        validaAte: DateTime(2026, 1, 31),
      );
      final primeiras = [
        ficha.datasPara(dia1).first,
        ficha.datasPara(dia2).first,
        ficha.datasPara(dia3).first,
      ];
      expect(primeiras.toSet(), hasLength(3));
      for (final data in primeiras) {
        expect(data.difference(DateTime(2026, 1, 5)).inDays, lessThan(7));
      }
    });

    test('repete semanalmente até a validade, sem passar dela', () {
      final ficha = FichaTreino(
        dias: const [dia1],
        geradaEm: DateTime(2026, 1, 1),
        validaAte: DateTime(2026, 1, 20),
      );
      final datas = ficha.datasPara(dia1);
      expect(datas, isNotEmpty);
      for (final data in datas) {
        expect(data.isAfter(ficha.validaAte), isFalse);
      }
      for (var i = 1; i < datas.length; i++) {
        expect(datas[i].difference(datas[i - 1]).inDays, 7);
      }
    });

    test('com diasDaSemana informado, usa o dia da semana escolhido para cada dia', () {
      final ficha = FichaTreino(
        dias: const [dia1, dia2],
        geradaEm: DateTime(2026, 1, 5), // uma segunda-feira (weekday 1)
        validaAte: DateTime(2026, 1, 26),
      );

      final datasDia1 = ficha.datasPara(dia1, diasDaSemana: [3, 6]); // quarta
      final datasDia2 = ficha.datasPara(dia2, diasDaSemana: [3, 6]); // sábado

      expect(datasDia1, isNotEmpty);
      expect(datasDia1.every((d) => d.weekday == DateTime.wednesday), isTrue);
      expect(datasDia2, isNotEmpty);
      expect(datasDia2.every((d) => d.weekday == DateTime.saturday), isTrue);
    });

    test('com diasDaSemana de tamanho diferente de dias, ignora e usa a distribuição automática', () {
      final ficha = FichaTreino(
        dias: const [dia1, dia2, dia3],
        geradaEm: DateTime(2026, 1, 5),
        validaAte: DateTime(2026, 1, 31),
      );

      final comDiasErrados = ficha.datasPara(dia1, diasDaSemana: [3]);
      final semDias = ficha.datasPara(dia1);

      expect(comDiasErrados, semDias);
    });
  });
}
