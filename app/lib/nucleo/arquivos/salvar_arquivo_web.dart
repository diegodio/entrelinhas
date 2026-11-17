import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> salvarArquivo(List<int> bytes, String nome, String tipo) async {
  final blob = web.Blob([Uint8List.fromList(bytes).toJS].toJS, web.BlobPropertyBag(type: tipo));
  final url = web.URL.createObjectURL(blob);
  final ancora = web.HTMLAnchorElement()
    ..href = url
    ..download = nome;
  web.document.body?.append(ancora);
  ancora.click();
  ancora.remove();
  web.URL.revokeObjectURL(url);
}
