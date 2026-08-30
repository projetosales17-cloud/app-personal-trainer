/// Gera um id único para um registro salvo pela usuária (diário, peso,
/// medidas, carga, vídeo). Timestamp em microssegundos + um contador de
/// sessão — assim vários registros criados no mesmo instante (testes,
/// importações) não colidem.
///
/// Registros antigos, salvos antes do campo `id` existir, caem no
/// timestamp ISO como id (ver os `fromJson` dos modelos) — estável e
/// único na prática para entradas feitas à mão.
int _sequencia = 0;

String gerarIdRegistro() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_sequencia++}';
