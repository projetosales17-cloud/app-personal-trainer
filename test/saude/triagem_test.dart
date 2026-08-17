import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/saude/triagem.dart';

void main() {
  test('classificarPressaoArterial', () {
    expect(classificarPressaoArterial(110, 70), 'Normal');
    expect(classificarPressaoArterial(125, 70), 'Presión elevada');
    expect(classificarPressaoArterial(132, 82), 'Hipertensión etapa 1');
    expect(classificarPressaoArterial(150, 95), 'Hipertensión etapa 2');
    expect(classificarPressaoArterial(185, 125), 'Crisis hipertensiva');
    expect(classificarPressaoArterial(85, 55), 'Hipotensión');
  });

  test('classificarPressaoArterial com valores inválidos lança ArgumentError', () {
    expect(() => classificarPressaoArterial(0, 70), throwsArgumentError);
  });

  test('verificarAlertaPressaoArterial', () {
    expect(verificarAlertaPressaoArterial('Normal'), isNull);
    expect(verificarAlertaPressaoArterial('Hipotensión'), isNotNull);
    expect(verificarAlertaPressaoArterial('Crisis hipertensiva'), contains('inmediato'));
  });

  test('triagemParQ sem fatores de risco', () {
    expect(triagemParQ({}), isEmpty);
  });

  test('triagemParQ com um fator de risco', () {
    expect(triagemParQ({'dorPeitoAtividade': true}), hasLength(1));
  });

  test('triagemParQ com múltiplos fatores', () {
    final resultado = triagemParQ({
      'problemaCardiaco': true,
      'tonturaDesequilibrio': true,
      'outroMotivo': false,
    });
    expect(resultado, hasLength(2));
  });

  test('avaliarLiberacaoAtividadeFisica liberado', () {
    final resultado = avaliarLiberacaoAtividadeFisica({});
    expect(resultado.liberado, isTrue);
    expect(resultado.alertas, isEmpty);
  });

  test('avaliarLiberacaoAtividadeFisica não liberado', () {
    final resultado = avaliarLiberacaoAtividadeFisica({'medicamentoPressaoCoracao': true});
    expect(resultado.liberado, isFalse);
    expect(resultado.alertas, hasLength(1));
  });
}
