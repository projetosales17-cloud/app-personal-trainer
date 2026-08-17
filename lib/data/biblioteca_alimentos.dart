import '../models/alimento.dart';

/// Biblioteca v1 de alimentos: cerca de 7 por categoria, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras). Usada para consulta e substituição, não para cardápio gerado.
const bibliotecaAlimentos = <Alimento>[
  // Proteína
  Alimento(
    id: 'frango-grelhado',
    nome: 'Pechuga de pollo a la plancha',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
    vegetariano: false,
    vegano: false,
  ),
  Alimento(
    id: 'tilapia-assada',
    nome: 'Tilapia al horno',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
    vegetariano: false,
    vegano: false,
  ),
  Alimento(
    id: 'ovo-cozido',
    nome: 'Huevo cocido',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '2 unidades',
    vegetariano: true,
    vegano: false,
  ),
  Alimento(
    id: 'tofu-grelhado',
    nome: 'Tofu a la plancha',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
  ),
  Alimento(
    id: 'lentilha-cozida',
    nome: 'Lentejas cocidas',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '1 taza (~200g)',
  ),
  Alimento(
    id: 'grao-de-bico-cozido',
    nome: 'Garbanzos cocidos',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '1 taza (~200g)',
  ),
  Alimento(
    id: 'iogurte-natural-desnatado',
    nome: 'Yogur natural descremado',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '200g',
    contemLactose: true,
    vegano: false,
  ),

  // Carboidrato
  Alimento(
    id: 'arroz-integral',
    nome: 'Arroz integral cocido',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '4 cucharadas (~100g)',
  ),
  Alimento(
    id: 'batata-doce',
    nome: 'Camote cocido (batata)',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '150g',
  ),
  Alimento(
    id: 'aveia-em-flocos',
    nome: 'Avena en hojuelas',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '3 cucharadas (~30g)',
    observacao:
        'Naturalmente sin gluten, pero puede haber contaminación cruzada: '
        'busca la versión certificada "sin gluten" si tienes sensibilidad.',
  ),
  Alimento(
    id: 'pao-integral',
    nome: 'Pan integral',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '2 rebanadas',
    contemGluten: true,
  ),
  Alimento(
    id: 'quinoa-cozida',
    nome: 'Quinoa cocida',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '4 cucharadas (~100g)',
  ),
  Alimento(
    id: 'mandioca-cozida',
    nome: 'Yuca cocida',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '100g',
  ),
  Alimento(
    id: 'macarrao-de-arroz',
    nome: 'Fideos de arroz',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '1 taza cocido',
  ),

  // Gordura
  Alimento(
    id: 'azeite-de-oliva',
    nome: 'Aceite de oliva extravirgen',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 cucharada',
  ),
  Alimento(
    id: 'abacate',
    nome: 'Aguacate (palta)',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1/2 unidad',
  ),
  Alimento(
    id: 'castanha-do-para',
    nome: 'Nuez de Brasil',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '2 a 3 unidades',
  ),
  Alimento(
    id: 'amendoas',
    nome: 'Almendras',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 puñado (~20g)',
  ),
  Alimento(
    id: 'chia',
    nome: 'Chía',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 cucharada',
  ),
  Alimento(
    id: 'linhaca-triturada',
    nome: 'Linaza molida',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 cucharada',
  ),
  Alimento(
    id: 'pasta-de-amendoim',
    nome: 'Mantequilla de maní integral',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 cucharada',
    observacao: 'Prefiere las versiones sin azúcar añadido.',
  ),

  // Vegetal
  Alimento(
    id: 'brocolis-vapor',
    nome: 'Brócoli cocido al vapor',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 taza',
  ),
  Alimento(
    id: 'espinafre-refogado',
    nome: 'Espinaca salteada',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 taza',
  ),
  Alimento(
    id: 'cenoura',
    nome: 'Zanahoria cruda o cocida',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidad mediana',
  ),
  Alimento(
    id: 'abobrinha-grelhada',
    nome: 'Calabacín a la plancha',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 taza',
  ),
  Alimento(
    id: 'couve-refogada',
    nome: 'Col rizada salteada',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '2 cucharadas',
  ),
  Alimento(
    id: 'pepino',
    nome: 'Pepino en rodajas',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidad mediana',
  ),
  Alimento(
    id: 'tomate',
    nome: 'Tomate',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidad mediana',
  ),

  // Fruta
  Alimento(
    id: 'banana',
    nome: 'Plátano (banana)',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidad mediana',
  ),
  Alimento(
    id: 'maca',
    nome: 'Manzana',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidad mediana',
  ),
  Alimento(
    id: 'morango',
    nome: 'Fresa (frutilla)',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '8 a 10 unidades',
  ),
  Alimento(
    id: 'mamao',
    nome: 'Papaya',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 rebanada mediana',
  ),
  Alimento(
    id: 'laranja',
    nome: 'Naranja',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidad mediana',
  ),
  Alimento(
    id: 'melancia',
    nome: 'Sandía',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 rebanada mediana',
    observacao:
        'Índice glucémico más alto: quienes necesitan controlar el azúcar en '
        'la sangre deben moderar la porción y buscar orientación profesional.',
  ),

  // Laticínio/substituto
  Alimento(
    id: 'leite-desnatado',
    nome: 'Leche descremada',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 vaso (200ml)',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'iogurte-grego',
    nome: 'Yogur griego',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 envase (170g)',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'queijo-cottage',
    nome: 'Queso cottage',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '4 cucharadas',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'queijo-minas-frescal',
    nome: 'Queso fresco',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '2 rebanadas',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'leite-de-amendoas',
    nome: 'Leche de almendras sin azúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 vaso (200ml)',
  ),
  Alimento(
    id: 'leite-de-aveia',
    nome: 'Leche de avena sin azúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 vaso (200ml)',
    observacao: 'Busca la versión certificada "sin gluten" si tienes sensibilidad.',
  ),
  Alimento(
    id: 'bebida-de-soja',
    nome: 'Bebida de soya sin azúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 vaso (200ml)',
  ),
];
