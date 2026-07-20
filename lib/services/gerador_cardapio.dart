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
  static const _objetivosComCeia = {Objetivo.hipertrofia, Objetivo.performanceAtletica};

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
