import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> salvarArquivo(List<int> bytes, String nome, String tipo) async {
  await SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(Uint8List.fromList(bytes), mimeType: tipo, name: nome)],
    fileNameOverrides: [nome],
  ));
}
