import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_personal_trainer/models/orientacao.dart';
import 'package:app_personal_trainer/screens/orientacao_detalhe_screen.dart';

const _semVideo = Orientacao(
  id: 'exemplo-sem-video',
  titulo: 'Exemplo sem vídeo',
  tema: TemaOrientacao.habitos,
  corpo: 'Corpo do texto.',
);

const _comVideo = Orientacao(
  id: 'exemplo-com-video',
  titulo: 'Exemplo com vídeo',
  tema: TemaOrientacao.habitos,
  corpo: 'Corpo do texto.',
  urlVideo: 'https://exemplo.com/video.mp4',
);

const _faq = Orientacao(
  id: 'exemplo-faq',
  titulo: 'Pergunta de exemplo?',
  tema: TemaOrientacao.treino,
  tipo: TipoConteudoOrientacao.faq,
  corpo: 'Resposta de exemplo.',
);

void main() {
  testWidgets('Sem vídeo, mostra aviso e nenhum botão de assistir', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacaoDetalheScreen(orientacao: _semVideo)));

    expect(find.text('Vídeo em breve.'), findsOneWidget);
    expect(find.text('Assistir vídeo'), findsNothing);
  });

  testWidgets('Com vídeo, mostra o botão de assistir e nenhum aviso', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacaoDetalheScreen(orientacao: _comVideo)));

    expect(find.text('Assistir vídeo'), findsOneWidget);
    expect(find.text('Vídeo em breve.'), findsNothing);
  });

  testWidgets('Conteúdo FAQ mostra o selo "FAQ"', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrientacaoDetalheScreen(orientacao: _faq)));

    expect(find.text('FAQ'), findsOneWidget);
  });
}
