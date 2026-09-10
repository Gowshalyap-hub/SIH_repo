import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('lib/localization/en.json');
  final jsonString = await file.readAsString();
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  final Map<String, String> reverseMap = {};
  for (final entry in jsonMap.entries) {
    reverseMap[entry.value.toString()] = entry.key;
  }

  // Common UI strings not yet in en.json
  final extras = {
    'Add New Cow': 'add_new_cow',
    'Log Sensor Reading': 'log_sensor_reading',
    'Save Cow': 'save_cow',
    'Save Reading': 'save_reading',
    'Tag Number *': 'tag_number',
    'Breed': 'breed',
    'Birth Date': 'birth_date',
    'Body Temp (°C)': 'body_temp',
    'Udder Temp (°C)': 'udder_temp',
    'Activity Level': 'activity_level',
  };
  
  extras.forEach((val, key) {
    reverseMap[val] = key;
    jsonMap[key] = val;
  });

  // Save en.json back
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(jsonMap));

  final dir = Directory('lib/ui/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final f in files) {
    String content = await f.readAsString();
    bool changed = false;

    // Check if we need to import localization
    if (!content.contains('app_localizations.dart')) {
      content = content.replaceFirst(
        RegExp(r"(import 'package:flutter/material\.dart';)"),
        "import 'package:flutter/material.dart';\nimport '../../../core/utils/app_localizations.dart';"
      );
    }

    for (final entry in reverseMap.entries) {
      final val = entry.key;
      final k = entry.value;

      final patterns = [
        "Text('$val')", "const Text('$val')",
        "Text(\"$val\")", "const Text(\"$val\")"
      ];
      
      final replacement = "Text(AppLocalizations.of(context).translate('$k'))";

      for (var p in patterns) {
        if (content.contains(p)) {
          content = content.replaceAll(p, replacement);
          changed = true;
        }
      }
      
      final p3 = "AppButton(text: '$val'";
      final r3 = "AppButton(text: AppLocalizations.of(context).translate('$k')";
      if (content.contains(p3)) {
        content = content.replaceAll(p3, r3);
        changed = true;
      }
    }

    if (changed) {
      content = content.replaceAll(RegExp(r"const\s+Text\(AppLocalizations\.of"), "Text(AppLocalizations.of");
      await f.writeAsString(content);
      print('Updated ${f.path}');
    }
  }
}
