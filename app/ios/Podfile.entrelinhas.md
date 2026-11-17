# iOS: notas de configuração

- `permission_handler` exige ativar as permissões usadas no Podfile (gerado no primeiro
  `pod install`). Acrescente ao `post_install`:

  ```ruby
  target.build_configurations.each do |config|
    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'PERMISSION_CAMERA=1', 'PERMISSION_PHOTOS=1']
  end
  ```
- ML Kit exige iOS 15.5 ou superior: `platform :ios, '15.5'` no Podfile.
- Não verificado neste ambiente (sem macOS/Xcode). Ver docs/como-rodar.md.
