import '../models/publicacao_comunidade.dart';

/// Biblioteca v1 da aba Comunidade: conteúdo curado e pré-escrito
/// representando perfis variados (emagrecimento, hipertrofia, menopausa,
/// pós-bariátrica, terceira idade), não publicações reais de usuárias —
/// ver aviso em PublicacaoComunidade sobre a limitação atual.
const bibliotecaComunidade = <PublicacaoComunidade>[
  PublicacaoComunidade(
    id: 'fernanda-constancia',
    autora: 'Fernanda S.',
    tipo: TipoPublicacaoComunidade.depoimento,
    texto:
        'Cambié la meta de "perder X kilos" por "entrenar 3 veces por '
        'semana". Fallé menos veces con una meta que dependía solo de mí, '
        'no de la báscula.',
  ),
  PublicacaoComunidade(
    id: 'dica-agua-por-perto',
    autora: 'Equipo',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Dejar una botella de agua cerca (escritorio, bolso) ayuda a '
        'cumplir la meta de hidratación sin tener que acordarte de tomar '
        'agua todo el tiempo.',
  ),
  PublicacaoComunidade(
    id: 'marina-primeira-flexao',
    autora: 'Marina T.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'Después de meses entrenando en casa, logré hacer mi primera '
        'flexión de brazos completa sin apoyar las rodillas. Algo pequeño '
        'para mucha gente, enorme para mí.',
  ),
  PublicacaoComunidade(
    id: 'claudia-menopausa',
    autora: 'Claudia R.',
    tipo: TipoPublicacaoComunidade.depoimento,
    texto:
        'En la menopausia, el entrenamiento de fuerza se volvió una '
        'prioridad para mí después de entender su relación con la densidad '
        'ósea. No se trata de estética, se trata de los próximos 30 años.',
  ),
  PublicacaoComunidade(
    id: 'dica-ficha-vencida',
    autora: 'Equipo',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Cuando la app te avise que tu plan está por vencer, aprovecha '
        'para pensar si tus días disponibles en la semana cambiaron: el '
        'nuevo plan puede ajustarse mejor a tu rutina actual.',
  ),
  PublicacaoComunidade(
    id: 'juliana-bariatrica',
    autora: 'Juliana M.',
    tipo: TipoPublicacaoComunidade.depoimento,
    texto:
        'Un año después de la bariátrica, lo que más me ayudó fue no '
        'comparar mi ritmo con el de nadie más. Cada acompañamiento '
        'profesional traza un camino diferente.',
  ),
  PublicacaoComunidade(
    id: 'rosa-terceira-idade',
    autora: 'Rosa A.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'A los 68 años, empecé los entrenamientos de movilidad con miedo '
        'de lastimarme. Hoy subo escaleras sin sujetarme del pasamanos, '
        'algo que había dejado de hacer hace años.',
  ),
  PublicacaoComunidade(
    id: 'dica-descanso',
    autora: 'Equipo',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Un día de descanso no es un día perdido. Es parte del '
        'entrenamiento: el músculo se recupera y se vuelve más fuerte '
        'justo en ese intervalo.',
  ),
  PublicacaoComunidade(
    id: 'patricia-hipertrofia',
    autora: 'Patricia L.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'Registrar la carga de cada entrenamiento me mostró un progreso '
        'que no veía en el espejo. En 4 meses, dupliqué la carga de la '
        'sentadilla.',
  ),
  PublicacaoComunidade(
    id: 'dica-priorize-uma-mudanca',
    autora: 'Equipo',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Tratar de cambiar el entrenamiento, la alimentación y el sueño '
        'todo al mismo tiempo suele agotar rápido. Priorizar un cambio a '
        'la vez tiende a durar más.',
  ),
];
