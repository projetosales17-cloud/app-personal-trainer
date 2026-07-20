/// Frequência cardíaca máxima e zonas de treino.
///
/// Usa a fórmula clássica (220 - idade) para estimar a frequência cardíaca
/// máxima e divide o resultado em cinco zonas de intensidade, como
/// referência geral para orientar o treino.
library;

const _zonas = [
  ('Zona 1 - Recuperação (50-60%)', 0.5, 0.6),
  ('Zona 2 - Leve (60-70%)', 0.6, 0.7),
  ('Zona 3 - Moderada (70-80%)', 0.7, 0.8),
  ('Zona 4 - Intensa (80-90%)', 0.8, 0.9),
  ('Zona 5 - Máxima (90-100%)', 0.9, 1.0),
];

int calcularFcMaxima(int idade) {
  if (idade <= 0) {
    throw ArgumentError('Idade deve ser um valor positivo');
  }
  return 220 - idade;
}

/// Retorna, para cada zona, um par (batimento mínimo, batimento máximo).
Map<String, (int, int)> calcularZonasTreino(int fcMaxima) {
  if (fcMaxima <= 0) {
    throw ArgumentError('FC máxima deve ser um valor positivo');
  }
  return {
    for (final (nome, limiteInferior, limiteSuperior) in _zonas)
      nome: (
        (fcMaxima * limiteInferior).round(),
        (fcMaxima * limiteSuperior).round(),
      ),
  };
}
