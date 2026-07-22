import '../models/suplemento.dart';

/// Biblioteca v1 de suplementos: conteúdo educativo geral, sem dosagem
/// nem recomendação individualizada (ver Suplemento e briefing do
/// produto — precisa de validação profissional antes de virar conteúdo
/// prescritivo).
const bibliotecaSuplementos = <Suplemento>[
  Suplemento(
    id: 'whey-protein',
    nome: 'Whey protein',
    tipo: TipoSuplemento.proteina,
    descricao:
        'Proteína derivada do soro do leite, usada como forma prática de '
        'complementar a ingestão diária de proteína quando a alimentação '
        'sozinha não é suficiente. Existem versões com e sem lactose. Não '
        'substitui proteína de fontes alimentares — é um complemento.',
  ),
  Suplemento(
    id: 'proteina-vegetal',
    nome: 'Proteína vegetal (ervilha, arroz, soja)',
    tipo: TipoSuplemento.proteina,
    descricao:
        'Alternativa ao whey para quem tem restrição a laticínios ou segue '
        'dieta vegetariana/vegana, combinando proteínas de diferentes '
        'fontes vegetais para um perfil de aminoácidos mais completo.',
  ),
  Suplemento(
    id: 'creatina',
    nome: 'Creatina',
    tipo: TipoSuplemento.creatina,
    descricao:
        'Um dos suplementos mais estudados para desempenho em treinos de '
        'força — associado a ganhos de força e massa muscular ao longo do '
        'tempo, quando combinado com treino regular. Segura para a maioria '
        'das pessoas saudáveis, mas pessoas com condições renais devem '
        'conversar com um médico antes de usar.',
  ),
  Suplemento(
    id: 'multivitaminico',
    nome: 'Multivitamínico',
    tipo: TipoSuplemento.vitaminaMineral,
    descricao:
        'Combinação de vitaminas e minerais usada para cobrir possíveis '
        'lacunas nutricionais da alimentação do dia a dia. Especialmente '
        'relevante após cirurgia bariátrica, onde a absorção de nutrientes '
        'muda — nesse caso, a reposição costuma ser acompanhada de perto '
        'por exames periódicos pedidos pela equipe médica.',
  ),
  Suplemento(
    id: 'omega-3',
    nome: 'Ômega-3',
    tipo: TipoSuplemento.acidoGraxo,
    descricao:
        'Ácido graxo essencial, associado a benefícios cardiovasculares e '
        'anti-inflamatórios gerais. Presente naturalmente em peixes '
        'gordurosos e sementes como linhaça e chia — o suplemento é uma '
        'opção para quem não consome essas fontes com frequência.',
  ),
];
