import '../models/produto.dart';

/// Catálogo inicial da vitrine (ver briefing do produto): Prioridade 1
/// (home gym — alta demanda, baixo custo de frete, forte apelo visual).
/// As demais prioridades (recuperação/conforto, segmentados por perfil,
/// tecnologia, complementares) entram conforme a base de usuárias
/// crescer. Preços são faixas de referência de mercado, não preços reais
/// de um fornecedor — não há loja/parceria escolhida ainda.
const bibliotecaProdutos = <Produto>[
  Produto(
    id: 'faixas-resistencia',
    nome: 'Kit de faixas de resistência',
    descricao:
        'Elásticos de diferentes intensidades + mini bands, para treino em '
        'casa ou complemento na academia.',
    faixaPrecoReferencia: 'R\$ 30 – R\$ 70',
    tags: [TagPerfil.emagrecimento, TagPerfil.terceiraIdade],
  ),
  Produto(
    id: 'halteres-ajustaveis',
    nome: 'Halteres ajustáveis compactos',
    descricao: 'Peso regulável num par só de halteres, ocupando pouco espaço em casa.',
    faixaPrecoReferencia: 'R\$ 150 – R\$ 400',
    tags: [TagPerfil.hipertrofia, TagPerfil.emagrecimento],
  ),
  Produto(
    id: 'tapete-yoga',
    nome: 'Tapete de yoga antiderrapante',
    descricao: 'Base confortável para alongamento, mobilidade e exercícios no chão.',
    faixaPrecoReferencia: 'R\$ 40 – R\$ 90',
    tags: [TagPerfil.terceiraIdade, TagPerfil.menopausa, TagPerfil.bariatrica],
  ),
  Produto(
    id: 'corda-pular',
    nome: 'Corda de pular de alta velocidade',
    descricao:
        'Corda com rolamento, digital 2 em 1 com contador — ótima para cardio '
        'rápido em casa.',
    faixaPrecoReferencia: 'R\$ 25 – R\$ 60',
    tags: [TagPerfil.emagrecimento],
  ),
  Produto(
    id: 'conjunto-seamless',
    nome: 'Conjunto de academia sem costura',
    descricao: 'Top e legging seamless, conforto e liberdade de movimento no treino.',
    faixaPrecoReferencia: 'R\$ 90 – R\$ 180',
    tags: [TagPerfil.emagrecimento, TagPerfil.hipertrofia],
  ),
  Produto(
    id: 'roda-abdominal-produto',
    nome: 'Roda abdominal',
    descricao:
        'Fortalecimento de core e estabilidade — não recomendada para quem '
        'está no período de restrição pós-parto ou no perfil terceira idade '
        '(ver anamnese).',
    faixaPrecoReferencia: 'R\$ 30 – R\$ 60',
    tags: [TagPerfil.hipertrofia],
  ),
];
