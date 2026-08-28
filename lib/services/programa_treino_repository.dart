import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkin_progresso.dart';
import '../models/estrategia_bloco.dart';
import '../models/exercicio.dart';
import '../models/programa_treino.dart';
import '../models/registro_medidas.dart';
import 'progresso_repository.dart';
import 'sincronizador_dados.dart';

/// Persiste o estado do programa de treino de longo prazo e aplica as
/// regras de progressão a cada check-in (ver `CheckinProgresso` /
/// `EstrategiaBloco`).
class ProgramaTreinoRepository {
  ProgramaTreinoRepository({ProgressoRepository? progressoRepositorio})
    : progressoRepositorio = progressoRepositorio ?? ProgressoRepository();

  final ProgressoRepository progressoRepositorio;

  static const _chave = 'programa_treino';

  Future<ProgramaTreino?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return null;
    return ProgramaTreino.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
  }

  Future<void> _salvar(ProgramaTreino programa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(programa.toJson()));
    await SincronizadorDados.instancia.aposEscrita(_chave);
  }

  /// Cria o programa na primeira vez que a usuária vê a ficha; nas
  /// próximas, devolve o que já existe.
  Future<ProgramaTreino> iniciarSeNecessario() async {
    final existente = await carregar();
    if (existente != null) return existente;

    final agora = DateTime.now();
    final novo = ProgramaTreino(
      iniciadoEm: agora,
      blocoAtual: 1,
      blocoIniciadoEm: agora,
      nivelLiberado: NivelExercicio.iniciante,
    );
    await _salvar(novo);
    return novo;
  }

  /// Estratégia do bloco atual — usada para gerar a ficha na aba Minha
  /// ficha. Não altera o estado.
  Future<EstrategiaBloco> estrategiaAtual() async {
    final programa = await iniciarSeNecessario();
    return calcularEstrategiaBloco(
      bloco: programa.blocoAtual,
      nivelLiberado: programa.nivelLiberado,
      ultimoCheckin: programa.ultimoCheckin,
    );
  }

  /// Registra o check-in de fim de bloco: grava peso/medidas na aba
  /// Progresso, avança o bloco, sobe de nível se for o caso e devolve a
  /// estratégia da nova ficha.
  Future<EstrategiaBloco> registrarCheckin(CheckinProgresso checkin) async {
    final atual = await iniciarSeNecessario();

    if (checkin.pesoKg != null) {
      await progressoRepositorio.registrarPeso(checkin.pesoKg!, data: checkin.data);
    }
    final medidas = RegistroMedidas(
      data: checkin.data,
      cinturaCm: checkin.cinturaCm,
      quadrilCm: checkin.quadrilCm,
      bracoCm: checkin.bracoCm,
      coxaCm: checkin.coxaCm,
    );
    if (!medidas.vazio) {
      await progressoRepositorio.registrarMedidas(medidas);
    }

    var nivel = atual.nivelLiberado;
    final progrediu = checkin.dificuldade == DificuldadeTreino.facilDemais &&
        checkin.recuperacao == Recuperacao.bemRecuperada &&
        checkin.aderencia == AderenciaPercebida.quaseTudo;
    if (progrediu && nivel != NivelExercicio.avancado) {
      nivel = NivelExercicio.values[nivel.index + 1];
    }

    final proximoBloco = atual.blocoAtual + 1;
    final atualizado = atual.copyWith(
      blocoAtual: proximoBloco,
      blocoIniciadoEm: checkin.data,
      nivelLiberado: nivel,
      checkins: [...atual.checkins, checkin],
    );
    await _salvar(atualizado);

    return calcularEstrategiaBloco(
      bloco: proximoBloco,
      nivelLiberado: nivel,
      ultimoCheckin: checkin,
    );
  }

  /// Reset manual (botão "recomeçar programa" no Perfil). A anamnese e o
  /// histórico de progresso não são apagados.
  Future<void> recomecarPrograma() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
