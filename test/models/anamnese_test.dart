import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/anamnese.dart';

void main() {
  test('toJson/fromJson preserva todos os campos', () {
    final original = Anamnese(
      nome: 'Ana Pérez',
      apelido: 'Aninha',
      idade: 35,
      alturaCm: 165,
      pesoAtualKg: 80,
      pesoDesejadoKg: 65,
      sexo: Sexo.masculino,
      objetivoPrincipal: Objetivo.hipertrofia,
      cirurgiaBariatrica: true,
      tipoCirurgiaBariatrica: 'Bypass gástrico',
      mesesDesdeCirurgia: 18,
      condicaoHormonal: 'Menopausa',
      restricoesAlimentares: ['Lactose', 'Glúten'],
      lesoesLimitacoes: ['Joelho'],
      gruposEvitar: ['ombro', 'biceps'],
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 4,
      regioesPriorizadas: ['Fortalecer core'],
      localTreino: LocalTreino.casa,
      preferenciaTreino: PreferenciaTreino.combinado,
      dataParto: DateTime(2026, 1, 1),
      cicloMenstrualRegular: true,
      dataUltimaMenstruacao: DateTime(2026, 1, 1),
      duracaoCicloDias: 32,
    );

    final reconstruido = Anamnese.fromJson(original.toJson());

    expect(reconstruido.nome, 'Ana Pérez');
    expect(reconstruido.apelido, 'Aninha');
    expect(reconstruido.nomeExibicao, 'Aninha');
    expect(reconstruido.idade, original.idade);
    expect(reconstruido.alturaCm, original.alturaCm);
    expect(reconstruido.pesoAtualKg, original.pesoAtualKg);
    expect(reconstruido.pesoDesejadoKg, original.pesoDesejadoKg);
    expect(reconstruido.sexo, original.sexo);
    expect(reconstruido.objetivoPrincipal, original.objetivoPrincipal);
    expect(reconstruido.cirurgiaBariatrica, original.cirurgiaBariatrica);
    expect(reconstruido.tipoCirurgiaBariatrica, original.tipoCirurgiaBariatrica);
    expect(reconstruido.mesesDesdeCirurgia, original.mesesDesdeCirurgia);
    expect(reconstruido.condicaoHormonal, original.condicaoHormonal);
    expect(reconstruido.restricoesAlimentares, original.restricoesAlimentares);
    expect(reconstruido.lesoesLimitacoes, original.lesoesLimitacoes);
    expect(reconstruido.gruposEvitar, original.gruposEvitar);
    expect(reconstruido.nivelAtividade, original.nivelAtividade);
    expect(reconstruido.frequenciaSemanalDias, original.frequenciaSemanalDias);
    expect(reconstruido.regioesPriorizadas, original.regioesPriorizadas);
    expect(reconstruido.localTreino, original.localTreino);
    expect(reconstruido.preferenciaTreino, original.preferenciaTreino);
    expect(reconstruido.dataParto, original.dataParto);
    expect(reconstruido.cicloMenstrualRegular, original.cicloMenstrualRegular);
    expect(reconstruido.dataUltimaMenstruacao, original.dataUltimaMenstruacao);
    expect(reconstruido.duracaoCicloDias, 32);
  });

  test('fromJson usa valores padrão para campos opcionais ausentes', () {
    final anamnese = Anamnese.fromJson({
      'idade': 25,
      'alturaCm': 160.0,
      'pesoAtualKg': 55.0,
      'objetivoPrincipal': 'tonificacao',
      'nivelAtividade': 'sedentario',
      'frequenciaSemanalDias': 2,
    });

    expect(anamnese.pesoDesejadoKg, isNull);
    expect(anamnese.sexo, Sexo.feminino);
    expect(anamnese.cirurgiaBariatrica, isFalse);
    expect(anamnese.condicaoHormonal, 'Nenhuma');
    expect(anamnese.restricoesAlimentares, isEmpty);
    expect(anamnese.lesoesLimitacoes, isEmpty);
    expect(anamnese.gruposEvitar, isEmpty);
    expect(anamnese.regioesPriorizadas, isEmpty);
    expect(anamnese.localTreino, LocalTreino.academia);
    expect(anamnese.preferenciaTreino, PreferenciaTreino.soMusculacao);
    expect(anamnese.dataParto, isNull);
    expect(anamnese.cicloMenstrualRegular, isTrue);
    expect(anamnese.dataUltimaMenstruacao, isNull);
    expect(anamnese.duracaoCicloDias, isNull);
  });

  test('faseCiclo usa a duração de ciclo informada', () {
    // 18 dias depois da menstruação: já é lútea num ciclo de 28, mas ainda
    // folicular num ciclo de 35 (fase folicular mais longa).
    Anamnese comDuracao(int? dias) => Anamnese(
      idade: 30,
      alturaCm: 165,
      pesoAtualKg: 62,
      objetivoPrincipal: Objetivo.saudeGeral,
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      dataUltimaMenstruacao: DateTime.now().subtract(const Duration(days: 18)),
      duracaoCicloDias: dias,
    );

    expect(comDuracao(null).faseCiclo, FaseCiclo.lutea);
    expect(comDuracao(28).faseCiclo, FaseCiclo.lutea);
    expect(comDuracao(35).faseCiclo, FaseCiclo.folicular);
  });

  test('faseCiclo é null sem data da última menstruação ou com ciclo irregular', () {
    const semData = Anamnese(
      idade: 25,
      alturaCm: 160,
      pesoAtualKg: 55,
      objetivoPrincipal: Objetivo.tonificacao,
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
    );
    expect(semData.faseCiclo, isNull);

    final cicloIrregular = Anamnese(
      idade: 25,
      alturaCm: 160,
      pesoAtualKg: 55,
      objetivoPrincipal: Objetivo.tonificacao,
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      cicloMenstrualRegular: false,
      dataUltimaMenstruacao: DateTime.now(),
    );
    expect(cicloIrregular.faseCiclo, isNull);
  });

  test('faseCiclo calcula a partir da data da última menstruação quando regular', () {
    final anamnese = Anamnese(
      idade: 25,
      alturaCm: 160,
      pesoAtualKg: 55,
      objetivoPrincipal: Objetivo.tonificacao,
      nivelAtividade: NivelAtividade.leve,
      frequenciaSemanalDias: 3,
      dataUltimaMenstruacao: DateTime.now(),
    );
    expect(anamnese.faseCiclo, FaseCiclo.menstrual);
  });

  test('recomendação de preferência de treino por objetivo', () {
    expect(Objetivo.hipertrofia.preferenciaTreinoRecomendada, PreferenciaTreino.soMusculacao);
    expect(Objetivo.emagrecimento.preferenciaTreinoRecomendada, PreferenciaTreino.combinado);
    expect(Objetivo.tonificacao.preferenciaTreinoRecomendada, PreferenciaTreino.combinado);
    expect(Objetivo.performanceAtletica.preferenciaTreinoRecomendada, PreferenciaTreino.combinado);
    expect(Objetivo.saudeGeral.preferenciaTreinoRecomendada, PreferenciaTreino.combinado);
    expect(Objetivo.terceiraIdade.preferenciaTreinoRecomendada, PreferenciaTreino.combinado);
  });
}
