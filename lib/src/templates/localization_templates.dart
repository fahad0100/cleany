/// Fixed shared template module.
Map<String, String> localizationTemplates() => {
  'l10n.yaml': '''
# Flutter's official localization generator. Edit the ARB files to add messages.
arb-dir: assets/translations
template-arb-file: app_en.arb
output-dir: lib/core/localization/generated
output-localization-file: app_localizations.dart
nullable-getter: false
''',
  'assets/translations/app_en.arb': '''
{
  "@@locale": "en",
  "appTitle": "Application",
  "@appTitle": {"description": "The application's display title."},
  "welcome": "Welcome",
  "@welcome": {"description": "A greeting shown to the user."}
}
''',
  'assets/translations/app_ar.arb': '''
{
  "@@locale": "ar",
  "appTitle": "التطبيق",
  "welcome": "مرحبًا"
}
''',
};
