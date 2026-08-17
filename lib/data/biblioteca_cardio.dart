import '../models/atividade_cardio.dart';

/// Biblioteca v1 de atividades de cardio: variações para academia e para
/// casa, cada uma marcada como baixo ou alto impacto (ver briefing do
/// produto — variações de cardio por perfil, e perfil de terceira idade).
const bibliotecaCardio = <AtividadeCardio>[
  // Academia
  AtividadeCardio(
    id: 'caminhada-esteira',
    nome: 'Caminata en la caminadora',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Camina a un ritmo constante, con una inclinación leve si es posible.',
  ),
  AtividadeCardio(
    id: 'bicicleta-ergometrica',
    nome: 'Bicicleta estática',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Pedalea a un ritmo constante, ajustando la resistencia según tu condición física.',
  ),
  AtividadeCardio(
    id: 'eliptico',
    nome: 'Elíptica',
    local: LocalTreino.academia,
    baixoImpacto: true,
    instrucoes: 'Mantén un ritmo constante, usando los brazos y las piernas.',
  ),
  AtividadeCardio(
    id: 'corrida-esteira',
    nome: 'Carrera en la caminadora',
    local: LocalTreino.academia,
    baixoImpacto: false,
    instrucoes: 'Corre a un ritmo cómodo, aumentando la velocidad gradualmente.',
  ),

  // Casa
  AtividadeCardio(
    id: 'caminhada-ar-livre',
    nome: 'Caminata al aire libre',
    local: LocalTreino.casa,
    baixoImpacto: true,
    instrucoes: 'Camina a un ritmo constante por un recorrido plano.',
  ),
  AtividadeCardio(
    id: 'subir-descer-degrau',
    nome: 'Subir y bajar un escalón',
    local: LocalTreino.casa,
    baixoImpacto: true,
    instrucoes: 'Usa un escalón o banco bajo y estable, subiendo y bajando a un ritmo constante.',
  ),
  AtividadeCardio(
    id: 'polichinelo',
    nome: 'Saltos de tijera',
    local: LocalTreino.casa,
    baixoImpacto: false,
    duracaoMinutosSugerida: 15,
    instrucoes: 'Alterna entre pies juntos y separados, sincronizando con los brazos, en bloques de esfuerzo.',
  ),
  AtividadeCardio(
    id: 'corrida-ar-livre',
    nome: 'Carrera al aire libre',
    local: LocalTreino.casa,
    baixoImpacto: false,
    instrucoes: 'Corre a un ritmo cómodo por un recorrido plano.',
  ),
];
