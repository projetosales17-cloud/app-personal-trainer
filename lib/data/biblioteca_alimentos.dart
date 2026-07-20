import '../models/alimento.dart';

/// Biblioteca v1 de alimentos: cerca de 7 por categoria, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras). Usada para consulta e substituição, não para cardápio gerado.
const bibliotecaAlimentos = <Alimento>[
  // Proteína
  Alimento(
    id: 'frango-grelhado',
    nome: 'Frango grelhado (peito)',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
    vegetariano: false,
    vegano: false,
  ),
  Alimento(
    id: 'tilapia-assada',
    nome: 'Tilápia assada',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
    vegetariano: false,
    vegano: false,
  ),
  Alimento(
    id: 'ovo-cozido',
    nome: 'Ovo cozido',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '2 unidades',
    vegetariano: true,
    vegano: false,
  ),
  Alimento(
    id: 'tofu-grelhado',
    nome: 'Tofu grelhado',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '150g',
  ),
  Alimento(
    id: 'lentilha-cozida',
    nome: 'Lentilha cozida',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '1 xícara (~200g)',
  ),
  Alimento(
    id: 'grao-de-bico-cozido',
    nome: 'Grão-de-bico cozido',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '1 xícara (~200g)',
  ),
  Alimento(
    id: 'iogurte-natural-desnatado',
    nome: 'Iogurte natural desnatado',
    categoria: CategoriaAlimento.proteina,
    porcaoSugerida: '200g',
    contemLactose: true,
    vegano: false,
  ),

  // Carboidrato
  Alimento(
    id: 'arroz-integral',
    nome: 'Arroz integral cozido',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '4 colheres de sopa (~100g)',
  ),
  Alimento(
    id: 'batata-doce',
    nome: 'Batata-doce cozida',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '150g',
  ),
  Alimento(
    id: 'aveia-em-flocos',
    nome: 'Aveia em flocos',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '3 colheres de sopa (~30g)',
    observacao:
        'Naturalmente sem glúten, mas pode haver contaminação cruzada — '
        'procure a versão certificada "sem glúten" se tiver sensibilidade.',
  ),
  Alimento(
    id: 'pao-integral',
    nome: 'Pão integral',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '2 fatias',
    contemGluten: true,
  ),
  Alimento(
    id: 'quinoa-cozida',
    nome: 'Quinoa cozida',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '4 colheres de sopa (~100g)',
  ),
  Alimento(
    id: 'mandioca-cozida',
    nome: 'Mandioca cozida',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '100g',
  ),
  Alimento(
    id: 'macarrao-de-arroz',
    nome: 'Macarrão de arroz',
    categoria: CategoriaAlimento.carboidrato,
    porcaoSugerida: '1 xícara cozido',
  ),

  // Gordura
  Alimento(
    id: 'azeite-de-oliva',
    nome: 'Azeite de oliva extravirgem',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 colher de sopa',
  ),
  Alimento(
    id: 'abacate',
    nome: 'Abacate',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1/2 unidade',
  ),
  Alimento(
    id: 'castanha-do-para',
    nome: 'Castanha-do-pará',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '2 a 3 unidades',
  ),
  Alimento(
    id: 'amendoas',
    nome: 'Amêndoas',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 punhado (~20g)',
  ),
  Alimento(
    id: 'chia',
    nome: 'Chia',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 colher de sopa',
  ),
  Alimento(
    id: 'linhaca-triturada',
    nome: 'Linhaça triturada',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 colher de sopa',
  ),
  Alimento(
    id: 'pasta-de-amendoim',
    nome: 'Pasta de amendoim integral',
    categoria: CategoriaAlimento.gordura,
    porcaoSugerida: '1 colher de sopa',
    observacao: 'Prefira versões sem açúcar adicionado.',
  ),

  // Vegetal
  Alimento(
    id: 'brocolis-vapor',
    nome: 'Brócolis cozido no vapor',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 xícara',
  ),
  Alimento(
    id: 'espinafre-refogado',
    nome: 'Espinafre refogado',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 xícara',
  ),
  Alimento(
    id: 'cenoura',
    nome: 'Cenoura crua ou cozida',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidade média',
  ),
  Alimento(
    id: 'abobrinha-grelhada',
    nome: 'Abobrinha grelhada',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 xícara',
  ),
  Alimento(
    id: 'couve-refogada',
    nome: 'Couve refogada',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '2 colheres de sopa',
  ),
  Alimento(
    id: 'pepino',
    nome: 'Pepino em rodelas',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidade média',
  ),
  Alimento(
    id: 'tomate',
    nome: 'Tomate',
    categoria: CategoriaAlimento.vegetal,
    porcaoSugerida: '1 unidade média',
  ),

  // Fruta
  Alimento(
    id: 'banana',
    nome: 'Banana',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidade média',
  ),
  Alimento(
    id: 'maca',
    nome: 'Maçã',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidade média',
  ),
  Alimento(
    id: 'morango',
    nome: 'Morango',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '8 a 10 unidades',
  ),
  Alimento(
    id: 'mamao',
    nome: 'Mamão',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 fatia média',
  ),
  Alimento(
    id: 'laranja',
    nome: 'Laranja',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 unidade média',
  ),
  Alimento(
    id: 'melancia',
    nome: 'Melancia',
    categoria: CategoriaAlimento.fruta,
    porcaoSugerida: '1 fatia média',
    observacao:
        'Índice glicêmico mais alto — quem precisa controlar açúcar no '
        'sangue deve moderar a porção e buscar orientação profissional.',
  ),

  // Laticínio/substituto
  Alimento(
    id: 'leite-desnatado',
    nome: 'Leite desnatado',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 copo (200ml)',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'iogurte-grego',
    nome: 'Iogurte grego',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 pote (170g)',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'queijo-cottage',
    nome: 'Queijo cottage',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '4 colheres de sopa',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'queijo-minas-frescal',
    nome: 'Queijo minas frescal',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '2 fatias',
    contemLactose: true,
    vegano: false,
  ),
  Alimento(
    id: 'leite-de-amendoas',
    nome: 'Leite de amêndoas sem açúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 copo (200ml)',
  ),
  Alimento(
    id: 'leite-de-aveia',
    nome: 'Leite de aveia sem açúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 copo (200ml)',
    observacao: 'Procure a versão certificada "sem glúten" se tiver sensibilidade.',
  ),
  Alimento(
    id: 'bebida-de-soja',
    nome: 'Bebida de soja sem açúcar',
    categoria: CategoriaAlimento.laticinio,
    porcaoSugerida: '1 copo (200ml)',
  ),
];
