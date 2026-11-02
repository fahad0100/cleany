/// Old registry records keep their nested widget layout during repair/refactoring.
/// New components record `flat` explicitly, so missing files restore in place.
bool usesLegacyComponentWidgets(Map entry) {
  if (entry['kind'] != 'component') return false;
  final layout = entry['component_layout'];
  if (layout != null) return layout == 'widgets';
  final root = entry['path'];
  final name = entry['name'];
  final owned = entry['files'] as List? ?? [];
  if (owned.any((file) => file['path'] == '$root/${name}_widget.dart')) {
    return false;
  }
  return true;
}

/// Old entries retain their external controller wiring; new widgets own it.
bool usesLocalComponentScope(Map entry) =>
    entry['kind'] == 'component' && entry['component_scope'] == 'local';
