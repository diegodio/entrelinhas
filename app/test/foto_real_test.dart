import 'dart:io';

import 'package:entrelinhas/simples/ean13.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lê o código de uma foto real (verso do Murdoku, celular)', () async {
    final bytes = File('test/dados/murdoku_verso.jpg').readAsBytesSync();
    expect(await lerEan13DeFoto(bytes), '9788543111537');
  });
}
