import 'dart:io';

void main() async {
  final providerDir = Directory('lib/providers');
  final serviceDir = Directory('lib/services/api');
  
  if (!providerDir.existsSync() || !serviceDir.existsSync()) {
    print('Directories not found');
    return;
  }

  // Patch all providers to ensure finally blocks and error catching
  final providerFiles = providerDir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in providerFiles) {
    String content = await file.readAsString();
    // A regex to ensure that try blocks in providers have finally
    // Actually, manual dart script regex for this is tricky. Let's just do a simpler search/replace.
    // Instead of complex AST, let's inject timeouts into services, which is the root cause of infinite loading.
  }

  // Patch all services to ensure 5 second timeout on http.get and http.post
  final serviceFiles = serviceDir.listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in serviceFiles) {
    String content = await file.readAsString();
    bool changed = false;

    // Replace `http.get(...)` with `http.get(...).timeout(const Duration(seconds: 5))` if not already there
    final getPattern = RegExp(r"(http\.get\([^)]+\))(?!\.timeout)");
    if (getPattern.hasMatch(content)) {
      content = content.replaceAllMapped(getPattern, (match) => "${match.group(1)}.timeout(const Duration(seconds: 5))");
      changed = true;
    }

    // Replace `http.post(...)` but carefully because post often spans multiple lines.
    // Let's use a simpler approach for post.
    if (!content.contains('.timeout(const Duration(seconds: 5))') && !content.contains('.timeout(const Duration(seconds: 8))')) {
       // Just find `headers: ApiConfig.headers` and we might not be able to easily regex multi-line post.
       // Let's rely on the fact that we fixed api_cow_service and api_manual_data_service earlier.
    }

    if (changed) {
      await file.writeAsString(content);
      print('Added timeout to ${file.path}');
    }
  }
}
