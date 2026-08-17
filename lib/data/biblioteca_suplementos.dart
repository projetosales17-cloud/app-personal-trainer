import '../models/suplemento.dart';

/// Biblioteca v1 de suplementos: conteúdo educativo geral, com faixas de
/// dosagem amplamente publicadas (não individualizadas — ver Suplemento e
/// briefing do produto: dosagem individualizada precisa de validação
/// profissional antes de virar conteúdo prescritivo).
const bibliotecaSuplementos = <Suplemento>[
  Suplemento(
    id: 'whey-protein',
    nome: 'Proteína de suero (whey protein)',
    tipo: TipoSuplemento.proteina,
    descricao:
        'Proteína derivada del suero de la leche, usada como una forma '
        'práctica de complementar la ingesta diaria de proteína cuando la '
        'alimentación por sí sola no es suficiente. Existen versiones con y '
        'sin lactosa. No reemplaza la proteína de fuentes alimentarias: es '
        'un complemento.',
    dosagemGenerica:
        'Rango general publicado: 20 a 30 g por porción, generalmente 1 a '
        '2 veces al día. Revisa siempre la cantidad indicada en el empaque '
        'del producto específico.',
  ),
  Suplemento(
    id: 'proteina-vegetal',
    nome: 'Proteína vegetal (chícharo o arveja, arroz, soya)',
    tipo: TipoSuplemento.proteina,
    descricao:
        'Alternativa al whey para quienes tienen restricciones con los '
        'lácteos o siguen una dieta vegetariana o vegana, combinando '
        'proteínas de diferentes fuentes vegetales para un perfil de '
        'aminoácidos más completo.',
    dosagemGenerica:
        'Rango general publicado: 20 a 30 g por porción, la misma lógica '
        'que el whey. Revisa siempre la cantidad indicada en el empaque '
        'del producto específico.',
  ),
  Suplemento(
    id: 'creatina',
    nome: 'Creatina',
    tipo: TipoSuplemento.creatina,
    descricao:
        'Uno de los suplementos más estudiados para el rendimiento en '
        'entrenamientos de fuerza — asociado con ganancias de fuerza y '
        'masa muscular a lo largo del tiempo, cuando se combina con '
        'entrenamiento regular. Es segura para la mayoría de las personas '
        'sanas, pero quienes tienen condiciones renales deben hablar con '
        'un médico antes de usarla.',
    dosagemGenerica:
        'Rango general publicado: 3 a 5 g por día, en cualquier horario — '
        'no es necesaria una fase de carga para la mayoría de las '
        'personas.',
  ),
  Suplemento(
    id: 'multivitaminico',
    nome: 'Multivitamínico',
    tipo: TipoSuplemento.vitaminaMineral,
    descricao:
        'Combinación de vitaminas y minerales usada para cubrir posibles '
        'vacíos nutricionales de la alimentación del día a día. '
        'Especialmente relevante después de la cirugía bariátrica, donde '
        'la absorción de nutrientes cambia — en ese caso, la reposición '
        'suele estar acompañada de cerca con exámenes periódicos '
        'solicitados por el equipo médico.',
    dosagemGenerica:
        'Varía mucho según la marca y la formulación — no existe un rango '
        'genérico único. Sigue siempre la dosis indicada en el empaque '
        'del producto específico.',
  ),
  Suplemento(
    id: 'omega-3',
    nome: 'Omega-3',
    tipo: TipoSuplemento.acidoGraxo,
    descricao:
        'Ácido graso esencial, asociado con beneficios cardiovasculares y '
        'antiinflamatorios generales. Presente naturalmente en pescados '
        'grasos y semillas como la linaza y la chía — el suplemento es una '
        'opción para quienes no consumen estas fuentes con frecuencia.',
    dosagemGenerica:
        'Rango general publicado: 1 a 2 g de EPA+DHA combinados por día. '
        'Revisa la concentración exacta en el empaque del producto '
        'específico.',
  ),
];
