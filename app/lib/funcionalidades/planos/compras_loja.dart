// Assinatura pelas lojas (App Store / Google Play) com in_app_purchase.
//
// O app compra o produto e manda o recibo ao backend (/v1/assinaturas/loja), que confere
// com a loja: o direito de acesso vive no servidor. Escrito pela documentação do pacote;
// NÃO exercitado neste ambiente (exige produtos configurados nas lojas e aparelho real).
// O identificador do produto vem de --dart-define=PRODUTO_FAMILIA=<id>.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../nucleo/rede/cliente_api.dart';

const produtoFamilia = String.fromEnvironment('PRODUTO_FAMILIA');

class ComprasLoja {
  ComprasLoja(this.api);
  final ClienteApi api;
  StreamSubscription<List<PurchaseDetails>>? _assinatura;

  static bool get disponivelNestaPlataforma =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      produtoFamilia.isNotEmpty;

  /// Compra o plano Família. Conclui quando o backend confirma (ou lança erro).
  Future<void> assinarFamilia() async {
    final loja = InAppPurchase.instance;
    if (!await loja.isAvailable()) throw StateError('Loja indisponível.');
    final resposta = await loja.queryProductDetails({produtoFamilia});
    if (resposta.productDetails.isEmpty) throw StateError('Produto não encontrado na loja.');
    final concluido = Completer<void>();
    await _assinatura?.cancel();
    _assinatura = loja.purchaseStream.listen((compras) async {
      for (final c in compras) {
        if (c.productID != produtoFamilia) continue;
        if (c.status == PurchaseStatus.purchased || c.status == PurchaseStatus.restored) {
          try {
            await api.post<dynamic>(
              '/v1/assinaturas/loja',
              dados: {
                'origem': defaultTargetPlatform == TargetPlatform.iOS ? 'app_store' : 'google_play',
                'plano': 'familia',
                'produto': c.productID,
                // Apple: id da transação original; Google: token de compra.
                'recibo': defaultTargetPlatform == TargetPlatform.iOS
                    ? (c.purchaseID ?? '')
                    : c.verificationData.serverVerificationData,
              },
            );
            if (c.pendingCompletePurchase) await loja.completePurchase(c);
            if (!concluido.isCompleted) concluido.complete();
          } catch (e) {
            if (!concluido.isCompleted) concluido.completeError(e);
          }
        } else if (c.status == PurchaseStatus.error || c.status == PurchaseStatus.canceled) {
          if (!concluido.isCompleted) {
            concluido.completeError(StateError(c.error?.message ?? 'Compra não concluída.'));
          }
        }
      }
    });
    await loja.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: resposta.productDetails.first),
    );
    try {
      await concluido.future;
    } finally {
      await _assinatura?.cancel();
    }
  }
}
