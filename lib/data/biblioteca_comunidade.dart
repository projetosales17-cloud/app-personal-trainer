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
        'Troquei a meta de "perder X quilos" por "treinar 3x por semana". Errei '
        'menos vezes com uma meta que dependia só de mim, não da balança.',
  ),
  PublicacaoComunidade(
    id: 'dica-agua-por-perto',
    autora: 'Equipe',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Deixar uma garrafa de água por perto (mesa de trabalho, bolsa) ajuda a '
        'bater a meta de hidratação sem precisar lembrar de beber água o tempo todo.',
  ),
  PublicacaoComunidade(
    id: 'marina-primeira-flexao',
    autora: 'Marina T.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'Depois de meses treinando em casa, consegui fazer minha primeira '
        'flexão completa sem apoiar os joelhos. Pequena pra muita gente, '
        'enorme pra mim.',
  ),
  PublicacaoComunidade(
    id: 'claudia-menopausa',
    autora: 'Cláudia R.',
    tipo: TipoPublicacaoComunidade.depoimento,
    texto:
        'Na menopausa, o treino de força virou prioridade pra mim depois que '
        'entendi a relação com densidade óssea. Não é sobre estética, é sobre '
        'os próximos 30 anos.',
  ),
  PublicacaoComunidade(
    id: 'dica-ficha-vencida',
    autora: 'Equipe',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Quando o app avisar que sua ficha vai vencer, aproveite pra repensar '
        'se seus dias disponíveis na semana mudaram — a ficha nova pode se '
        'ajustar melhor à sua rotina atual.',
  ),
  PublicacaoComunidade(
    id: 'juliana-bariatrica',
    autora: 'Juliana M.',
    tipo: TipoPublicacaoComunidade.depoimento,
    texto:
        'Um ano depois da bariátrica, o que mais me ajudou foi não comparar '
        'meu ritmo com o de ninguém. Cada acompanhamento profissional traça um '
        'caminho diferente.',
  ),
  PublicacaoComunidade(
    id: 'rosa-terceira-idade',
    autora: 'Rosa A.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'Aos 68 anos, comecei os treinos de mobilidade com receio de me '
        'machucar. Hoje subo escadas sem me segurar no corrimão — algo que eu '
        'tinha parado de fazer havia anos.',
  ),
  PublicacaoComunidade(
    id: 'dica-descanso',
    autora: 'Equipe',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Um dia de descanso não é um dia perdido. É parte do treino — o '
        'músculo se recupera e fica mais forte justamente nesse intervalo.',
  ),
  PublicacaoComunidade(
    id: 'patricia-hipertrofia',
    autora: 'Patrícia L.',
    tipo: TipoPublicacaoComunidade.conquista,
    texto:
        'Registrar a carga de cada treino me mostrou um progresso que eu não '
        'via no espelho. Em 4 meses, dobrei a carga do agachamento.',
  ),
  PublicacaoComunidade(
    id: 'dica-priorize-uma-mudanca',
    autora: 'Equipe',
    tipo: TipoPublicacaoComunidade.dica,
    texto:
        'Tentar mudar treino, alimentação e sono todos de uma vez costuma '
        'cansar rápido. Priorizar uma mudança por vez tende a durar mais.',
  ),
];
