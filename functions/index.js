const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const hotmartHottok = defineSecret("HOTMART_HOTTOK");

// Eventos que liberam o acesso (compra aprovada/concluída, inclusive
// renovações de assinatura, que também disparam esses eventos).
const EVENTOS_LIBERAM_ACESSO = new Set(["PURCHASE_APPROVED", "PURCHASE_COMPLETE"]);

// Eventos que revogam o acesso (cancelamento, reembolso, chargeback,
// assinatura vencida/atrasada, disputa).
const EVENTOS_REVOGAM_ACESSO = new Set([
  "PURCHASE_CANCELED",
  "PURCHASE_REFUNDED",
  "PURCHASE_CHARGEBACK",
  "PURCHASE_EXPIRED",
  "PURCHASE_PROTEST",
  "PURCHASE_DELAYED",
]);

async function buscarOuCriarUsuario(email) {
  try {
    return await admin.auth().getUserByEmail(email);
  } catch (erro) {
    if (erro.code === "auth/user-not-found") {
      return await admin.auth().createUser({email});
    }
    throw erro;
  }
}

async function definirAssinatura(email, ativa, detalhes) {
  const usuario = await buscarOuCriarUsuario(email);
  await admin
      .firestore()
      .collection("assinaturas")
      .doc(usuario.uid)
      .set(
          {
            ativa,
            email,
            ...detalhes,
            atualizadoEm: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
      );
  return usuario.uid;
}

/**
 * Recebe o webhook (Postback) da Hotmart quando uma compra do MiPersonal
 * muda de status, e libera ou revoga o acesso ao app em
 * `assinaturas/{uid}.ativa` de acordo com o evento.
 *
 * Configuração no Hotmart: URL desta function + o segredo HOTMART_HOTTOK
 * (definido via `firebase functions:secrets:set HOTMART_HOTTOK`) deve
 * bater com o Hottok mostrado na tela de configuração do Webhook.
 */
exports.hotmartWebhook = onRequest(
    {secrets: [hotmartHottok], region: "us-central1"},
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Method not allowed");
        return;
      }

      const hottokRecebido = req.get("X-HOTMART-HOTTOK") || req.body?.hottok;
      if (hottokRecebido !== hotmartHottok.value()) {
        logger.warn("Hottok inválido recebido no webhook da Hotmart.");
        res.status(401).send("Invalid hottok");
        return;
      }

      const evento = req.body?.event;
      const email = req.body?.data?.buyer?.email;
      const transacao = req.body?.data?.purchase?.transaction;
      const status = req.body?.data?.purchase?.status;

      if (!evento || !email) {
        logger.warn("Payload do webhook sem 'event' ou 'buyer.email'.", {body: req.body});
        res.status(400).send("Missing event or buyer email");
        return;
      }

      const detalhes = {
        hotmartEvento: evento,
        hotmartStatus: status ?? null,
        hotmartTransacao: transacao ?? null,
      };

      try {
        if (EVENTOS_LIBERAM_ACESSO.has(evento)) {
          const uid = await definirAssinatura(email, true, detalhes);
          logger.info(`Acesso liberado para ${email} (uid ${uid}) — evento ${evento}.`);
        } else if (EVENTOS_REVOGAM_ACESSO.has(evento)) {
          const uid = await definirAssinatura(email, false, detalhes);
          logger.info(`Acesso revogado para ${email} (uid ${uid}) — evento ${evento}.`);
        } else {
          logger.info(`Evento ${evento} recebido, sem ação (ex: boleto emitido).`);
        }
        res.status(200).send("OK");
      } catch (erro) {
        logger.error("Erro ao processar webhook da Hotmart.", erro);
        res.status(500).send("Internal error");
      }
    },
);
