import 'checkin_progresso.dart';
import 'exercicio.dart';

/// Decisão do app para a ficha de um bloco: quanto volume, até que nível de
/// exercício, se é semana de deload, quais grupos evitar e uma mensagem de
/// contexto para a usuária. Combina a periodização por número de bloco com
/// o que a usuária respondeu no último check-in de progresso.
class EstrategiaBloco {
  const EstrategiaBloco({
    required this.bloco,
    required this.faseNome,
    required this.faseDescricao,
    required this.volumeModificador,
    required this.tetoNivel,
    required this.deload,
    required this.rotacaoOffset,
    required this.mensagem,
    this.gruposExcluidosExtra = const {},
  });

  final int bloco;
  final String faseNome;
  final String faseDescricao;

  /// Somado ao volume-alvo por grupo do objetivo (pode ser negativo).
  final int volumeModificador;

  /// Nível de exercício mais alto permitido nesta ficha.
  final NivelExercicio tetoNivel;

  final bool deload;

  /// Deslocamento na lista de exercícios candidatos, para não repetir os
  /// mesmos movimentos bloco após bloco.
  final int rotacaoOffset;

  /// Grupos musculares a evitar por causa de dor relatada no check-in.
  final Set<GrupoMuscular> gruposExcluidosExtra;

  /// Frase de contexto mostrada na aba Minha ficha e no fim do check-in.
  final String mensagem;
}

/// Mapeia a região de dor relatada no check-in para o grupo muscular a
/// evitar na ficha. Regiões não reconhecidas não filtram nada.
const _mapaRegiaoDorParaGrupo = {
  'Joelho': GrupoMuscular.perna,
  'Pernas': GrupoMuscular.perna,
  'Glúteo': GrupoMuscular.gluteo,
  'Ombro': GrupoMuscular.ombro,
  'Coluna / lombar': GrupoMuscular.costas,
  'Punho': GrupoMuscular.biceps,
  'Cotovelo': GrupoMuscular.triceps,
  'Abdômen': GrupoMuscular.abdomen,
};

const regioesDorCheckin = [
  'Joelho',
  'Pernas',
  'Glúteo',
  'Ombro',
  'Coluna / lombar',
  'Punho',
  'Cotovelo',
  'Abdômen',
];

NivelExercicio _menorNivel(NivelExercicio a, NivelExercicio b) =>
    a.index <= b.index ? a : b;

/// Calcula a estratégia do bloco que está começando agora. [ultimoCheckin]
/// descreve o bloco que acabou de terminar (pode ser `null` no primeiro
/// bloco). O ajuste de `nivelLiberado` (subir de iniciante para
/// intermediário etc.) é responsabilidade do `ProgramaTreinoRepository` —
/// aqui ele já chega decidido.
EstrategiaBloco calcularEstrategiaBloco({
  required int bloco,
  required NivelExercicio nivelLiberado,
  CheckinProgresso? ultimoCheckin,
}) {
  // Fase base pela periodização (bloco 1 = adaptação; depois ciclo de
  // acúmulo -> intensificação -> deload).
  String faseNome;
  String faseDescricao;
  int volumeModificador;
  NivelExercicio tetoNivel;
  var deload = false;

  if (bloco <= 1) {
    faseNome = 'Bloco de adaptação';
    faseDescricao =
        'Primeiras semanas: aprender bem os movimentos com carga leve.';
    volumeModificador = -1;
    tetoNivel = NivelExercicio.iniciante;
  } else {
    switch ((bloco - 2) % 3) {
      case 0:
        faseNome = 'Bloco de acúmulo';
        faseDescricao =
            'Mais volume: somar trabalho total para gerar adaptação.';
        volumeModificador = 1;
        tetoNivel = nivelLiberado;
      case 1:
        faseNome = 'Bloco de intensificação';
        faseDescricao =
            'Menos volume, cargas mais altas: subir a exigência.';
        volumeModificador = 0;
        tetoNivel = nivelLiberado;
      default:
        faseNome = 'Semana de descarga';
        faseDescricao =
            'Volume reduzido para recuperar e assimilar o que foi treinado.';
        volumeModificador = -1;
        tetoNivel = _menorNivel(nivelLiberado, NivelExercicio.intermediario);
        deload = true;
    }
  }

  // Modulação pelo último check-in.
  var mensagem = faseDescricao;
  final gruposExcluidosExtra = <GrupoMuscular>{};

  if (ultimoCheckin != null) {
    final segurar = ultimoCheckin.dificuldade == DificuldadeTreino.dificilDemais ||
        ultimoCheckin.recuperacao == Recuperacao.muitoCansada ||
        ultimoCheckin.aderencia == AderenciaPercebida.pouco;
    final progredir = ultimoCheckin.dificuldade == DificuldadeTreino.facilDemais &&
        ultimoCheckin.recuperacao == Recuperacao.bemRecuperada &&
        ultimoCheckin.aderencia == AderenciaPercebida.quaseTudo;

    if (segurar) {
      faseNome = 'Semana de ajuste';
      volumeModificador -= 1;
      tetoNivel = NivelExercicio.iniciante;
      deload = true;
      mensagem =
          'Como o bloco anterior foi puxado, este começa mais leve pra você se recuperar bem.';
    } else if (progredir) {
      volumeModificador += 1;
      tetoNivel = nivelLiberado;
      mensagem =
          'Como o treino ficou fácil e você está bem recuperada, este bloco sobe o volume e a exigência.';
    }

    if (ultimoCheckin.dorNova) {
      final grupo = _mapaRegiaoDorParaGrupo[ultimoCheckin.regiaoDorNova];
      if (grupo != null) gruposExcluidosExtra.add(grupo);
      mensagem =
          '$mensagem Evitamos exercícios da região onde você sentiu dor — se persistir, procure um profissional de saúde.';
    }
  }

  return EstrategiaBloco(
    bloco: bloco,
    faseNome: faseNome,
    faseDescricao: faseDescricao,
    volumeModificador: volumeModificador,
    tetoNivel: tetoNivel,
    deload: deload,
    rotacaoOffset: bloco - 1,
    gruposExcluidosExtra: gruposExcluidosExtra,
    mensagem: mensagem,
  );
}
