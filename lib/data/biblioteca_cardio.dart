import '../models/atividade_cardio.dart';

/// Biblioteca v1 de atividades de cardio: variações para academia e para
/// casa, cada uma marcada como baixo ou alto impacto (ver briefing do
/// produto — variações de cardio por perfil, e perfil de terceira idade).
const bibliotecaCardio = <AtividadeCardio>[
  // Academia
  AtividadeCardio(
    id: 'caminhada-esteira',
    nome: 'Caminhada na esteira',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Caminhe em ritmo constante, em inclinação leve se possível.',
  ),
  AtividadeCardio(
    id: 'bicicleta-ergometrica',
    nome: 'Bicicleta ergométrica',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Pedale em ritmo constante, ajustando a carga conforme o condicionamento.',
  ),
  AtividadeCardio(
    id: 'eliptico',
    nome: 'Elíptico',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Mantenha um ritmo constante, usando os braços e as pernas.',
  ),
  AtividadeCardio(
    id: 'corrida-esteira',
    nome: 'Corrida na esteira',
    local: LocalTreino.academia,
    baixoImpacto: false,
    instrucoes: 'Corra em ritmo confortável, aumentando a velocidade gradualmente.',
  ),

  // Casa
  AtividadeCardio(
    id: 'caminhada-ar-livre',
    nome: 'Caminhada ao ar livre',
    local: LocalTreino.casa,
    baixoImpacto: true,
    instrucoes: 'Caminhe em ritmo constante por um percurso plano.',
  ),
  AtividadeCardio(
    id: 'subir-descer-degrau',
    nome: 'Subir e descer degrau',
    local: LocalTreino.casa,
    baixoImpacto: true,
    instrucoes: 'Use um degrau ou banco baixo e estável, subindo e descendo em ritmo constante.',
  ),
  AtividadeCardio(
    id: 'polichinelo',
    nome: 'Polichinelo',
    local: LocalTreino.casa,
    baixoImpacto: false,
    duracaoMinutosSugerida: 15,
    instrucoes: 'Alterne entre pés juntos e afastados, sincronizando com os braços, em blocos de esforço.',
  ),
  AtividadeCardio(
    id: 'corrida-ar-livre',
    nome: 'Corrida ao ar livre',
    local: LocalTreino.casa,
    baixoImpacto: false,
    instrucoes: 'Corra em ritmo confortável por um percurso plano.',
  ),
];
