import '../models/receita.dart';

/// Biblioteca v1 de receitas: 2 por tipo de refeição, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras).
const bibliotecaReceitas = <Receita>[
  // Café da manhã
  Receita(
    id: 'omelete-de-espinafre',
    titulo: 'Omelete de espinafre',
    tipoRefeicao: TipoRefeicao.cafeDaManha,
    tempoPreparoMinutos: 10,
    porcoes: 1,
    ingredientes: ['2 ovos', '1 punhado de espinafre picado', 'sal a gosto', '1 fio de azeite'],
    modoPreparo:
        'Bata os ovos com o sal. Aqueça o azeite em uma frigideira e refogue o '
        'espinafre por 1 minuto. Adicione os ovos batidos e cozinhe em fogo '
        'baixo até firmar, dobrando ao meio antes de servir.',
    vegano: false,
  ),
  Receita(
    id: 'vitamina-de-banana-com-aveia',
    titulo: 'Vitamina de banana com aveia',
    tipoRefeicao: TipoRefeicao.cafeDaManha,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: [
      '1 banana',
      '2 colheres de sopa de aveia em flocos',
      '1 copo de bebida vegetal (ou leite comum, se preferir)',
    ],
    modoPreparo: 'Bata todos os ingredientes no liquidificador até ficar homogêneo. Sirva gelado.',
  ),

  // Almoço
  Receita(
    id: 'frango-arroz-integral-brocolis',
    titulo: 'Frango grelhado com arroz integral e brócolis',
    tipoRefeicao: TipoRefeicao.almoco,
    tempoPreparoMinutos: 30,
    porcoes: 2,
    ingredientes: [
      '2 filés de peito de frango',
      '1 xícara de arroz integral cru',
      '1 xícara de brócolis em floretes',
      'sal, alho e azeite a gosto',
    ],
    modoPreparo:
        'Tempere o frango com sal e alho e grelhe até dourar dos dois lados. '
        'Cozinhe o arroz integral conforme instruções da embalagem. Cozinhe o '
        'brócolis no vapor por 5 minutos. Sirva tudo junto.',
    vegetariano: false,
    vegano: false,
  ),
  Receita(
    id: 'bowl-grao-de-bico-legumes',
    titulo: 'Bowl de grão-de-bico com legumes',
    tipoRefeicao: TipoRefeicao.almoco,
    tempoPreparoMinutos: 20,
    porcoes: 2,
    ingredientes: [
      '1 xícara de grão-de-bico cozido',
      '1 cenoura ralada',
      '1/2 abobrinha em cubos grelhados',
      'azeite, limão e sal a gosto',
    ],
    modoPreparo:
        'Grelhe a abobrinha em cubos até dourar. Misture com o grão-de-bico e '
        'a cenoura ralada em uma tigela. Tempere com azeite, limão e sal.',
  ),

  // Lanche da tarde
  Receita(
    id: 'iogurte-com-frutas-e-chia',
    titulo: 'Iogurte com frutas e chia',
    tipoRefeicao: TipoRefeicao.lancheDaTarde,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: [
      '1 pote de iogurte natural (ou iogurte vegetal, se preferir)',
      '1/2 xícara de morangos picados',
      '1 colher de sopa de chia',
    ],
    modoPreparo: 'Misture o iogurte com os morangos picados e finalize com a chia por cima.',
    contemLactose: true,
    vegano: false,
  ),
  Receita(
    id: 'torrada-integral-pasta-de-amendoim',
    titulo: 'Torrada integral com pasta de amendoim',
    tipoRefeicao: TipoRefeicao.lancheDaTarde,
    tempoPreparoMinutos: 5,
    porcoes: 1,
    ingredientes: ['2 fatias de pão integral', '1 colher de sopa de pasta de amendoim integral'],
    modoPreparo: 'Toste o pão e espalhe a pasta de amendoim por cima.',
    contemGluten: true,
  ),

  // Jantar
  Receita(
    id: 'sopa-de-legumes-com-lentilha',
    titulo: 'Sopa de legumes com lentilha',
    tipoRefeicao: TipoRefeicao.jantar,
    tempoPreparoMinutos: 35,
    porcoes: 2,
    ingredientes: [
      '1 xícara de lentilha crua',
      '1 cenoura em cubos',
      '1 abobrinha em cubos',
      'sal e temperos a gosto',
      'água suficiente para cobrir',
    ],
    modoPreparo:
        'Refogue os legumes rapidamente, adicione a lentilha e água suficiente '
        'para cobrir tudo. Cozinhe em fogo médio até a lentilha ficar macia, '
        'cerca de 25 minutos. Ajuste o sal e os temperos ao final.',
  ),
  Receita(
    id: 'salada-de-atum-com-folhas-verdes',
    titulo: 'Salada de atum com folhas verdes',
    tipoRefeicao: TipoRefeicao.jantar,
    tempoPreparoMinutos: 10,
    porcoes: 1,
    ingredientes: [
      '1 lata de atum em água',
      'folhas verdes a gosto (alface, rúcula ou espinafre)',
      '1 tomate em rodelas',
      'azeite e limão a gosto',
    ],
    modoPreparo: 'Monte as folhas e o tomate em um prato, adicione o atum escorrido por cima e '
        'tempere com azeite e limão.',
    vegetariano: false,
    vegano: false,
  ),
];
