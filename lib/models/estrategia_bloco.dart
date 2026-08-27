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
  'Rodilla': GrupoMuscular.perna,
  'Piernas': GrupoMuscular.perna,
  'Glúteo': GrupoMuscular.gluteo,
  'Hombro': GrupoMuscular.ombro,
  'Espalda / lumbar': GrupoMuscular.costas,
  'Muñeca': GrupoMuscular.biceps,
  'Codo': GrupoMuscular.triceps,
  'Abdomen': GrupoMuscular.abdomen,
};

const regioesDorCheckin = [
  'Rodilla',
  'Piernas',
  'Glúteo',
  'Hombro',
  'Espalda / lumbar',
  'Muñeca',
  'Codo',
  'Abdomen',
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
    faseNome = 'Bloque de adaptación';
    faseDescricao =
        'Primeras semanas: aprender bien los movimientos con carga ligera.';
    volumeModificador = -1;
    tetoNivel = NivelExercicio.iniciante;
  } else {
    switch ((bloco - 2) % 3) {
      case 0:
        faseNome = 'Bloque de acumulación';
        faseDescricao =
            'Más volumen: sumar trabajo total para generar adaptación.';
        volumeModificador = 1;
        tetoNivel = nivelLiberado;
      case 1:
        faseNome = 'Bloque de intensificación';
        faseDescricao =
            'Menos volumen, cargas más altas: subir la exigencia.';
        volumeModificador = 0;
        tetoNivel = nivelLiberado;
      default:
        faseNome = 'Semana de descarga';
        faseDescricao =
            'Volumen reducido para recuperar y asimilar lo entrenado.';
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
          'Como el bloque anterior fue exigente, este arranca más ligero para que te recuperes bien.';
    } else if (progredir) {
      volumeModificador += 1;
      tetoNivel = nivelLiberado;
      mensagem =
          'Como el entrenamiento te resultó fácil y estás bien recuperada, este bloque sube el volumen y la exigencia.';
    }

    if (ultimoCheckin.dorNova) {
      final grupo = _mapaRegiaoDorParaGrupo[ultimoCheckin.regiaoDorNova];
      if (grupo != null) gruposExcluidosExtra.add(grupo);
      mensagem =
          '$mensagem Evitamos ejercicios de la zona donde sentiste dolor — si persiste, consulta a un profesional de salud.';
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
