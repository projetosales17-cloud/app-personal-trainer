import '../models/receita.dart';

/// Biblioteca v1 de receitas: 2 por tipo de refeição, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras).
const bibliotecaReceitas = <Receita>[
  // Café da manhã
  Receita(
    id: 'omelete-de-espinafre',
    titulo: 'Omelette de espinaca',
    tipoRefeicao: TipoRefeicao.cafeDaManha,
    tempoPreparoMinutos: 10,
    porcoes: 1,
    ingredientes: ['2 huevos', 'un puñado de espinaca picada', 'sal al gusto', 'un chorrito de aceite de oliva'],
    modoPreparo:
        'Bate los huevos con la sal. Calienta el aceite en un sartén y saltea la '
        'espinaca durante 1 minuto. Agrega los huevos batidos y cocina a fuego '
        'bajo hasta que cuajen, doblando por la mitad antes de servir.',
    vegano: false,
  ),
  Receita(
    id: 'vitamina-de-banana-com-aveia',
    titulo: 'Batido de plátano con avena',
    tipoRefeicao: TipoRefeicao.cafeDaManha,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: [
      '1 plátano',
      '2 cucharadas de avena en hojuelas',
      '1 vaso de bebida vegetal (o leche normal, si prefieres)',
    ],
    modoPreparo: 'Licúa todos los ingredientes en la licuadora hasta obtener una mezcla homogénea. Sirve bien frío.',
  ),

  // Almoço
  Receita(
    id: 'frango-arroz-integral-brocolis',
    titulo: 'Pechuga de pollo a la plancha con arroz integral y brócoli',
    tipoRefeicao: TipoRefeicao.almoco,
    tempoPreparoMinutos: 30,
    porcoes: 2,
    ingredientes: [
      '2 filetes de pechuga de pollo',
      '1 taza de arroz integral crudo',
      '1 taza de brócoli en floretes',
      'sal, ajo y aceite de oliva al gusto',
    ],
    modoPreparo:
        'Sazona el pollo con sal y ajo y cocínalo a la plancha hasta que dore '
        'por ambos lados. Cocina el arroz integral siguiendo las instrucciones '
        'del empaque. Cocina el brócoli al vapor durante 5 minutos. Sirve todo junto.',
    vegetariano: false,
    vegano: false,
  ),
  Receita(
    id: 'bowl-grao-de-bico-legumes',
    titulo: 'Bowl de garbanzos con vegetales',
    tipoRefeicao: TipoRefeicao.almoco,
    tempoPreparoMinutos: 20,
    porcoes: 2,
    ingredientes: [
      '1 taza de garbanzos cocidos',
      '1 zanahoria rallada',
      '1/2 calabacín en cubos, a la plancha',
      'aceite de oliva, limón y sal al gusto',
    ],
    modoPreparo:
        'Cocina el calabacín en cubos a la plancha hasta que dore. Mezcla con '
        'los garbanzos y la zanahoria rallada en un tazón. Sazona con aceite '
        'de oliva, limón y sal.',
  ),

  // Lanche da tarde
  Receita(
    id: 'iogurte-com-frutas-e-chia',
    titulo: 'Yogur con frutas y chía',
    tipoRefeicao: TipoRefeicao.lancheDaTarde,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: [
      '1 envase de yogur natural (o yogur vegetal, si prefieres)',
      '1/2 taza de fresas picadas',
      '1 cucharada de chía',
    ],
    modoPreparo: 'Mezcla el yogur con las fresas picadas y termina espolvoreando la chía por encima.',
    contemLactose: true,
    vegano: false,
  ),
  Receita(
    id: 'torrada-integral-pasta-de-amendoim',
    titulo: 'Tostada integral con mantequilla de maní',
    tipoRefeicao: TipoRefeicao.lancheDaTarde,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: ['2 rebanadas de pan integral', '1 cucharada de mantequilla de maní integral'],
    modoPreparo: 'Tuesta el pan y unta la mantequilla de maní encima.',
    contemGluten: true,
  ),

  // Jantar
  Receita(
    id: 'sopa-de-legumes-com-lentilha',
    titulo: 'Sopa de vegetales con lentejas',
    tipoRefeicao: TipoRefeicao.jantar,
    tempoPreparoMinutos: 35,
    porcoes: 2,
    ingredientes: [
      '1 taza de lentejas crudas',
      '1 zanahoria en cubos',
      '1 calabacín en cubos',
      'sal y condimentos al gusto',
      'agua suficiente para cubrir',
    ],
    modoPreparo:
        'Saltea rápidamente los vegetales, agrega las lentejas y suficiente '
        'agua para cubrir todo. Cocina a fuego medio hasta que las lentejas '
        'estén tiernas, unos 25 minutos. Ajusta la sal y los condimentos al final.',
  ),
  Receita(
    id: 'salada-de-atum-com-folhas-verdes',
    titulo: 'Ensalada de atún con hojas verdes',
    tipoRefeicao: TipoRefeicao.jantar,
    tempoPreparoMinutos: 10,
    porcoes: 1,
    ingredientes: [
      '1 lata de atún en agua',
      'hojas verdes al gusto (lechuga, rúcula o espinaca)',
      '1 tomate en rodajas',
      'aceite de oliva y limón al gusto',
    ],
    modoPreparo: 'Coloca las hojas y el tomate en un plato, agrega el atún escurrido por encima y '
        'sazona con aceite de oliva y limón.',
    vegetariano: false,
    vegano: false,
  ),
];
