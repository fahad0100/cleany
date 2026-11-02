/// Stable command identities keep execution independent of menu numbering.
enum CliCommand {
  createFeature(
    1,
    'Generation',
    'Create feature',
    'Create a complete feature with Data, Domain and Presentation, then connect its Cubit or Bloc, dependencies and route.',
    requiresInitialization: true,
  ),
  createComponent(
    2,
    'Generation',
    'Create component',
    'Create a reusable widget to embed inside feature UI, with an optional Cubit or Bloc owned and disposed by its local BlocProvider.',
    requiresInitialization: true,
  ),
  addUseCase(
    3,
    'Generation',
    'Add use case',
    'Add an Entity-returning or void operation to an existing feature, reuse its repository, and connect its Cubit or Bloc.',
    requiresInitialization: true,
  ),
  removeFeature(
    4,
    'Cleanup',
    'Remove feature',
    'Remove a feature and its nested entries, then clean dependencies, routes and ownership records. Review the files before applying.',
    requiresInitialization: true,
  ),
  removeComponent(
    5,
    'Cleanup',
    'Remove component',
    'Remove a component and its state files, update the registry, and clean any legacy central bindings.',
    requiresInitialization: true,
  ),
  listFeatures(
    6,
    'Inspection & Management',
    'List features',
    'Show registered feature names, state management choices and project locations.',
    requiresInitialization: true,
  ),
  listComponents(
    7,
    'Inspection & Management',
    'List components',
    'Show registered component names, state management choices and project locations.',
    requiresInitialization: true,
  ),
  renameMove(
    8,
    'Inspection & Management',
    'Rename or move an entry',
    'Rename or move a feature or component and update Dart references, central bindings and registry paths. Backend endpoints are preserved.',
    requiresInitialization: true,
  ),
  initialize(
    9,
    'Core & Setup',
    'Initialize project',
    'Set up the application architecture, localization, network services, environments and run profiles using the production app identity.',
  ),
  configureFlavors(
    10,
    'Core & Setup',
    'Configure native flavors',
    'Configure dev, uat and prod native app identities on selected platforms through Flavorizr, then validate the staged changes.',
  ),
  appConfigValue(
    11,
    'Core & Setup',
    'App config value',
    'Add a public String configuration key with dev, uat and prod YAML values and a dart-define override in AppConfig.',
    requiresInitialization: true,
  ),
  doctor(
    12,
    'Maintenance & Recovery',
    'Project doctor / repair',
    'Inspect the registry, generated sources, dependencies, routes and bindings, then review specific supported repairs.',
  ),
  recover(
    13,
    'Maintenance & Recovery',
    'Recover interrupted operation',
    'Recover an interrupted transaction from its journal, restoring safe files while retaining conflicting edits and backups.',
  ),
  maintenance(
    14,
    'Maintenance & Recovery',
    'Cleany maintenance / reset',
    'Clean abandoned project-local workspaces, configure command timeouts, or archive managed files and reset the architecture.',
  ),
  exit(0, null, 'Exit', 'Close the Cleany session.');

  const CliCommand(
    this.number,
    this.section,
    this.label,
    this.description, {
    this.requiresInitialization = false,
  });
  final int number;
  final String? section;
  final String label;
  final String description;
  final bool requiresInitialization;

  static CliCommand? fromNumber(String value) {
    final number = int.tryParse(value);
    return values.where((command) => command.number == number).singleOrNull;
  }
}
