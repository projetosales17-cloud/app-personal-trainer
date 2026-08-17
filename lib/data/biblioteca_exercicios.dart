import '../models/exercicio.dart';

/// Biblioteca v1 de exercícios: cerca de 6 por grupo muscular, como ponto
/// de partida (ver briefing do produto — a expansão é esperada em versões
/// futuras).
const bibliotecaExercicios = <Exercicio>[
  // Pecho
  Exercicio(
    id: 'flexao-de-braco',
    nome: 'Flexión de brazos',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Con las manos apoyadas en el piso, al ancho de los hombros, baja el '
        'cuerpo manteniendo el core contraído y empuja hacia arriba hasta estirar los brazos.',
    caminhoImagem: 'assets/personagem/flexao-de-braco.jpg',
  ),
  Exercicio(
    id: 'flexao-pes-elevados',
    nome: 'Flexión con pies elevados',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.ombro, GrupoMuscular.triceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.banco,
    instrucoes:
        'Apoya los pies en un banco y las manos en el piso. Haz la flexión '
        'de forma normal: la inclinación aumenta la exigencia en la parte superior del pecho.',
    caminhoImagem: 'assets/personagem/flexao-pes-elevados.jpg',
  ),
  Exercicio(
    id: 'supino-reto-halteres',
    nome: 'Press de banca plano con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Acostada en un banco, empuja las mancuernas hacia arriba hasta '
        'estirar los brazos, luego baja de forma controlada hasta la altura del pecho.',
    caminhoImagem: 'assets/personagem/supino-reto-halteres.jpg',
  ),
  Exercicio(
    id: 'supino-reto-barra',
    nome: 'Press de banca plano con barra',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Acostada en un banco, sujeta la barra un poco más abierta que el '
        'ancho de los hombros y baja hasta tocar levemente el pecho, luego empuja hacia arriba.',
    caminhoImagem: 'assets/personagem/supino-reto-barra.jpg',
  ),
  Exercicio(
    id: 'crucifixo-halteres',
    nome: 'Aperturas con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Acostada en un banco, con los brazos ligeramente flexionados, abre '
        'las mancuernas hacia los lados hasta sentir el estiramiento en el pecho y regresa de forma controlada.',
    caminhoImagem: 'assets/personagem/crucifixo-halteres.jpg',
  ),
  Exercicio(
    id: 'crossover-cabo',
    nome: 'Cruce de poleas',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Con un cable en cada mano, jálalos hacia el frente del cuerpo en '
        'un movimiento de arco, contrayendo el pecho al final del recorrido.',
    caminhoImagem: 'assets/personagem/crossover-cabo.jpg',
  ),
  Exercicio(
    id: 'crucifixo-elastico',
    nome: 'Aperturas con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.emagrecimento],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta detrás del cuerpo (una puerta o punto '
        'fijo), un extremo en cada mano, junta los brazos al frente en un movimiento de arco.',
    caminhoImagem: 'assets/personagem/crucifixo-elastico.jpg',
  ),

  // Espalda
  Exercicio(
    id: 'remada-curvada-halteres',
    nome: 'Remo inclinado con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con el torso inclinado hacia adelante y la espalda recta, jala las '
        'mancuernas en dirección a la cintura, contrayendo las escápulas.',
    caminhoImagem: 'assets/personagem/remada-curvada-halteres.jpg',
  ),
  Exercicio(
    id: 'remada-unilateral-halter',
    nome: 'Remo unilateral con mancuerna',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Apoyando una rodilla y una mano en el banco, jala la mancuerna con '
        'la otra mano hacia la cintura, manteniendo el torso estable.',
    caminhoImagem: 'assets/personagem/remada-unilateral-halter.jpg',
  ),
  Exercicio(
    id: 'puxada-frontal-polia',
    nome: 'Jalón al pecho en polea',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada, jala la barra en dirección a la parte superior del pecho, '
        'contrayendo la espalda y evitando balancear el torso.',
    caminhoImagem: 'assets/personagem/puxada-frontal-polia.jpg',
  ),
  Exercicio(
    id: 'remada-baixa-cabo',
    nome: 'Remo bajo en polea',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada con las rodillas ligeramente flexionadas, jala el cable en '
        'dirección al abdomen, manteniendo la columna erguida.',
    caminhoImagem: 'assets/personagem/remada-baixa-cabo.jpg',
  ),
  Exercicio(
    id: 'superman',
    nome: 'Superman',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.mobilidade, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Acostada boca abajo, eleva al mismo tiempo brazos y piernas, '
        'contrayendo la zona lumbar, y regresa de forma controlada.',
    caminhoImagem: 'assets/personagem/superman.jpg',
  ),
  Exercicio(
    id: 'barra-fixa-assistida',
    nome: 'Dominadas asistidas',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Con la ayuda de una máquina asistida o una banda elástica, jala el '
        'cuerpo hacia arriba hasta que la barbilla pase la barra.',
    caminhoImagem: 'assets/personagem/barra-fixa-assistida.jpg',
  ),
  Exercicio(
    id: 'remada-elastico',
    nome: 'Remo con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta a un punto fijo al frente, jala los '
        'extremos hacia la cintura, contrayendo las escápulas.',
    caminhoImagem: 'assets/personagem/remada-elastico.jpg',
  ),
  Exercicio(
    id: 'puxada-alta-elastico',
    nome: 'Jalón alto con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta a un punto fijo por encima de la '
        'cabeza, jala los extremos hacia abajo en dirección al pecho, manteniendo el torso estable.',
    caminhoImagem: 'assets/personagem/puxada-alta-elastico.jpg',
  ),

  // Hombro
  Exercicio(
    id: 'desenvolvimento-halteres',
    nome: 'Press de hombro con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Sentada o de pie, empuja las mancuernas hacia arriba hasta estirar '
        'los brazos por encima de la cabeza y baja de forma controlada.',
    caminhoImagem: 'assets/personagem/desenvolvimento-halteres.jpg',
  ),
  Exercicio(
    id: 'elevacao-lateral',
    nome: 'Elevación lateral',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con los brazos a los costados del cuerpo, eleva las mancuernas '
        'hacia los lados hasta la altura de los hombros, sin balancear el torso.',
    caminhoImagem: 'assets/personagem/elevacao-lateral.jpg',
  ),
  Exercicio(
    id: 'elevacao-frontal',
    nome: 'Elevación frontal',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con las mancuernas frente a los muslos, eleva los brazos hacia '
        'adelante hasta la altura de los hombros y baja de forma controlada.',
    caminhoImagem: 'assets/personagem/elevacao-frontal.jpg',
  ),
  Exercicio(
    id: 'remada-alta',
    nome: 'Remo alto',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.costas],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Sujetando las mancuernas frente al cuerpo, lleva los codos hacia '
        'arriba y hacia afuera hasta la altura de los hombros.',
    caminhoImagem: 'assets/personagem/remada-alta.jpg',
  ),
  Exercicio(
    id: 'face-pull-cabo',
    nome: 'Face pull en polea',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.costas],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.mobilidade, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Jala la cuerda en dirección al rostro, separando las manos y '
        'contrayendo la parte posterior del hombro.',
    caminhoImagem: 'assets/personagem/face-pull-cabo.jpg',
  ),
  Exercicio(
    id: 'desenvolvimento-militar-barra',
    nome: 'Press militar con barra',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.barra,
    instrucoes:
        'De pie, empuja la barra desde la altura de los hombros hasta '
        'estirar los brazos por completo encima de la cabeza.',
    caminhoImagem: 'assets/personagem/desenvolvimento-militar-barra.jpg',
  ),
  Exercicio(
    id: 'desenvolvimento-elastico',
    nome: 'Press de hombro con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta bajo los pies, empuja los extremos '
        'hacia arriba hasta estirar los brazos por encima de la cabeza y baja de forma controlada.',
    caminhoImagem: 'assets/personagem/desenvolvimento-elastico.jpg',
  ),
  Exercicio(
    id: 'elevacao-lateral-elastico',
    nome: 'Elevación lateral con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta bajo los pies, eleva los brazos hacia '
        'los lados hasta la altura de los hombros, sin balancear el torso.',
    caminhoImagem: 'assets/personagem/elevacao-lateral-elastico.jpg',
  ),

  // Bíceps
  Exercicio(
    id: 'rosca-direta-halteres',
    nome: 'Curl de bíceps con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con los brazos a los costados del cuerpo, flexiona los codos '
        'elevando las mancuernas hasta la altura de los hombros, sin balancear el cuerpo.',
    caminhoImagem: 'assets/personagem/rosca-direta-halteres.jpg',
  ),
  Exercicio(
    id: 'rosca-alternada',
    nome: 'Curl alternado',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes: 'Igual que el curl de bíceps, alternando un brazo a la vez.',
    caminhoImagem: 'assets/personagem/rosca-alternada.jpg',
  ),
  Exercicio(
    id: 'rosca-martelo',
    nome: 'Curl martillo',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con las palmas de las manos una frente a la otra, flexiona los '
        'codos manteniendo ese agarre neutro durante todo el movimiento.',
    caminhoImagem: 'assets/personagem/rosca-martelo.jpg',
  ),
  Exercicio(
    id: 'rosca-direta-barra',
    nome: 'Curl de bíceps con barra',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Con agarre supinado en la barra, flexiona los codos elevando la '
        'barra hasta la altura de los hombros.',
    caminhoImagem: 'assets/personagem/rosca-direta-barra.jpg',
  ),
  Exercicio(
    id: 'rosca-scott',
    nome: 'Curl Scott',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Con el brazo apoyado en el banco Scott, flexiona el codo elevando '
        'el peso sin despegar el brazo del apoyo.',
    caminhoImagem: 'assets/personagem/rosca-scott.jpg',
  ),
  Exercicio(
    id: 'rosca-concentrada',
    nome: 'Curl concentrado',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Sentada, con el codo apoyado en la parte interna del muslo, '
        'flexiona el brazo elevando la mancuerna lentamente.',
    caminhoImagem: 'assets/personagem/rosca-concentrada.jpg',
  ),
  Exercicio(
    id: 'rosca-direta-elastico',
    nome: 'Curl de bíceps con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta bajo los pies, flexiona los codos '
        'elevando los extremos hasta la altura de los hombros, sin balancear el cuerpo.',
    caminhoImagem: 'assets/personagem/rosca-direta-elastico.jpg',
  ),
  Exercicio(
    id: 'rosca-martelo-elastico',
    nome: 'Curl martillo con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Igual que el curl de bíceps con banda elástica, manteniendo las '
        'palmas una frente a la otra durante todo el movimiento.',
    caminhoImagem: 'assets/personagem/rosca-martelo-elastico.jpg',
  ),

  // Tríceps
  Exercicio(
    id: 'triceps-corda-cabo',
    nome: 'Tríceps en polea con cuerda',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Con los codos fijos a los costados del cuerpo, extiende los brazos '
        'empujando la cuerda hacia abajo.',
    caminhoImagem: 'assets/personagem/triceps-corda-cabo.jpg',
  ),
  Exercicio(
    id: 'mergulho-banco',
    nome: 'Fondos en banco',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    gruposMuscularesSecundarios: [GrupoMuscular.peito],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.banco,
    instrucoes:
        'Con las manos apoyadas en el borde del banco detrás del cuerpo, '
        'flexiona los codos bajando la cadera y empuja de vuelta hacia arriba.',
    caminhoImagem: 'assets/personagem/mergulho-banco.jpg',
  ),
  Exercicio(
    id: 'triceps-testa-halteres',
    nome: 'Extensión de tríceps acostada con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Acostada, con los brazos estirados hacia arriba, flexiona solo los '
        'codos bajando las mancuernas en dirección a la frente.',
    caminhoImagem: 'assets/personagem/triceps-testa-halteres.jpg',
  ),
  Exercicio(
    id: 'triceps-frances',
    nome: 'Press francés con mancuerna',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'De pie o sentada, con la mancuerna detrás de la cabeza, extiende '
        'el codo elevando el peso y regresa de forma controlada.',
    caminhoImagem: 'assets/personagem/triceps-frances.jpg',
  ),
  Exercicio(
    id: 'flexao-braco-fechada',
    nome: 'Flexión de brazos cerrada',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    gruposMuscularesSecundarios: [GrupoMuscular.peito],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Igual que la flexión tradicional, pero con las manos más juntas, '
        'al ancho de los hombros, para enfocar más el tríceps.',
    caminhoImagem: 'assets/personagem/flexao-braco-fechada.jpg',
  ),
  Exercicio(
    id: 'triceps-coice-halter',
    nome: 'Tríceps patada con mancuerna',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con el torso inclinado hacia adelante y el brazo pegado al cuerpo, '
        'extiende el codo llevando la mancuerna hacia atrás.',
    caminhoImagem: 'assets/personagem/triceps-coice-halter.jpg',
  ),
  Exercicio(
    id: 'triceps-elastico',
    nome: 'Tríceps con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica sujeta a un punto fijo por encima de la '
        'cabeza y los codos pegados al cuerpo, extiende los brazos empujando hacia abajo.',
    caminhoImagem: 'assets/personagem/triceps-elastico.jpg',
  ),

  // Pierna
  Exercicio(
    id: 'agachamento-livre',
    nome: 'Sentadilla libre',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Con los pies al ancho de los hombros, baja flexionando la cadera y '
        'las rodillas como si fueras a sentarte, manteniendo la espalda recta.',
    caminhoImagem: 'assets/personagem/agachamento-livre.jpg',
  ),
  Exercicio(
    id: 'agachamento-halteres',
    nome: 'Sentadilla con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Igual que la sentadilla libre, sujetando una mancuerna en cada '
        'mano a los costados del cuerpo para aumentar la carga.',
    caminhoImagem: 'assets/personagem/agachamento-halteres.jpg',
  ),
  Exercicio(
    id: 'afundo',
    nome: 'Zancada',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Da un paso hacia adelante y baja la rodilla trasera en dirección '
        'al piso, manteniendo el torso erguido, luego regresa a la posición inicial.',
    caminhoImagem: 'assets/personagem/afundo.jpg',
  ),
  Exercicio(
    id: 'leg-press',
    nome: 'Prensa de piernas',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada en la máquina, empuja la plataforma estirando las '
        'piernas, sin trabar por completo las rodillas, y regresa de forma controlada.',
    caminhoImagem: 'assets/personagem/leg-press.jpg',
  ),
  Exercicio(
    id: 'cadeira-extensora',
    nome: 'Extensión de cuádriceps en máquina',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada en la máquina, estira las rodillas elevando el peso y '
        'baja de forma controlada.',
    caminhoImagem: 'assets/personagem/cadeira-extensora.jpg',
  ),
  Exercicio(
    id: 'cadeira-flexora',
    nome: 'Curl femoral en máquina',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Acostada o sentada en la máquina, flexiona las rodillas llevando '
        'el peso en dirección a los glúteos.',
    caminhoImagem: 'assets/personagem/cadeira-flexora.jpg',
  ),

  // Glúteo
  Exercicio(
    id: 'elevacao-pelvica',
    nome: 'Elevación de cadera',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Acostada con las rodillas flexionadas y los pies apoyados en el '
        'piso, eleva la cadera contrayendo los glúteos en la parte más alta del movimiento.',
    caminhoImagem: 'assets/personagem/elevacao-pelvica.jpg',
  ),
  Exercicio(
    id: 'elevacao-pelvica-barra',
    nome: 'Elevación de cadera con barra',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Con la barra apoyada sobre la cadera y la espalda apoyada en un '
        'banco, eleva la cadera contrayendo los glúteos en la parte más alta.',
    caminhoImagem: 'assets/personagem/elevacao-pelvica-barra.jpg',
  ),
  Exercicio(
    id: 'agachamento-sumo-halter',
    nome: 'Sentadilla sumo con mancuerna',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con los pies separados y apuntando hacia afuera, sujeta una '
        'mancuerna frente al cuerpo y baja flexionando la cadera y las rodillas.',
    caminhoImagem: 'assets/personagem/agachamento-sumo-halter.jpg',
  ),
  Exercicio(
    id: 'coice-cabo',
    nome: 'Patada de glúteo en polea',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Con el cable sujeto al tobillo, extiende la pierna hacia atrás '
        'contrayendo el glúteo, manteniendo el torso estable.',
    caminhoImagem: 'assets/personagem/coice-cabo.jpg',
  ),
  Exercicio(
    id: 'abducao-quadril-elastico',
    nome: 'Abducción de cadera con banda elástica',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Con la banda elástica alrededor de las piernas, abre y cierra las '
        'piernas hacia los lados contra la resistencia.',
    caminhoImagem: 'assets/personagem/abducao-quadril-elastico.jpg',
  ),
  Exercicio(
    id: 'stiff-halteres',
    nome: 'Peso muerto rumano con mancuernas',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Con las rodillas ligeramente flexionadas, inclina el torso hacia '
        'adelante bajando las mancuernas cerca de las piernas, sintiendo el estiramiento en la parte posterior del muslo.',
    caminhoImagem: 'assets/personagem/stiff-halteres.jpg',
  ),

  // Abdomen
  Exercicio(
    id: 'prancha',
    nome: 'Plancha',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.mobilidade],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Apoyada sobre los antebrazos y las puntas de los pies, mantén el '
        'cuerpo recto y el core contraído durante el tiempo indicado.',
    caminhoImagem: 'assets/personagem/prancha.jpg',
  ),
  Exercicio(
    id: 'prancha-lateral',
    nome: 'Plancha lateral',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Apoyada sobre un antebrazo y el costado del pie, mantén el cuerpo '
        'alineado, evitando que la cadera baje.',
    caminhoImagem: 'assets/personagem/prancha-lateral.jpg',
  ),
  Exercicio(
    id: 'abdominal-supra',
    nome: 'Abdominal superior',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Acostada con las rodillas flexionadas, eleva el torso en '
        'dirección a las rodillas contrayendo el abdomen, sin forzar el cuello.',
    caminhoImagem: 'assets/personagem/abdominal-supra.jpg',
  ),
  Exercicio(
    id: 'abdominal-infra',
    nome: 'Abdominal inferior',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Acostada con las piernas estiradas, elévalas en dirección al '
        'techo contrayendo la parte inferior del abdomen, y baja sin tocar el piso.',
    caminhoImagem: 'assets/personagem/abdominal-infra.jpg',
  ),
  Exercicio(
    id: 'bicicleta-no-chao',
    nome: 'Bicicleta en el piso',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.emagrecimento],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Acostada, alterna llevando el codo hacia la rodilla opuesta '
        'mientras estiras la otra pierna, en un movimiento de pedaleo.',
    caminhoImagem: 'assets/personagem/bicicleta-no-chao.jpg',
  ),
  Exercicio(
    id: 'roda-abdominal',
    nome: 'Rueda abdominal',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.outro,
    instrucoes:
        'Arrodillada, rueda hacia adelante estirando el cuerpo lo más '
        'posible sin dejar que la cadera baje, luego regresa.',
    caminhoImagem: 'assets/personagem/roda-abdominal.jpg',
  ),
];
