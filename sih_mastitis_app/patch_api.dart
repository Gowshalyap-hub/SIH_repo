import 'dart:io';

void main() async {
  final serviceDir = Directory('lib/services/api');
  final serviceFiles = serviceDir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in serviceFiles) {
    String content = await file.readAsString();
    bool changed = false;

    // Add timeouts to http.get
    final getRegex = RegExp(r"(http\.get\([^)]+\))(?!\.timeout)");
    if (getRegex.hasMatch(content)) {
      content = content.replaceAllMapped(getRegex, (m) => "${m.group(1)}.timeout(const Duration(seconds: 5))");
      changed = true;
    }

    // Add timeouts to http.post that are on a single line for simplicity
    final postRegex = RegExp(r"(http\.post\([^)]+\))(?!\.timeout)");
    if (postRegex.hasMatch(content)) {
      content = content.replaceAllMapped(postRegex, (m) => "${m.group(1)}.timeout(const Duration(seconds: 5))");
      changed = true;
    }

    if (changed) {
      await file.writeAsString(content);
      print('Patched timeouts in ${file.path}');
    }
  }
}
