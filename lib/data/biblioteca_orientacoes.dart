import '../models/orientacao.dart';

/// Biblioteca v1 de orientações: 2 conteúdos por tema, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras). Conteúdo educativo geral — a trilha pós-bariátrica aqui só
/// reforça a importância de acompanhamento profissional, sem prescrever
/// nada específico (ver briefing: precisa de validação profissional antes
/// de virar conteúdo prescritivo).
const bibliotecaOrientacoes = <Orientacao>[
  // Treino
  Orientacao(
    id: 'aquecimento-antes-do-treino',
    titulo: 'Por que aquecer antes de treinar',
    tema: TemaOrientacao.treino,
    corpo:
        'O aquecimento prepara músculos e articulações para o esforço, aumenta '
        'a temperatura corporal e reduz o risco de lesões. Poucos minutos de '
        'movimento leve (caminhada, polichinelos, mobilidade articular) antes '
        'da parte principal do treino já fazem diferença.',
  ),
  Orientacao(
    id: 'descanso-entre-treinos',
    titulo: 'Descanso entre treinos',
    tema: TemaOrientacao.treino,
    corpo:
        'O músculo se fortalece no descanso, não só durante o treino. Respeitar '
        'pelo menos um dia de intervalo para o mesmo grupo muscular ajuda na '
        'recuperação e reduz o risco de lesões por excesso de uso.',
  ),

  // Alimentação
  Orientacao(
    id: 'hidratacao-ao-longo-do-dia',
    titulo: 'Hidratação ao longo do dia',
    tema: TemaOrientacao.alimentacao,
    corpo:
        'Distribuir a ingestão de água ao longo do dia, em vez de concentrar '
        'tudo de uma vez, ajuda o corpo a absorver melhor os líquidos. '
        'Consulte a aba Hidratação para ver sua meta diária estimada.',
  ),
  Orientacao(
    id: 'como-ler-rotulos',
    titulo: 'Como ler rótulos de alimentos',
    tema: TemaOrientacao.alimentacao,
    corpo:
        'Observar a lista de ingredientes (geralmente em ordem decrescente de '
        'quantidade) e a informação nutricional por porção ajuda a comparar '
        'produtos e identificar açúcares e gorduras adicionados.',
  ),

  // Motivação
  Orientacao(
    id: 'constancia-antes-de-perfeicao',
    titulo: 'Constância importa mais que perfeição',
    tema: TemaOrientacao.motivacao,
    corpo:
        'Um treino imperfeito feito é mais valioso do que o treino perfeito '
        'que nunca acontece. Resultados vêm da soma de pequenas ações '
        'repetidas ao longo do tempo, não de esforços pontuais intensos.',
  ),
  Orientacao(
    id: 'metas-realistas',
    titulo: 'Definindo metas realistas',
    tema: TemaOrientacao.motivacao,
    corpo:
        'Metas menores e mensuráveis (ex: treinar 3x nesta semana) sustentam a '
        'motivação melhor do que objetivos grandes e distantes. Comemore o '
        'progresso pelo caminho, não só o resultado final.',
  ),

  // Menopausa
  Orientacao(
    id: 'atividade-fisica-na-menopausa',
    titulo: 'Atividade física na menopausa',
    tema: TemaOrientacao.menopausa,
    corpo:
        'A prática regular de exercícios, incluindo treino de força, é '
        'associada a benefícios para densidade óssea, composição corporal e '
        'bem-estar durante a menopausa. Converse com seu médico sobre '
        'particularidades do seu caso antes de mudanças importantes na rotina.',
  ),
  Orientacao(
    id: 'alimentacao-e-menopausa',
    titulo: 'Alimentação e menopausa',
    tema: TemaOrientacao.menopausa,
    corpo:
        'Mudanças hormonais podem afetar apetite, composição corporal e sono. '
        'Priorizar proteínas, cálcio e fibras no dia a dia é uma orientação '
        'geral comum nessa fase — um(a) nutricionista pode individualizar '
        'essas recomendações para você.',
  ),

  // Pós-bariátrica
  Orientacao(
    id: 'acompanhamento-profissional-bariatrica',
    titulo: 'Acompanhamento profissional é essencial',
    tema: TemaOrientacao.posBariatrica,
    corpo:
        'Após cirurgia bariátrica, necessidades nutricionais e de treino são '
        'específicas e mudam ao longo do tempo pós-operatório. Este app ainda '
        'não substitui o acompanhamento de nutricionista e educador físico '
        'com experiência em bariátrica — procure sempre orientação '
        'profissional individualizada.',
  ),
  Orientacao(
    id: 'sinais-de-alerta-bariatrica',
    titulo: 'Sinais de alerta para procurar ajuda',
    tema: TemaOrientacao.posBariatrica,
    corpo:
        'Sintomas como tontura frequente, queda de cabelo intensa, fadiga '
        'incomum ou dificuldade persistente para se alimentar merecem '
        'conversa com sua equipe médica — não espere a próxima consulta de '
        'rotina se algo parecer fora do comum.',
  ),

  // Hábitos saudáveis
  Orientacao(
    id: 'sono-e-recuperacao',
    titulo: 'Sono e recuperação',
    tema: TemaOrientacao.habitos,
    corpo:
        'O sono é quando boa parte da recuperação muscular e hormonal '
        'acontece. Priorizar uma rotina de sono regular pode ter tanto '
        'impacto nos resultados quanto o treino ou a alimentação.',
  ),
  Orientacao(
    id: 'pequenas-mudancas-grandes-resultados',
    titulo: 'Pequenas mudanças, grandes resultados',
    tema: TemaOrientacao.habitos,
    corpo:
        'Trocar o elevador pela escada, caminhar mais, ajustar o horário de '
        'dormir — mudanças pequenas e sustentáveis tendem a durar mais do que '
        'reformulações drásticas e difíceis de manter.',
  ),
];
