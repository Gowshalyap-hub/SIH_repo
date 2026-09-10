import 'dart:convert';
import 'dart:io';

void main() async {
  final enFile = File('lib/localization/en.json');
  final taFile = File('lib/localization/ta.json');
  final hiFile = File('lib/localization/hi.json');
  
  Map<String, dynamic> enMap = jsonDecode(await enFile.readAsString());
  Map<String, dynamic> taMap = jsonDecode(await taFile.readAsString());
  Map<String, dynamic> hiMap = jsonDecode(await hiFile.readAsString());

  final dir = Directory('lib/ui/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final stringRegex = RegExp(r"Text\(\s*'([^'\$]+)'\s*\)");
  final stringRegexDouble = RegExp(r'Text\(\s*"([^"\$]+)"\s*\)');
  
  final appButtonRegex = RegExp(r"AppButton\(\s*text:\s*'([^'\$]+)'");
  final appButtonRegexDouble = RegExp(r'AppButton\(\s*text:\s*"([^"\$]+)"');
  
  final appBarRegex = RegExp(r"AppBar\(\s*title:\s*const Text\('([^'\$]+)'\)");

  for (final f in files) {
    String content = await f.readAsString();
    bool changed = false;

    if (!content.contains('app_localizations.dart')) {
      content = content.replaceFirst(
        RegExp(r"(import 'package:flutter/material\.dart';)"),
        "import 'package:flutter/material.dart';\nimport 'package:sih_mastitis_app/core/utils/app_localizations.dart';"
      );
    }

    // Helper to process regex
    content = content.replaceAllMapped(stringRegex, (match) {
      final original = match.group(1)!;
      final key = original.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      if (!enMap.containsKey(key)) {
        enMap[key] = original;
        taMap[key] = original; // fallback
        hiMap[key] = original; // fallback
      }
      changed = true;
      return "Text(AppLocalizations.of(context).translate('$key'))";
    });

    content = content.replaceAllMapped(stringRegexDouble, (match) {
      final original = match.group(1)!;
      final key = original.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      if (!enMap.containsKey(key)) {
        enMap[key] = original;
        taMap[key] = original;
        hiMap[key] = original;
      }
      changed = true;
      return "Text(AppLocalizations.of(context).translate('$key'))";
    });

    content = content.replaceAllMapped(appButtonRegex, (match) {
      final original = match.group(1)!;
      final key = original.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      if (!enMap.containsKey(key)) {
        enMap[key] = original;
        taMap[key] = original;
        hiMap[key] = original;
      }
      changed = true;
      return "AppButton(text: AppLocalizations.of(context).translate('$key')";
    });

    content = content.replaceAllMapped(appBarRegex, (match) {
      final original = match.group(1)!;
      final key = original.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      if (!enMap.containsKey(key)) {
        enMap[key] = original;
        taMap[key] = original;
        hiMap[key] = original;
      }
      changed = true;
      return "AppBar(title: Text(AppLocalizations.of(context).translate('$key'))";
    });

    if (changed) {
      // Remove any bad consts
      content = content.replaceAll("const Text(AppLocalizations", "Text(AppLocalizations");
      await f.writeAsString(content);
      print('Localized ${f.path}');
    }
  }

  await enFile.writeAsString(JsonEncoder.withIndent('  ').convert(enMap));
  await taFile.writeAsString(JsonEncoder.withIndent('  ').convert(taMap));
  await hiFile.writeAsString(JsonEncoder.withIndent('  ').convert(hiMap));
}
