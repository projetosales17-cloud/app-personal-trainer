# App Personal Trainer Online

App "personal trainer online completo" (treino, alimentação, progresso e
suporte por IA), vendido diretamente ao consumidor final. Público-alvo
principal: mulheres, cobrindo emagrecimento/reeducação alimentar (incluindo
menopausa e sobrepeso), hipertrofia, performance atlética e perfil
pós-bariátrica.

Uma única base de código em Flutter gera o app para **Android, iOS,
Windows e macOS**.

> Builds de iOS e macOS exigem um Mac com Xcode — não podem ser gerados a
> partir de Windows/Linux.

## Status atual

Estrutura inicial de navegação com as 6 seções principais definidas no
briefing do produto (Home, Treino, Alimentação, Progresso, Orientações,
Perfil), ainda como telas placeholder. Nenhuma funcionalidade de
onboarding, anamnese, biblioteca de exercícios, licenciamento ou
assinatura foi implementada ainda.

## Rodando o projeto

```bash
flutter pub get
flutter run -d windows   # ou -d chrome, -d android, etc.
```

## Rodando os testes

```bash
flutter analyze
flutter test
```
