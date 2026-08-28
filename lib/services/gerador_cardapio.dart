import '../models/alimento.dart';
import '../models/anamnese.dart';
import '../models/cardapio.dart';
import 'biblioteca_alimentos_repository.dart';

/// Um "encaixe" dentro de uma refeição: uma categoria de alimento, filtrada
/// pela refeição (café/almoço/…) e, opcionalmente, se é leguminosa
/// (o "feijão do prato").
class _Encaixe {
  const _Encaixe(this.categoria, {this.leguminosa});
  final CategoriaAlimento categoria;
  final bool? leguminosa;
}

/// Gera um cardápio a partir da anamnese, usando a biblioteca de alimentos.
/// Monta cada refeição a partir de um "molde" pensado pra ela (café da
/// manhã não recebe arroz; almoço tem arroz + feijão + salada; jantar é
/// mais leve), e não repete o mesmo alimento no mesmo dia. Não substitui a
/// avaliação de um(a) nutricionista, especialmente para o perfil
/// pós-bariátrica (ver briefing do produto).
class GeradorCardapio {
  GeradorCardapio({BibliotecaAlimentosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaAlimentosRepository();

  final BibliotecaAlimentosRepository repositorio;

  static const duracaoValidadeDias = 30;
  static const _diasDeVariacao = 7;

  /// Objetivos com maior demanda calórica/proteica ganham uma refeição
  /// extra (Ceia) — orientação prática comum, não um ajuste calórico
  /// calculado.
  static const _objetivosComCeia = {
    Objetivo.hipertrofia,
    Objetivo.gluteoPernas,
    Objetivo.performanceAtletica,
  };

  /// Moldes de refeição: a ordem e a natureza dos encaixes. Filtrados por
  /// `Refeicao` na hora de escolher, então cada item já sai adequado ao
  /// horário.
  // O café alterna entre uma versão salgada (pão/tapioca + ovo/queijo) e
  // uma versão "tigela" (laticínio + aveia/granola), pra não repetir.
  static const _moldeCafeSalgado = [
    _Encaixe(CategoriaAlimento.carboidrato),
    _Encaixe(CategoriaAlimento.proteina, leguminosa: false),
    _Encaixe(CategoriaAlimento.fruta),
  ];

  static const _moldeCafeTigela = [
    _Encaixe(CategoriaAlimento.laticinio),
    _Encaixe(CategoriaAlimento.carboidrato),
    _Encaixe(CategoriaAlimento.fruta),
  ];

  static const _moldeAlmoco = [
    _Encaixe(CategoriaAlimento.proteina, leguminosa: false),
    _Encaixe(CategoriaAlimento.carboidrato),
    _Encaixe(CategoriaAlimento.proteina, leguminosa: true), // o feijão
    _Encaixe(CategoriaAlimento.vegetal),
    _Encaixe(CategoriaAlimento.vegetal),
    _Encaixe(CategoriaAlimento.gordura),
  ];

  static const _moldeLancheLaticinio = [
    _Encaixe(CategoriaAlimento.fruta),
    _Encaixe(CategoriaAlimento.laticinio),
  ];

  static const _moldeLancheGordura = [
    _Encaixe(CategoriaAlimento.fruta),
    _Encaixe(CategoriaAlimento.gordura),
  ];

  static const _moldeJantar = [
    _Encaixe(CategoriaAlimento.proteina, leguminosa: false),
    _Encaixe(CategoriaAlimento.vegetal),
    _Encaixe(CategoriaAlimento.vegetal),
    _Encaixe(CategoriaAlimento.carboidrato),
  ];

  static const _moldeCeia = [
    _Encaixe(CategoriaAlimento.laticinio),
    _Encaixe(CategoriaAlimento.gordura),
  ];

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
        _montarDia(indiceDia, restricoes, incluirCeia),
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

  DiaDeCardapio _montarDia(int indiceDia, List<String> restricoes, bool incluirCeia) {
    // Não repetir o mesmo alimento em duas refeições do mesmo dia.
    final usadosNoDia = <String>{};

    // Café e lanche alternam de formato conforme o dia, pra não cair
    // sempre no mesmo.
    final moldeCafe =
        indiceDia.isEven ? _moldeCafeSalgado : _moldeCafeTigela;
    final moldeLanche =
        indiceDia.isEven ? _moldeLancheLaticinio : _moldeLancheGordura;

    return DiaDeCardapio(
      dia: indiceDia + 1,
      refeicoes: [
        _montarRefeicao(Refeicao.cafeDaManha, moldeCafe, indiceDia, restricoes, usadosNoDia),
        _montarRefeicao(Refeicao.almoco, _moldeAlmoco, indiceDia, restricoes, usadosNoDia),
        _montarRefeicao(Refeicao.lancheTarde, moldeLanche, indiceDia, restricoes, usadosNoDia),
        _montarRefeicao(Refeicao.jantar, _moldeJantar, indiceDia, restricoes, usadosNoDia),
        if (incluirCeia)
          _montarRefeicao(Refeicao.ceia, _moldeCeia, indiceDia, restricoes, usadosNoDia),
      ],
    );
  }

  RefeicaoDoDia _montarRefeicao(
    Refeicao refeicao,
    List<_Encaixe> molde,
    int indiceDia,
    List<String> restricoes,
    Set<String> usadosNoDia,
  ) {
    final alimentos = <Alimento>[];
    for (final encaixe in molde) {
      final escolhido = _escolher(encaixe, refeicao, indiceDia, restricoes, usadosNoDia);
      if (escolhido != null) {
        alimentos.add(escolhido);
        usadosNoDia.add(escolhido.id);
      }
    }
    return RefeicaoDoDia(nome: refeicao.label, alimentos: alimentos);
  }

  Alimento? _escolher(
    _Encaixe encaixe,
    Refeicao refeicao,
    int indiceDia,
    List<String> restricoes,
    Set<String> usadosNoDia,
  ) {
    final candidatos = repositorio.filtrar(
      categoria: encaixe.categoria,
      refeicao: refeicao,
      leguminosa: encaixe.leguminosa,
      restricoesUsuaria: restricoes,
    );

    // Preferir os que ainda não foram usados hoje; se todos já saíram
    // (biblioteca pequena pra alguma restrição), aí sim repete.
    final naoUsados = candidatos.where((a) => !usadosNoDia.contains(a.id)).toList();
    final lista = naoUsados.isNotEmpty ? naoUsados : candidatos;
    if (lista.isEmpty) return null;
    return lista[indiceDia % lista.length];
  }
}
