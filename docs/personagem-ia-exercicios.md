# Ficha da personagem — demonstração de exercícios por IA

> Documento de referência para gerar as imagens reais de demonstração de exercício (ver `Exercicio.caminhoImagem` em `lib/models/exercicio.dart`). Objetivo: a **mesma personagem, consistente, aparece em todas as imagens da biblioteca de exercícios** — ver decisão no briefing do produto ("imagens geradas por IA, personagem consistente" em vez de vídeo/GIF).
>
> Este documento não gera as imagens — é o material para colar em qualquer ferramenta de geração de imagem (Leonardo AI, Midjourney, Gemini/ImageFX, etc.).

## Status (2026-07-22)

**Primeiro lote gerado e integrado**: 8 imagens (uma por grupo muscular, não por exercício individual ainda) via **Google Flow** (`labs.google/fx`, sucessor do ImageFX — ver seção 6), usando o recurso "Personagens" do Flow para manter a referência entre gerações. Substituíram as ilustrações SVG interinas como `GrupoMuscular.ilustracaoPadrao` (`lib/models/exercicio.dart`), em `assets/personagem/*.jpg`.

Notas do processo real:
- O prompt base funcionou bem para consistência de rosto/roupa/estilo entre poses diferentes.
- Controle fino de pose (mãos exatas, ângulo exato dos braços) levou 1-3 tentativas por imagem — normal, não é falha da ferramenta.
- Pequena variação notada: a imagem de bíceps saiu com braços mais definidos/musculosos que as demais (a IA "flexionou" mais ao interpretar "bicep curl position"). Aceitável por ora, mas se for gerar novo lote, vale adicionar "consistent moderate muscle tone, not more defined than in other poses" ao prompt dessa pose especificamente.
- Baixar a imagem certa do histórico do Flow por navegação/hover foi pouco confiável (a ferramenta às vezes ativa o botão de download de uma miniatura diferente da que parece selecionada). O método confiável foi: gerar a pose, conferir visualmente o resultado ainda fresco na tela, e baixar imediatamente — não confiar em voltar ao histórico depois.

## Status (2026-07-23)

**Segundo lote gerado e integrado**: as 7 imagens individuais do grupo **Peito** (flexão de braço, flexão com pés elevados, supino reto com halteres, supino reto com barra, crucifixo com halteres, crossover no cabo, crucifixo com elástico), via Google Flow, usando o recurso "Personagens" nativo do Flow (`@Yara` no prompt) em vez de re-descrever a personagem em texto a cada geração — mesma consistência visual, menos repetição. `Exercicio.caminhoImagem` de cada um dos 7 exercícios de Peito em `lib/data/biblioteca_exercicios.dart` aponta para `assets/personagem/<id-do-exercicio>.jpg`.

Notas do processo desta rodada:
- O botão de download do Flow falhou silenciosamente quando clicado via automação (sem diálogo, sem erro, sem arquivo salvo) — o clique manual do usuário no mesmo botão funcionou normalmente todas as vezes. Causa não identificada. Fluxo que funcionou: gero e escolho a melhor variante, aviso qual botão clicar, o usuário clica "Baixar" → "1K — Tamanho original", confirmo o arquivo em `Downloads` e movo/renomeio pra `assets/personagem/`.
- O menu de download tem 3 opções de resolução (1K/2K/4K) — usar sempre **1K "Tamanho original"** (2K/4K exigem plano pago).
- Todas as 7 imagens vieram anatomicamente corretas já na primeira geração (pegada, cotovelos, apoio dos pés, sem punhos torcidos), sem precisar reforçar prompt negativo.

**Ainda não feito**: imagens por exercício individual dos outros 7 grupos musculares (Costas, Ombro, Bíceps, Tríceps, Perna, Glúteo, Abdômen) — ~48 exercícios da biblioteca continuam sem `caminhoImagem` próprio, usando a ilustração genérica do grupo.

## 1. Personagem — descrição fixa

Nome de referência interno: **Yara** (só para facilitar comunicação — não aparece no app).

- Mulher brasileira, aparência entre 30 e 35 anos — idade que soa acessível para a maioria dos perfis do app (emagrecimento, hipertrofia, menopausa, pós-bariátrica, terceira idade), sem parecer nem adolescente nem sênior.
- Pele morena clara, tom médio.
- Cabelo castanho escuro, ondulado/cacheado, preso em rabo de cavalo alto (além de combinar com o contexto de treino, um penteado preso ajuda a manter a consistência entre gerações — cabelo solto varia muito de uma imagem pra outra).
- Compleição atlética, mas realista — evitar padrão de fisiculturista. A maioria das usuárias do app não está buscando hipertrofia extrema, e a personagem precisa parecer alcançável pra quem está começando.
- Expressão facial confiante e acolhedora, leve sorriso — tom de "personal trainer" e não de "modelo".

