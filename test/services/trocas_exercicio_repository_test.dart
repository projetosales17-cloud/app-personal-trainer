import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_personal_trainer/services/trocas_exercicio_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final repositorio = TrocasExercicioRepository();

  test('sem nada salvo, carregar devolve mapa vazio', () async {
    expect(await repositorio.carregar(), isEmpty);
  });

  test('trocar guarda o par original -> substituto', () async {
    await repositorio.trocar('agachamento-livre', 'agachamento-cadeira');
    expect(await repositorio.carregar(), {'agachamento-livre': 'agachamento-cadeira'});
  });

  test('trocar de novo o mesmo original substitui o valor', () async {
    await repositorio.trocar('supino-reto-barra', 'flexao-de-braco');
    await repositorio.trocar('supino-reto-barra', 'supino-reto-halteres');
    expect(await repositorio.carregar(), {'supino-reto-barra': 'supino-reto-halteres'});
  });

  test('desfazer remove só aquele par', () async {
    await repositorio.trocar('a', '1');
    await repositorio.trocar('b', '2');
    await repositorio.desfazer('a');
    expect(await repositorio.carregar(), {'b': '2'});
  });

  test('limparTudo zera o mapa', () async {
    await repositorio.trocar('a', '1');
    await repositorio.trocar('b', '2');
    await repositorio.limparTudo();
    expect(await repositorio.carregar(), isEmpty);
  });
}
