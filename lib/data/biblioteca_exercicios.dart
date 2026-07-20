import '../models/exercicio.dart';

/// Biblioteca v1 de exercícios: cerca de 6 por grupo muscular, como ponto
/// de partida (ver briefing do produto — a expansão é esperada em versões
/// futuras).
const bibliotecaExercicios = <Exercicio>[
  // Peito
  Exercicio(
    id: 'flexao-de-braco',
    nome: 'Flexão de braço',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Com as mãos apoiadas no chão na largura dos ombros, desça o corpo '
        'mantendo o core contraído e empurre de volta até estender os braços.',
  ),
  Exercicio(
    id: 'flexao-pes-elevados',
    nome: 'Flexão com pés elevados',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.ombro, GrupoMuscular.triceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.banco,
    instrucoes:
        'Apoie os pés em um banco e as mãos no chão. Execute a flexão '
        'normalmente — a inclinação aumenta a exigência na parte superior do peito.',
  ),
  Exercicio(
    id: 'supino-reto-halteres',
    nome: 'Supino reto com halteres',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Deitada em um banco, empurre os halteres para cima até estender os '
        'braços, depois desça de forma controlada até a altura do peito.',
  ),
  Exercicio(
    id: 'supino-reto-barra',
    nome: 'Supino reto com barra',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps, GrupoMuscular.ombro],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Deitada em um banco, segure a barra um pouco mais afastada que a '
        'largura dos ombros e desça até tocar levemente o peito, depois empurre para cima.',
  ),
  Exercicio(
    id: 'crucifixo-halteres',
    nome: 'Crucifixo com halteres',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Deitada em um banco, com os braços levemente flexionados, abra os '
        'halteres lateralmente até sentir alongar o peito e volte controladamente.',
  ),
  Exercicio(
    id: 'crossover-cabo',
    nome: 'Crossover no cabo',
    grupoMuscularPrincipal: GrupoMuscular.peito,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Com um cabo em cada mão, puxe ambos à frente do corpo em um '
        'movimento de arco, contraindo o peito no ponto final.',
  ),

  // Costas
  Exercicio(
    id: 'remada-curvada-halteres',
    nome: 'Remada curvada com halteres',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com o tronco inclinado à frente e as costas retas, puxe os '
        'halteres em direção à cintura, contraindo as escápulas.',
  ),
  Exercicio(
    id: 'remada-unilateral-halter',
    nome: 'Remada unilateral com halter',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Apoiando um joelho e uma mão no banco, puxe o halter com a outra '
        'mão em direção à cintura, mantendo o tronco estável.',
  ),
  Exercicio(
    id: 'puxada-frontal-polia',
    nome: 'Puxada frontal na polia',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada, puxe a barra em direção à parte superior do peito, '
        'contraindo as costas e evitando balançar o tronco.',
  ),
  Exercicio(
    id: 'remada-baixa-cabo',
    nome: 'Remada baixa no cabo',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada com os joelhos levemente flexionados, puxe o cabo em '
        'direção ao abdômen, mantendo a coluna ereta.',
  ),
  Exercicio(
    id: 'superman',
    nome: 'Superman',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.mobilidade, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Deitada de bruços, eleve simultaneamente braços e pernas, '
        'contraindo a lombar, e volte controladamente.',
  ),
  Exercicio(
    id: 'barra-fixa-assistida',
    nome: 'Barra fixa assistida',
    grupoMuscularPrincipal: GrupoMuscular.costas,
    gruposMuscularesSecundarios: [GrupoMuscular.biceps],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Usando o apoio de uma máquina assistida ou elástico, puxe o '
        'corpo para cima até o queixo passar da barra.',
  ),

  // Ombro
  Exercicio(
    id: 'desenvolvimento-halteres',
    nome: 'Desenvolvimento com halteres',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Sentada ou em pé, empurre os halteres para cima até estender os '
        'braços acima da cabeça e desça controladamente.',
  ),
  Exercicio(
    id: 'elevacao-lateral',
    nome: 'Elevação lateral',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com os braços ao lado do corpo, eleve os halteres lateralmente '
        'até a altura dos ombros, sem balançar o tronco.',
  ),
  Exercicio(
    id: 'elevacao-frontal',
    nome: 'Elevação frontal',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com os halteres à frente das coxas, eleve os braços à frente até '
        'a altura dos ombros e desça controladamente.',
  ),
  Exercicio(
    id: 'remada-alta',
    nome: 'Remada alta',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.costas],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Segurando os halteres à frente do corpo, puxe os cotovelos para '
        'cima e para fora até a altura dos ombros.',
  ),
  Exercicio(
    id: 'face-pull-cabo',
    nome: 'Face pull no cabo',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.costas],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.mobilidade, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Puxe a corda em direção ao rosto, separando as mãos e '
        'contraindo a parte de trás do ombro.',
  ),
  Exercicio(
    id: 'desenvolvimento-militar-barra',
    nome: 'Desenvolvimento militar com barra',
    grupoMuscularPrincipal: GrupoMuscular.ombro,
    gruposMuscularesSecundarios: [GrupoMuscular.triceps],
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.barra,
    instrucoes:
        'Em pé, empurre a barra a partir da altura dos ombros até '
        'estender totalmente os braços acima da cabeça.',
  ),

  // Bíceps
  Exercicio(
    id: 'rosca-direta-halteres',
    nome: 'Rosca direta com halteres',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com os braços ao lado do corpo, flexione os cotovelos elevando '
        'os halteres até a altura dos ombros, sem balançar.',
  ),
  Exercicio(
    id: 'rosca-alternada',
    nome: 'Rosca alternada',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes: 'Igual à rosca direta, alternando um braço de cada vez.',
  ),
  Exercicio(
    id: 'rosca-martelo',
    nome: 'Rosca martelo',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com as palmas voltadas uma para a outra, flexione os cotovelos '
        'mantendo essa pegada neutra durante todo o movimento.',
  ),
  Exercicio(
    id: 'rosca-direta-barra',
    nome: 'Rosca direta com barra',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Com pegada supinada na barra, flexione os cotovelos elevando a '
        'barra até a altura dos ombros.',
  ),
  Exercicio(
    id: 'rosca-scott',
    nome: 'Rosca Scott',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Com o braço apoiado no banco Scott, flexione o cotovelo elevando '
        'o peso sem tirar o braço do apoio.',
  ),
  Exercicio(
    id: 'rosca-concentrada',
    nome: 'Rosca concentrada',
    grupoMuscularPrincipal: GrupoMuscular.biceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Sentada, com o cotovelo apoiado na parte interna da coxa, '
        'flexione o braço elevando o halter lentamente.',
  ),

  // Tríceps
  Exercicio(
    id: 'triceps-corda-cabo',
    nome: 'Tríceps corda no cabo',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Com os cotovelos fixos ao lado do corpo, estenda os braços '
        'empurrando a corda para baixo.',
  ),
  Exercicio(
    id: 'mergulho-banco',
    nome: 'Mergulho no banco',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    gruposMuscularesSecundarios: [GrupoMuscular.peito],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.banco,
    instrucoes:
        'Com as mãos apoiadas na borda do banco atrás do corpo, flexione '
        'os cotovelos descendo o quadril e empurre de volta para cima.',
  ),
  Exercicio(
    id: 'triceps-testa-halteres',
    nome: 'Tríceps testa com halteres',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Deitada, com os braços estendidos para cima, flexione apenas os '
        'cotovelos descendo os halteres em direção à testa.',
  ),
  Exercicio(
    id: 'triceps-frances',
    nome: 'Tríceps francês',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Em pé ou sentada, com o halter atrás da cabeça, estenda o '
        'cotovelo elevando o peso e volte controladamente.',
  ),
  Exercicio(
    id: 'flexao-braco-fechada',
    nome: 'Flexão de braço fechada',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    gruposMuscularesSecundarios: [GrupoMuscular.peito],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Como a flexão tradicional, mas com as mãos próximas, na largura '
        'dos ombros, para focar mais o tríceps.',
  ),
  Exercicio(
    id: 'triceps-coice-halter',
    nome: 'Tríceps coice com halter',
    grupoMuscularPrincipal: GrupoMuscular.triceps,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com o tronco inclinado à frente e o braço junto ao corpo, '
        'estenda o cotovelo levando o halter para trás.',
  ),

  // Perna
  Exercicio(
    id: 'agachamento-livre',
    nome: 'Agachamento livre',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Com os pés na largura dos ombros, desça flexionando quadril e '
        'joelhos como se fosse sentar, mantendo as costas retas.',
  ),
  Exercicio(
    id: 'agachamento-halteres',
    nome: 'Agachamento com halteres',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Igual ao agachamento livre, segurando um halter em cada mão ao '
        'lado do corpo para aumentar a carga.',
  ),
  Exercicio(
    id: 'afundo',
    nome: 'Afundo',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Dê um passo à frente e desça o joelho de trás em direção ao '
        'chão, mantendo o tronco ereto, depois volte à posição inicial.',
  ),
  Exercicio(
    id: 'leg-press',
    nome: 'Leg press',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    gruposMuscularesSecundarios: [GrupoMuscular.gluteo],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada na máquina, empurre a plataforma estendendo as pernas, '
        'sem travar totalmente os joelhos, e volte controladamente.',
  ),
  Exercicio(
    id: 'cadeira-extensora',
    nome: 'Cadeira extensora',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Sentada na máquina, estenda os joelhos elevando o peso e desça '
        'controladamente.',
  ),
  Exercicio(
    id: 'cadeira-flexora',
    nome: 'Cadeira flexora',
    grupoMuscularPrincipal: GrupoMuscular.perna,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Deitada ou sentada na máquina, flexione os joelhos puxando o '
        'peso em direção aos glúteos.',
  ),

  // Glúteo
  Exercicio(
    id: 'elevacao-pelvica',
    nome: 'Elevação pélvica',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Deitada com os joelhos flexionados e pés apoiados no chão, eleve '
        'o quadril contraindo os glúteos no topo do movimento.',
  ),
  Exercicio(
    id: 'elevacao-pelvica-barra',
    nome: 'Elevação pélvica com barra',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.barra,
    instrucoes:
        'Com a barra apoiada sobre o quadril e as costas apoiadas em um '
        'banco, eleve o quadril contraindo os glúteos no topo.',
  ),
  Exercicio(
    id: 'agachamento-sumo-halter',
    nome: 'Agachamento sumô com halter',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com os pés afastados e apontados para fora, segure um halter à '
        'frente do corpo e desça flexionando o quadril e os joelhos.',
  ),
  Exercicio(
    id: 'coice-cabo',
    nome: 'Coice no cabo',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.maquina,
    instrucoes:
        'Com o cabo preso no tornozelo, estenda a perna para trás '
        'contraindo o glúteo, mantendo o tronco estável.',
  ),
  Exercicio(
    id: 'abducao-quadril-elastico',
    nome: 'Abdução de quadril com elástico',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.elastico,
    instrucoes:
        'Com o elástico ao redor das pernas, abra e feche as pernas '
        'lateralmente contra a resistência.',
  ),
  Exercicio(
    id: 'stiff-halteres',
    nome: 'Stiff com halteres',
    grupoMuscularPrincipal: GrupoMuscular.gluteo,
    gruposMuscularesSecundarios: [GrupoMuscular.perna],
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.forca],
    equipamento: Equipamento.halteres,
    instrucoes:
        'Com os joelhos levemente flexionados, incline o tronco à frente '
        'descendo os halteres próximos às pernas, sentindo alongar o posterior.',
  ),

  // Abdômen
  Exercicio(
    id: 'prancha',
    nome: 'Prancha',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.mobilidade],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Apoiada nos antebraços e pontas dos pés, mantenha o corpo reto '
        'e o core contraído pelo tempo determinado.',
  ),
  Exercicio(
    id: 'prancha-lateral',
    nome: 'Prancha lateral',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.intermediario,
    objetivos: [ObjetivoExercicio.forca],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Apoiada em um antebraço e na lateral do pé, mantenha o corpo '
        'alinhado, evitando que o quadril caia.',
  ),
  Exercicio(
    id: 'abdominal-supra',
    nome: 'Abdominal supra',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Deitada com os joelhos flexionados, eleve o tronco em direção '
        'aos joelhos contraindo o abdômen, sem puxar o pescoço.',
  ),
  Exercicio(
    id: 'abdominal-infra',
    nome: 'Abdominal infra',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Deitada com as pernas estendidas, eleve-as em direção ao teto '
        'contraindo a parte inferior do abdômen, e desça sem tocar o chão.',
  ),
  Exercicio(
    id: 'bicicleta-no-chao',
    nome: 'Bicicleta no chão',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.iniciante,
    objetivos: [ObjetivoExercicio.hipertrofia, ObjetivoExercicio.emagrecimento],
    equipamento: Equipamento.nenhum,
    instrucoes:
        'Deitada, alterne levar o cotovelo em direção ao joelho oposto '
        'enquanto estende a outra perna, em um movimento de pedalada.',
  ),
  Exercicio(
    id: 'roda-abdominal',
    nome: 'Roda abdominal',
    grupoMuscularPrincipal: GrupoMuscular.abdomen,
    nivel: NivelExercicio.avancado,
    objetivos: [ObjetivoExercicio.forca, ObjetivoExercicio.hipertrofia],
    equipamento: Equipamento.outro,
    instrucoes:
        'Ajoelhada, role a roda para a frente estendendo o corpo o '
        'máximo possível sem deixar o quadril cair, depois retorne.',
  ),
];