## 2. Roupa e paleta de cores

Usar as cores da identidade visual do app (`lib/tema.dart`, cor-semente `#B0305A`, framboesa/vinho):

- Top de treino (regata ou cropped) na cor vinho/framboesa `#B0305A`.
- Legging preta ou cinza-chumbo.
- Tênis branco.
- Sem estampas, logos ou textos na roupa.

## 3. Estilo visual

**Recomendado: ilustração vetorial/flat moderna com sombreamento leve (semi-flat)** — não fotorrealista.

Por quê:
- Mais fácil manter consistência entre dezenas de gerações — fotorrealismo tende a "derivar" (rosto, proporções) de uma imagem pra outra, exigindo muito mais retrabalho.
- Combina com a estética limpa que já existe no app (Material 3, cores planas).
- Evita o "uncanny valley" de fotorrealismo com pequenos erros de anatomia que a IA comete com frequência.

Se preferir fotorrealismo mesmo assim, o mesmo texto da seção 1-2 funciona — só troque a instrução de estilo (seção 4) por algo como "realistic photography, studio lighting, fitness photoshoot style".

## 4. Prompt base (template)

Use isto como ponto de partida, trocando só o trecho `[POSE]` para cada exercício:

```
Yara, a Brazilian woman in her early 30s, warm and confident expression,
medium-light brown skin tone, dark brown wavy hair in a high ponytail,
realistic athletic build (not overly muscular), wearing a wine-red
(#B0305A) fitness tank top, dark gray leggings, and white sneakers.
Clean modern semi-flat vector illustration style with soft shading,
plain light gray background, full body view, no text, no logos.

Pose: [POSE]
```

### Sugestões de `[POSE]` por grupo muscular

| Grupo muscular | Sugestão de pose |
|---|---|
| Peito | em pé, de frente, braços estendidos à frente na altura do peito |
| Costas | tronco levemente inclinado à frente, um braço puxando em direção à cintura |
| Ombro | em pé, de frente, braços estendidos para cima acima da cabeça |
| Bíceps | em pé, de frente, um braço flexionado com a mão próxima ao ombro |
| Tríceps | em pé, de perfil, um braço estendido para trás/para cima |
| Perna | de perfil, agachada, joelho à frente, um braço estendido para o equilíbrio |
| Glúteo | deitada de lado, quadril elevado, joelhos flexionados (ponte) |
| Abdômen | deitada de costas, joelhos flexionados, tronco curvado em direção aos joelhos |

Para exercícios específicos (ex: agachamento com halteres vs. agachamento livre), adicione detalhes ao final do prompt — "segurando um halter em cada mão", "com um elástico ao redor das pernas", etc.

## 5. Prompt negativo (quando a ferramenta aceitar)

```
text, watermark, logo, multiple people, extra limbs, distorted hands,
photorealistic skin pores, extreme muscle definition, medical equipment,
different hairstyle, different skin tone, different outfit color
```

## 6. Como manter a personagem consistente por ferramenta

- **Leonardo AI**: gere a primeira imagem com o prompt base (pose neutra, em pé). Depois, use o recurso de **Character Reference** (ou "Elements", dependendo da versão) apontando pra essa primeira imagem em todas as gerações seguintes.
- **Midjourney (V7)**: gere a imagem de referência primeiro. Nas gerações seguintes, adicione `--cref [URL da imagem de referência]` ao final do prompt (Omni Reference) — isso é o que mais preserva o rosto/roupa entre poses diferentes.
- **Google Gemini / ImageFX**: faça upload da imagem de referência junto com o prompt de texto descrevendo a nova pose — o modelo usa a imagem como âncora de consistência.

Em qualquer ferramenta: gere a **imagem de referência primeiro** (pose neutra, em pé, de frente) antes de gerar as poses específicas de cada exercício — isso dá à ferramenta uma âncora visual clara pra manter entre as gerações.

## 7. Formato de entrega (para eu integrar no app)

Para imagens **por exercício individual** (próximo passo, ainda não feito):
- Formato: PNG/JPG com fundo liso claro (fundo transparente também funciona).
- Nome do arquivo: usar o mesmo `id` do exercício em `lib/data/biblioteca_exercicios.dart` (ex: `flexao-de-braco.jpg`, `agachamento-livre.jpg`) — assim a integração é direta, sem precisar mapear manualmente.
- Não precisa ser tudo de uma vez — dá pra integrar aos poucos, grupo muscular por grupo muscular.

Quando tiver os arquivos, é só me avisar onde estão (pasta local) que eu:
1. Copio pra `assets/personagem/`.
2. Atualizo `Exercicio.caminhoImagem` de cada exercício correspondente em `lib/data/biblioteca_exercicios.dart`.
3. Rodo os testes pra confirmar que nada quebrou.
