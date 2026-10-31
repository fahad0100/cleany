import 'dart:convert';
import 'dart:io';

import 'project.dart';
import 'workspace.dart';

/// Durable recovery metadata. Backups are retained if neither snapshot is valid.
/// File transitions are appended, avoiding a full manifest rewrite per file.
class JournalStore {
  JournalStore(this.project, this.root);
  final Project project;
  final String root;

  void create(Map<String, dynamic> manifest) {
    final payload = jsonEncode(manifest);
    final contents = jsonEncode({
      ...manifest,
      'checksum': digestBytes(utf8.encode(payload)),
    });
    // Write the independent fallback first, before modifying any project file.
    for (final name in ['manifest.backup.json', 'manifest.json']) {
      final file = File(project.file('$root/$name'));
      file.writeAsStringSync(contents, flush: true);
    }
  }

  Map<String, dynamic> read() {
    for (final name in ['manifest.json', 'manifest.backup.json']) {
      try {
        final file = File(project.file('$root/$name'));
        final data =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final checksum = data.remove('checksum');
        if (![1, 2, 3].contains(data['version']) ||
            data['files'] is! Map ||
            (data['version'] == 3 &&
                checksum != digestBytes(utf8.encode(jsonEncode(data))))) {
          throw const FormatException('Invalid recovery metadata');
        }
        final events = File(project.file('$root/states.jsonl'));
        if (data['version'] == 3 && events.existsSync()) {
          final lines = events.readAsStringSync().split('\n');
          // A torn final append has no newline and is deliberately ignored.
          for (final line in lines.take(lines.length - 1)) {
            try {
              final event = jsonDecode(line) as Map;
              final record = (data['files'] as Map)[event['path']];
              if (record is Map &&
                  [
                    'applied',
                    'restored',
                    'conflict',
                  ].contains(event['state'])) {
                record['state'] = event['state'];
              }
            } on Object {
              // Content hashes, not transition records, authorize recovery.
            }
          }
        }
        return data;
      } on Object {
        // Try the independent snapshot; never delete unknown recovery data.
      }
    }
    throw const GenerationException(
      'Recovery metadata is missing or invalid. All backups were preserved in .cleany/transaction; restore a valid manifest before retrying.',
    );
  }

  void transition(String path, String state) {
    File(project.file('$root/states.jsonl')).writeAsStringSync(
      '${jsonEncode({'path': path, 'state': state})}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}
