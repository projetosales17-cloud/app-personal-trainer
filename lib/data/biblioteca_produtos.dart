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
    nome: 'Kit de bandas de resistencia',
    descricao:
        'Bandas elásticas de diferentes intensidades + mini bandas, para '
        'entrenar en casa o complementar tu rutina en el gimnasio.',
    faixaPrecoReferencia: 'R\$ 30 – R\$ 70',
    tags: [TagPerfil.emagrecimento, TagPerfil.terceiraIdade],
  ),
  Produto(
    id: 'halteres-ajustaveis',
    nome: 'Mancuernas ajustables compactas',
    descricao: 'Peso regulable en un solo par de mancuernas, que ocupa poco espacio en casa.',
    faixaPrecoReferencia: 'R\$ 150 – R\$ 400',
    tags: [TagPerfil.hipertrofia, TagPerfil.emagrecimento],
  ),
  Produto(
    id: 'tapete-yoga',
    nome: 'Tapete de yoga antideslizante',
    descricao: 'Base cómoda para estiramientos, movilidad y ejercicios en el piso.',
    faixaPrecoReferencia: 'R\$ 40 – R\$ 90',
    tags: [TagPerfil.terceiraIdade, TagPerfil.menopausa, TagPerfil.bariatrica],
  ),
  Produto(
    id: 'corda-pular',
    nome: 'Cuerda para saltar de alta velocidad',
    descricao:
        'Cuerda con rodamiento, digital 2 en 1 con contador — ideal para '
        'cardio rápido en casa.',
    faixaPrecoReferencia: 'R\$ 25 – R\$ 60',
    tags: [TagPerfil.emagrecimento],
  ),
  Produto(
    id: 'conjunto-seamless',
    nome: 'Conjunto deportivo sin costuras',
    descricao: 'Top y legging sin costuras, comodidad y libertad de movimiento durante el entrenamiento.',
    faixaPrecoReferencia: 'R\$ 90 – R\$ 180',
    tags: [TagPerfil.emagrecimento, TagPerfil.hipertrofia],
  ),
  Produto(
    id: 'roda-abdominal-produto',
    nome: 'Rueda abdominal',
    descricao:
        'Fortalecimiento del core y la estabilidad — no se recomienda '
        'para quienes están en el período de restricción posparto o en '
        'el perfil de tercera edad (ver anamnesis).',
    faixaPrecoReferencia: 'R\$ 30 – R\$ 60',
    tags: [TagPerfil.hipertrofia],
  ),
];
