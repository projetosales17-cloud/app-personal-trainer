import '../models/alimento.dart';
import '../models/anamnese.dart';
import '../models/cardapio.dart';
import 'biblioteca_alimentos_repository.dart';

/// Gera um cardápio a partir da anamnese, usando a biblioteca de alimentos.
/// É uma primeira versão simples de personalização — não substitui a
/// avaliação de um(a) nutricionista, especialmente para o perfil
/// pós-bariátrica (ver briefing do produto: a trilha bariátrica precisa de
/// validação profissional antes de virar conteúdo real, então não recebe
/// nenhuma regra especial aqui).
class GeradorCardapio {
  GeradorCardapio({BibliotecaAlimentosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaAlimentosRepository();

  final BibliotecaAlimentosRepository repositorio;

  static const duracaoValidadeDias = 30;
  static const _diasDeVariacao = 3;

  /// Objetivos com maior demanda calórica/proteica ganham uma refeição
  /// extra (Ceia) — orientação prática comum, não um ajuste calórico
  /// calculado.
  static const _objetivosComCeia = {
    Objetivo.hipertrofia,
    Objetivo.gluteoPernas,
    Objetivo.performanceAtletica,
  };

  /// Dicas nutricionais gerais e não-prescritivas por fase do ciclo (ver
  /// briefing do produto) — não muda a seleção de alimentos, só complementa
  /// com uma sugestão de atenção prática.
  static const _observacoesPorFase = {
    FaseCiclo.menstrual:
        'Fase menstrual: dê atenção especial à hidratação e a alimentos '
        'ricos em ferro (ex: carnes magras, leguminosas, vegetais escuros).',
    FaseCiclo.folicular:
        'Fase folicular: fase de mais energia — bom momento para manter a '
        'dieta bem distribuída ao longo do dia.',
    FaseCiclo.ovulacao:
        'Ovulação: mantenha a hidratação em dia, especialmente se o treino '
        'estiver mais intenso nesses dias.',
    FaseCiclo.lutea:
        'Fase lútea: é comum sentir mais fome ou vontade de doce — priorizar '
        'fontes de fibra e proteína pode ajudar a manter a saciedade.',
  };

  /// Janela em que um parto recente ainda gera uma dica nutricional de
  /// recuperação/amamentação (~6 meses). Regra prática, não médica.
  static const _diasPosParto = 180;

  /// Dicas nutricionais gerais e não-prescritivas por condição hormonal
  /// informada na anamnese (ver briefing do produto: "sem dietas, sem
  /// culpa"). Não mudam a seleção de alimentos — são orientações de
  /// equilíbrio mostradas junto ao cardápio.
  static const _observacoesPorCondicao = {
    'SOP (Síndrome do Ovário Policístico)':
        'Com SOP, incluir proteína e fibras em todas as refeições e reduzir '
        'açúcar e ultraprocessados costuma ajudar no controle da glicemia e '
        'na saciedade. Gorduras boas (azeite, abacate, castanhas) também são '
        'boas aliadas.',
    'Menopausa':
        'Na menopausa, capriche em cálcio (laticínios ou substitutos '
        'fortificados, folhas verde-escuras, gergelim) e em proteína bem '
        'distribuída ao longo do dia para preservar massa óssea e muscular.',
    'TPM / ciclo irregular':
        'Na semana da TPM, alimentos ricos em magnésio (castanhas, cacau '
        '70%+, folhas verdes) e em cálcio podem aliviar inchaço e '
        'irritabilidade. Reduzir sal, cafeína e álcool nesses dias também '
        'costuma ajudar.',
  };

  static const _observacaoPosParto =
      'No pós-parto — e especialmente se você amamenta — a necessidade de '
      'líquidos, ferro, cálcio e proteína aumenta. Faça refeições regulares, '
      'mantenha água por perto e evite dietas restritivas nessa fase.';

  List<String> _observacoesFoco(Anamnese anamnese) {
    final observacoes = <String>[];
    final porCondicao = _observacoesPorCondicao[anamnese.condicaoHormonal];
    if (porCondicao != null) observacoes.add(porCondicao);

    final parto = anamnese.dataParto;
    if (parto != null && DateTime.now().difference(parto).inDays < _diasPosParto) {
      observacoes.add(_observacaoPosParto);
    }
    return observacoes;
  }

  Cardapio gerar(Anamnese anamnese) {
    final restricoes = anamnese.restricoesAlimentares;
    final incluirCeia = _objetivosComCeia.contains(anamnese.objetivoPrincipal);

    final dias = <DiaDeCardapio>[
      for (var indiceDia = 0; indiceDia < _diasDeVariacao; indiceDia++)
        DiaDeCardapio(
          dia: indiceDia + 1,
          refeicoes: [
            _montarRefeicao('Café da manhã', indiceDia, restricoes, const [
              CategoriaAlimento.laticinio,
              CategoriaAlimento.carboidrato,
              CategoriaAlimento.fruta,
            ]),
            _montarRefeicao('Almoço', indiceDia, restricoes, const [
              CategoriaAlimento.proteina,
              CategoriaAlimento.carboidrato,
              CategoriaAlimento.vegetal,
              CategoriaAlimento.gordura,
            ]),
            _montarRefeicao('Lanche da tarde', indiceDia, restricoes, const [
              CategoriaAlimento.fruta,
              CategoriaAlimento.gordura,
            ]),
            _montarRefeicao('Jantar', indiceDia, restricoes, const [
              CategoriaAlimento.proteina,
              CategoriaAlimento.vegetal,
              CategoriaAlimento.carboidrato,
            ]),
            if (incluirCeia)
              _montarRefeicao('Ceia', indiceDia, restricoes, const [
                CategoriaAlimento.proteina,
                CategoriaAlimento.laticinio,
              ]),
          ],
        ),
    ];

    final geradaEm = DateTime.now();
    return Cardapio(
      dias: dias,
      geradaEm: geradaEm,
      validaAte: geradaEm.add(const Duration(days: duracaoValidadeDias)),
      observacaoCiclo: _observacoesPorFase[anamnese.faseCiclo],
      observacoesFoco: _observacoesFoco(anamnese),
    );
  }

  RefeicaoDoDia _montarRefeicao(
    String nome,
    int indiceDia,
    List<String> restricoes,
    List<CategoriaAlimento> categorias,
  ) {
    final alimentos = [
      for (final categoria in categorias) _escolherAlimento(categoria, indiceDia, restricoes),
    ].whereType<Alimento>().toList();
    return RefeicaoDoDia(nome: nome, alimentos: alimentos);
  }

  Alimento? _escolherAlimento(CategoriaAlimento categoria, int indiceDia, List<String> restricoes) {
    final candidatos = repositorio.filtrar(categoria: categoria, restricoesUsuaria: restricoes);
    if (candidatos.isEmpty) return null;
    return candidatos[indiceDia % candidatos.length];
  }
}
