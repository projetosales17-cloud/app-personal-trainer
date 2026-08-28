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
        DiaDeCardapio(
          dia: indiceDia + 1,
          refeicoes: [
            _montarRefeicao('Desayuno', indiceDia, restricoes, const [
              CategoriaAlimento.laticinio,
              CategoriaAlimento.carboidrato,
              CategoriaAlimento.fruta,
            ]),
            _montarRefeicao('Almuerzo', indiceDia, restricoes, const [
              CategoriaAlimento.proteina,
              CategoriaAlimento.carboidrato,
              CategoriaAlimento.vegetal,
              CategoriaAlimento.gordura,
            ]),
            _montarRefeicao('Merienda', indiceDia, restricoes, const [
              CategoriaAlimento.fruta,
              CategoriaAlimento.gordura,
            ]),
            _montarRefeicao('Cena', indiceDia, restricoes, const [
              CategoriaAlimento.proteina,
              CategoriaAlimento.vegetal,
              CategoriaAlimento.carboidrato,
            ]),
            if (incluirCeia)
              _montarRefeicao('Colación nocturna', indiceDia, restricoes, const [
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
