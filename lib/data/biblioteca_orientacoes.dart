import '../models/orientacao.dart';

/// Biblioteca v1 de orientações: 2 conteúdos por tema, como ponto de
/// partida (ver briefing do produto — a expansão é esperada em versões
/// futuras). Conteúdo educativo geral — a trilha pós-bariátrica aqui só
/// reforça a importância de acompanhamento profissional, sem prescrever
/// nada específico (ver briefing: precisa de validação profissional antes
/// de virar conteúdo prescritivo).
///
/// Cada `caminhoVideo` aponta para um vídeo curto em loop da Yara
/// (`assets/videos/` + nome do tema + `.mp4`) reaproveitado por todo o
/// conteúdo do mesmo tema — não é um vídeo por item individual.
const bibliotecaOrientacoes = <Orientacao>[
  // Treino
  Orientacao(
    id: 'aquecimento-antes-do-treino',
    titulo: 'Por qué calentar antes de entrenar',
    tema: TemaOrientacao.treino,
    corpo:
        'El calentamiento prepara los músculos y las articulaciones para el '
        'esfuerzo, aumenta la temperatura corporal y reduce el riesgo de '
        'lesiones. Unos pocos minutos de movimiento suave (caminata, saltos '
        'de tijera, movilidad articular) antes de la parte principal del '
        'entrenamiento ya marcan la diferencia.',
    caminhoVideo: 'assets/videos/treino.mp4',
  ),
  Orientacao(
    id: 'descanso-entre-treinos',
    titulo: 'Descanso entre entrenamientos',
    tema: TemaOrientacao.treino,
    corpo:
        'El músculo se fortalece durante el descanso, no solo durante el '
        'entrenamiento. Respetar al menos un día de intervalo para el mismo '
        'grupo muscular ayuda en la recuperación y reduce el riesgo de '
        'lesiones por sobreuso.',
    caminhoVideo: 'assets/videos/treino.mp4',
  ),

  // Alimentação
  Orientacao(
    id: 'hidratacao-ao-longo-do-dia',
    titulo: 'Hidratación a lo largo del día',
    tema: TemaOrientacao.alimentacao,
    corpo:
        'Distribuir la ingesta de agua a lo largo del día, en vez de '
        'concentrarla toda de una vez, ayuda a que el cuerpo absorba mejor '
        'los líquidos. Consulta la pestaña Hidratación para ver tu meta '
        'diaria estimada.',
    caminhoVideo: 'assets/videos/alimentacao.mp4',
  ),
  Orientacao(
    id: 'como-ler-rotulos',
    titulo: 'Cómo leer las etiquetas de los alimentos',
    tema: TemaOrientacao.alimentacao,
    corpo:
        'Observar la lista de ingredientes (generalmente en orden '
        'decreciente de cantidad) y la información nutricional por porción '
        'ayuda a comparar productos e identificar azúcares y grasas '
        'añadidas.',
    caminhoVideo: 'assets/videos/alimentacao.mp4',
  ),

  // Motivação
  Orientacao(
    id: 'constancia-antes-de-perfeicao',
    titulo: 'La constancia importa más que la perfección',
    tema: TemaOrientacao.motivacao,
    corpo:
        'Un entrenamiento imperfecto que sí se hace vale más que el '
        'entrenamiento perfecto que nunca sucede. Los resultados vienen de '
        'la suma de pequeñas acciones repetidas a lo largo del tiempo, no '
        'de esfuerzos puntuales intensos.',
    caminhoVideo: 'assets/videos/motivacao.mp4',
  ),
  Orientacao(
    id: 'metas-realistas',
    titulo: 'Cómo definir metas realistas',
    tema: TemaOrientacao.motivacao,
    corpo:
        'Las metas pequeñas y medibles (por ejemplo: entrenar 3 veces esta '
        'semana) sostienen la motivación mejor que los objetivos grandes y '
        'lejanos. Celebra el progreso en el camino, no solo el resultado '
        'final.',
    caminhoVideo: 'assets/videos/motivacao.mp4',
  ),

  // Menopausa
  Orientacao(
    id: 'atividade-fisica-na-menopausa',
    titulo: 'Actividad física en la menopausia',
    tema: TemaOrientacao.menopausa,
    corpo:
        'La práctica regular de ejercicio, incluido el entrenamiento de '
        'fuerza, se asocia con beneficios para la densidad ósea, la '
        'composición corporal y el bienestar durante la menopausia. Habla '
        'con tu médico sobre las particularidades de tu caso antes de hacer '
        'cambios importantes en tu rutina.',
  ),
  Orientacao(
    id: 'alimentacao-e-menopausa',
    titulo: 'Alimentación y menopausia',
    tema: TemaOrientacao.menopausa,
    corpo:
        'Los cambios hormonales pueden afectar el apetito, la composición '
        'corporal y el sueño. Priorizar las proteínas, el calcio y la fibra '
        'en el día a día es una recomendación general común en esta etapa; '
        'un(a) nutricionista puede personalizar estas recomendaciones para '
        'ti.',
  ),

  // Pós-bariátrica
  Orientacao(
    id: 'acompanhamento-profissional-bariatrica',
    titulo: 'El acompañamiento profesional es esencial',
    tema: TemaOrientacao.posBariatrica,
    corpo:
        'Después de la cirugía bariátrica, las necesidades nutricionales y '
        'de entrenamiento son específicas y cambian a lo largo del tiempo '
        'posoperatorio. Esta app todavía no reemplaza el acompañamiento de '
        'un(a) nutricionista y un(a) educador(a) físico(a) con experiencia '
        'en bariátrica — busca siempre orientación profesional '
        'individualizada.',
  ),
  Orientacao(
    id: 'sinais-de-alerta-bariatrica',
    titulo: 'Señales de alerta para buscar ayuda',
    tema: TemaOrientacao.posBariatrica,
    corpo:
        'Síntomas como mareos frecuentes, caída intensa de cabello, fatiga '
        'inusual o dificultad persistente para alimentarte merecen una '
        'conversación con tu equipo médico — no esperes a tu próxima '
        'consulta de rutina si algo se siente fuera de lo común.',
  ),

  // Hábitos saudáveis
  Orientacao(
    id: 'sono-e-recuperacao',
    titulo: 'Sueño y recuperación',
    tema: TemaOrientacao.habitos,
    corpo:
        'El sueño es cuando ocurre gran parte de la recuperación muscular y '
        'hormonal. Priorizar una rutina de sueño regular puede tener tanto '
        'impacto en los resultados como el entrenamiento o la '
        'alimentación.',
  ),
  Orientacao(
    id: 'pequenas-mudancas-grandes-resultados',
    titulo: 'Pequeños cambios, grandes resultados',
    tema: TemaOrientacao.habitos,
    corpo:
        'Cambiar el elevador por las escaleras, caminar más, ajustar tu '
        'horario para dormir — los cambios pequeños y sostenibles suelen '
        'durar más que las reformas drásticas y difíciles de mantener.',
  ),

  // FAQ — perguntas frequentes, uma por tema (formato pergunta/resposta,
  // ver briefing do produto: "artigos por tema, FAQ e vídeos curtos").
  Orientacao(
    id: 'faq-quantas-vezes-por-semana',
    titulo: '¿Cuántas veces por semana debo entrenar?',
    tema: TemaOrientacao.treino,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'Depende de la frecuencia semanal que elegiste en la anamnesis y de '
        'tu nivel de actividad. La app ya genera tu rutina considerando '
        'esto — puedes ajustar la frecuencia cuando generes una nueva '
        'rutina.',
    caminhoVideo: 'assets/videos/treino.mp4',
  ),
  Orientacao(
    id: 'faq-diario-conta-caloria',
    titulo: '¿El diario de alimentación cuenta calorías?',
    tema: TemaOrientacao.alimentacao,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'No en esta versión. El diario registra lo que comiste de forma '
        'libre, sin conteo de calorías — el objetivo es crear el hábito de '
        'llevar un seguimiento de tu alimentación, no controlar números.',
    caminhoVideo: 'assets/videos/alimentacao.mp4',
  ),
  Orientacao(
    id: 'faq-nao-motivada',
    titulo: '¿Qué hacer cuando te falta la motivación?',
    tema: TemaOrientacao.motivacao,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'Reduce la meta del día en vez de saltarte el entrenamiento '
        'completo — un entrenamiento corto mantiene vivo el hábito. La '
        'motivación va y viene; la constancia es lo que sostiene el '
        'resultado en los días en que la motivación falta.',
    caminhoVideo: 'assets/videos/motivacao.mp4',
  ),
  Orientacao(
    id: 'faq-posso-treinar-fogachos',
    titulo: '¿Puedo entrenar si tengo bochornos o sofocos de la menopausia?',
    tema: TemaOrientacao.menopausa,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'En general sí, ajustando la intensidad y la hidratación. Si los '
        'síntomas son intensos o vienen acompañados de otras señales '
        'inusuales, habla con tu médico antes de mantener tu rutina de '
        'entrenamiento.',
  ),
  Orientacao(
    id: 'faq-quando-posso-treinar-bariatrica',
    titulo: '¿Cuándo puedo volver a entrenar después de la cirugía bariátrica?',
    tema: TemaOrientacao.posBariatrica,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'Esto lo define tu equipo médico, no la app — el tiempo de '
        'autorización varía según la persona y el tipo de cirugía. Habla '
        'con tu cirujano(a) y tu educador(a) físico(a) antes de retomar '
        'cualquier entrenamiento.',
  ),
  Orientacao(
    id: 'faq-preciso-dormir-quanto',
    titulo: '¿Cuántas horas de sueño necesito para rendir en el entrenamiento?',
    tema: TemaOrientacao.habitos,
    tipo: TipoConteudoOrientacao.faq,
    corpo:
        'De 7 a 9 horas es el rango generalmente recomendado para adultas, '
        'aunque varía de persona a persona. Priorizar la regularidad en el '
        'horario para dormir suele ayudar tanto como la cantidad de horas.',
  ),
];
