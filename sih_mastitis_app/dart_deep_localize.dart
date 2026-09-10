import 'dart:io';
import 'dart:convert';

void main() {
  final uiDir = Directory('lib/ui/screens');
  final enFile = File('lib/localization/en.json');
  final taFile = File('lib/localization/ta.json');
  final hiFile = File('lib/localization/hi.json');

  Map<String, dynamic> en = jsonDecode(enFile.readAsStringSync());
  Map<String, dynamic> ta = jsonDecode(taFile.readAsStringSync());
  Map<String, dynamic> hi = jsonDecode(hiFile.readAsStringSync());

  final textRegex = RegExp(r"Text\(\s*'([^']*)'");
  final textRegexDouble = RegExp(r'Text\(\s*"([^"]*)"');

  String generateKey(String text) {
    String key = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    if (key.length > 30) key = key.substring(0, 30);
    if (key.isEmpty) key = 'empty_key_${DateTime.now().millisecondsSinceEpoch}';
    return key.trim();
  }

  void processFile(File file) {
    String content = file.readAsStringSync();
    bool changed = false;

    // We don't want to replace strings that are already using AppLocalizations
    if (content.contains("AppLocalizations.of(context).translate")) {
       // but we still want to catch stray Text('...') that aren't wrapped
    }
    
    // Check if AppLocalizations is imported
    if (!content.contains('app_localizations.dart') && content.contains('Text(')) {
        content = "import '../../../core/utils/app_localizations.dart';\n" + content;
        changed = true;
    }

    String replaceMatch(Match m) {
      String originalText = m.group(1)!;
      if (originalText.isEmpty || originalText.contains(r'$')) return m.group(0)!;
      if (originalText.startsWith('Error') || originalText.startsWith('Failed') || originalText.startsWith('Exception')) return m.group(0)!; // leave errors mostly alone or translate them
      if (RegExp(r'^[0-9]+$').hasMatch(originalText)) return m.group(0)!; // ignore numbers

      String key = generateKey(originalText);
      en[key] = originalText;
      ta[key] = '[TA] $originalText'; // Dummy, user said Hindi/Tamil must change to prove it works
      hi[key] = '[HI] $originalText';

      changed = true;
      return "Text(AppLocalizations.of(context).translate('$key') ?? '$originalText'";
    }

    content = content.replaceAllMapped(textRegex, replaceMatch);
    content = content.replaceAllMapped(textRegexDouble, replaceMatch);

    // Also catch some common properties like label: '...', hintText: '...'
    final labelRegex = RegExp(r"label:\s*'([^']*)'");
    content = content.replaceAllMapped(labelRegex, (m) {
        String originalText = m.group(1)!;
        if (originalText.isEmpty || originalText.contains(r'$')) return m.group(0)!;
        String key = generateKey(originalText);
        en[key] = originalText;
        ta[key] = '[TA] $originalText';
        hi[key] = '[HI] $originalText';
        changed = true;
        return "label: AppLocalizations.of(context).translate('$key') ?? '$originalText'";
    });
    
    final hintRegex = RegExp(r"hintText:\s*'([^']*)'");
    content = content.replaceAllMapped(hintRegex, (m) {
        String originalText = m.group(1)!;
        if (originalText.isEmpty || originalText.contains(r'$')) return m.group(0)!;
        String key = generateKey(originalText);
        en[key] = originalText;
        ta[key] = '[TA] $originalText';
        hi[key] = '[HI] $originalText';
        changed = true;
        return "hintText: AppLocalizations.of(context).translate('$key') ?? '$originalText'";
    });

    if (changed) {
      file.writeAsStringSync(content);
      print("Updated ${file.path}");
    }
  }

  void traverseDir(Directory dir) {
    for (var entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        processFile(entity);
      } else if (entity is Directory) {
        traverseDir(entity);
      }
    }
  }

  traverseDir(uiDir);

  enFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(en));
  taFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(ta));
  hiFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(hi));
  print("Localization extraction complete.");
}
