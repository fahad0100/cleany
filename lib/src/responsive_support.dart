import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'ast_editor.dart';
import 'project.dart';
import 'transaction.dart';

/// Adds Sizer around existing app roots without replacing their configuration.
/// Doctor uses this before restoring themes that depend on viewport metrics.
bool planSizerIntegration(GenerationPlan plan) {
  const path = 'lib/app/app.dart';
  if (plan.files.containsKey(path)
      ? plan.files[path]!.after == null
      : !File(plan.project.file(path)).existsSync()) {
    return false;
  }
  final source = plan.read(path);
  final parsed = parseString(content: source, throwIfDiagnostics: false);
  if (parsed.errors.isNotEmpty) {
    throw const GenerationException(
      'Cannot integrate Sizer into invalid app.dart.',
    );
  }
  final material = <String>{};
  final sizers = <String>{};
  for (final directive in parsed.unit.directives.whereType<ImportDirective>()) {
    if (directive.combinators.isNotEmpty) continue;
    final prefix = directive.prefix == null ? '' : '${directive.prefix!.name}.';
    if (directive.uri.stringValue == 'package:flutter/material.dart') {
      material.add('${prefix}MaterialApp');
      material.add('${prefix}MaterialApp.router');
    }
    if (directive.uri.stringValue == 'package:sizer/sizer.dart') {
      sizers.add('${prefix}Sizer');
    }
  }
  final calls = _WidgetCalls();
  parsed.unit.accept(calls);
  final roots = calls.nodes.where((node) {
    if (!material.contains(_callName(node))) return false;
    for (var parent = node.parent; parent != null; parent = parent.parent) {
      final name = _callName(parent);
      if (sizers.contains(name) || material.contains(name)) return false;
    }
    return true;
  }).toList();
  if (roots.isEmpty) return false;
  final editor = AstEditor(source);
  var name = sizers.firstOrNull;
  String? importPrefix;
  if (name == null) {
    // A prefix avoids collisions with unrelated user-defined Sizer symbols.
    var prefix = 'cleany_sizer';
    var suffix = 1;
    while (editor.usesUnqualified(prefix)) {
      prefix = 'cleany_sizer_${suffix++}';
    }
    name = '$prefix.Sizer';
    importPrefix = prefix;
  }
  roots.sort((a, b) => b.offset.compareTo(a.offset));
  for (final root in roots) {
    final original = source.substring(root.offset, root.end);
    editor.source = editor.source.replaceRange(root.offset, root.end, '''
$name(
      maxTabletWidth: 1024,
      builder: (context, orientation, screenType) => $original,
    )''');
  }
  // Insert after source-offset edits, so the parsed ranges remain valid.
  if (importPrefix != null) {
    final unit = parseString(content: editor.source).unit;
    final imports = unit.directives.whereType<ImportDirective>().toList();
    final offset = imports.isNotEmpty
        ? imports.last.end
        : unit.declarations.first.offset;
    editor.source = editor.source.replaceRange(
      offset,
      offset,
      "\nimport 'package:sizer/sizer.dart' as $importPrefix;\n",
    );
  }
  plan.write(path, editor.source);
  return true;
}

String? _callName(AstNode node) => switch (node) {
  InstanceCreationExpression() => node.constructorName.toSource(),
  MethodInvocation() =>
    '${node.target == null ? '' : '${node.target!.toSource()}.'}${node.methodName.name}',
  _ => null,
};

class _WidgetCalls extends RecursiveAstVisitor<void> {
  final nodes = <AstNode>[];
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    nodes.add(node);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    nodes.add(node);
    super.visitMethodInvocation(node);
  }
}
