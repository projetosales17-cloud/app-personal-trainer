import '../models/alimento.dart';
import '../models/anamnese.dart';
import '../models/cardapio.dart';
import 'biblioteca_alimentos_repository.dart';

/// Un "encaje" dentro de una comida: una categoría de alimento, filtrada
/// por la comida (desayuno/almuerzo/…) y, opcionalmente, si es leguminosa
/// (los "frijoles del plato").
class _Encaixe {
  const _Encaixe(this.categoria, {this.leguminosa});
  final CategoriaAlimento categoria;
  final bool? leguminosa;
}

/// Genera un menú a partir de la anamnesis, usando la biblioteca de
/// alimentos. Arma cada comida con un "molde" pensado para ella (el
/// desayuno no lleva arroz; la comida lleva arroz + frijoles + ensalada;
/// la cena es más ligera) y no repite el mismo alimento el mismo día. No
/// sustituye la evaluación de un(a) nutricionista, sobre todo para el
/// perfil posbariátrica (ver briefing del producto).
class GeradorCardapio {
  GeradorCardapio({BibliotecaAlimentosRepository? repositorio})
    : repositorio = repositorio ?? BibliotecaAlimentosRepository();

  final BibliotecaAlimentosRepository repositorio;

  static const duracaoValidadeDias = 30;
  static const _diasDeVariacao = 7;

  /// Objetivos con mayor demanda calórica/proteica reciben una comida
  /// extra (Colación nocturna) — orientación práctica común, no un ajuste
  /// calórico calculado.
  static const _objetivosComCeia = {
    Objetivo.hipertrofia,
    Objetivo.gluteoPernas,
    Objetivo.performanceAtletica,
  };

  // El desayuno alterna entre una versión salada (tortilla/pan + huevo/
  // queso) y una versión "tazón" (lácteo + avena/granola), para no repetir.
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
    _Encaixe(CategoriaAlimento.proteina, leguminosa: true), // los frijoles
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
        'Fase menstrual: presta especial atención a la hidratación y a '
        'alimentos ricos en hierro (ej: carnes magras, legumbres, vegetales '
        'de hoja verde oscura).',
    FaseCiclo.folicular:
        'Fase folicular: fase de más energía — buen momento para mantener '
        'la dieta bien distribuida a lo largo del día.',
    FaseCiclo.ovulacao:
        'Ovulación: mantén la hidratación al día, sobre todo si el '
        'entrenamiento es más intenso en estos días.',
    FaseCiclo.lutea:
        'Fase lútea: es común sentir más hambre o antojo de dulce — '
        'priorizar fuentes de fibra y proteína puede ayudar a mantener la '
        'saciedad.',
  };

  /// Janela em que um parto recente ainda gera uma dica nutricional de
  /// recuperação/amamentação (~6 meses). Regra prática, não médica.
  static const _diasPosParto = 180;

  /// Dicas nutricionais gerais e não-prescritivas por condição hormonal
  /// informada na anamnese (ver briefing do produto: "sem dietas, sem
  /// culpa"). Não mudam a seleção de alimentos.
  static const _observacoesPorCondicao = {
    'SOP (Síndrome de Ovario Poliquístico)':
        'Con SOP, incluir proteína y fibra en todas las comidas y reducir '
        'azúcar y ultraprocesados suele ayudar al control de la glucemia y a '
        'la saciedad. Las grasas buenas (aceite de oliva, aguacate, frutos '
        'secos) también son buenas aliadas.',
    'Menopausia':
        'En la menopausia, prioriza el calcio (lácteos o sustitutos '
        'fortificados, hojas verde oscuro, ajonjolí) y la proteína bien '
        'distribuida en el día para preservar masa ósea y muscular.',
    'SPM / ciclo irregular':
        'En la semana del SPM, los alimentos ricos en magnesio (frutos '
        'secos, cacao 70%+, hojas verdes) y en calcio pueden aliviar la '
        'hinchazón y la irritabilidad. Reducir sal, cafeína y alcohol en '
        'esos días también suele ayudar.',
  };

  static const _observacaoPosParto =
      'En el posparto — y sobre todo si estás amamantando — aumenta la '
      'necesidad de líquidos, hierro, calcio y proteína. Haz comidas '
      'regulares, ten agua cerca y evita dietas restrictivas en esta etapa.';

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
    // No repetir el mismo alimento en dos comidas del mismo día.
    final usadosNoDia = <String>{};

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

    final naoUsados = candidatos.where((a) => !usadosNoDia.contains(a.id)).toList();
    final lista = naoUsados.isNotEmpty ? naoUsados : candidatos;
    if (lista.isEmpty) return null;
    return lista[indiceDia % lista.length];
  }
}
