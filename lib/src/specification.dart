import 'dart:convert';

import 'project.dart';

/// Fixed-template release recorded for newly generated entries.
const templateVersion = '2.0.4';

/// Current ownership-registry schema version, independent of package semver.
const registryVersion = 2;

/// A constrained Dart field, with an independently configurable JSON key.
class FieldSpec {
  /// Validates a lowerCamelCase field, supported Dart type, and JSON alias.
  FieldSpec(this.name, String type, {String? jsonKey})
    : type = normalizeType(type),
      jsonKey = jsonKey ?? name {
    if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(name)) {
      throw const GenerationException('Field names must be lowerCamelCase.');
    }
    if (const {
      'copyWith',
      'toJson',
      'fromJson',
      'runtimeType',
      'hashCode',
      'toString',
      'noSuchMethod',
      'when',
      'whenOrNull',
      'maybeWhen',
      'map',
      'mapOrNull',
      'maybeMap',
    }.contains(name)) {
      throw GenerationException(
        'Field $name conflicts with Dart, Freezed, or JSON members.',
      );
    }
    validateName(
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}'),
    );
    if (this.jsonKey.isEmpty || this.jsonKey.contains(RegExp(r'[\x00-\x1f]'))) {
      throw const GenerationException('Invalid JSON field key.');
    }
  }

  /// Supported nonnullable field types; append `?` for nullable fields.
  static const types = [
    'String',
    'int',
    'double',
    'bool',
    'DateTime',
    'List<String>',
    'List<int>',
    'List<num>',
    'List<dynamic>',
    'List<Map<String, dynamic>>',
    'Map<String, dynamic>',
    'Set<dynamic>',
    'dynamic',
  ];

  /// Accepts CLI spellings while storing valid, explicit Dart collection types.
  static String normalizeType(String input) {
    final value = input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final nullable = value.endsWith('?');
    final base = nullable ? value.substring(0, value.length - 1) : value;
    final aliases = {
      for (final type in types) type.replaceAll(' ', '').toLowerCase(): type,
      'list': 'List<dynamic>',
      'set': 'Set<dynamic>',
    };
    final canonical = aliases[base];
    if (canonical == null) {
      throw GenerationException('Unsupported field type: $input.');
    }
    return '$canonical${nullable && canonical != 'dynamic' ? '?' : ''}';
  }

  /// Dart property name used in both Model and Entity.
  final String name;

  /// Canonical Dart type, optionally ending in `?`.
  final String type;

  /// Transport key mapped by the generated JSON model.
  final String jsonKey;

  /// Whether the field accepts null values.
  bool get nullable => type == 'dynamic' || type.endsWith('?');

  /// Serializes this specification into the versioned registry representation.
  Map<String, Object?> toJson() => {
    'name': name,
    'type': type,
    'json_key': jsonKey,
  };

  /// Restores and validates a stored field specification.
  factory FieldSpec.fromJson(Map<String, dynamic> json) => FieldSpec(
    json['name'] as String,
    json['type'] as String,
    jsonKey: json['json_key'] as String?,
  );
}

/// Domain requests remain typed; transport encoding lives in the repository.
class FeatureSpec {
  /// Defines response fields and an optional typed request/API contract.
  FeatureSpec({
    List<FieldSpec>? fields,
    this.method = 'GET',
    this.endpoint,
    List<FieldSpec>? requestFields,
    this.requestEncoding = 'query',
  }) : fields = fields ?? [FieldSpec('id', 'String')],
       requestFields = requestFields ?? [] {
    if (this.fields.isEmpty ||
        !['GET', 'POST', 'PUT', 'PATCH', 'DELETE'].contains(method) ||
        !['query', 'body'].contains(requestEncoding) ||
        (method == 'GET' && requestEncoding == 'body')) {
      throw const GenerationException(
        'Invalid API contract. GET requests use query parameters.',
      );
    }
    for (final group in [this.fields, this.requestFields]) {
      if (group.map((field) => field.name).toSet().length != group.length ||
          group.map((field) => field.jsonKey).toSet().length != group.length) {
        throw const GenerationException(
          'Field names and JSON keys must be unique.',
        );
      }
    }
    if (endpoint != null &&
        (!endpoint!.startsWith('/') ||
            endpoint!.contains(RegExp(r'[\x00-\x20{}]')) ||
            endpoint!.startsWith('//'))) {
      throw const GenerationException(
        'Use a relative API path such as /v1/orders.',
      );
    }
  }

  /// Fields shared by the generated response Model and Domain Entity.
  final List<FieldSpec> fields;

  /// Input fields in the Domain Request; an empty list omits that type.
  final List<FieldSpec> requestFields;

  /// HTTP method used by the data-layer client; defaults to GET.
  final String method;

  /// Relative API path; null derives the default from the entry name.
  final String? endpoint;

  /// Request transport encoding: `query` or `body`.
  final String requestEncoding;

  /// Whether generation includes a typed request argument.
  bool get hasRequest => requestFields.isNotEmpty;

  /// Serializes this specification into the versioned registry representation.
  Map<String, Object?> toJson() => {
    'fields': fields.map((f) => f.toJson()).toList(),
    'method': method,
    'endpoint': endpoint,
    'request_fields': requestFields.map((f) => f.toJson()).toList(),
    'request_encoding': requestEncoding,
  };

  /// Restores and validates a persisted API contract.
  factory FeatureSpec.fromJson(Map<String, dynamic> json) => FeatureSpec(
    fields: (json['fields'] as List?)
        ?.map((v) => FieldSpec.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList(),
    requestFields: (json['request_fields'] as List?)
        ?.map((v) => FieldSpec.fromJson(Map<String, dynamic>.from(v as Map)))
        .toList(),
    method: json['method'] as String? ?? 'GET',
    endpoint: json['endpoint'] as String?,
    requestEncoding: json['request_encoding'] as String? ?? 'query',
  );
}

/// Escapes text as a Dart string literal, including interpolation characters.
String dartLiteral(String text) => jsonEncode(text).replaceAll(r'$', r'\$');

/// Result exposed by an additional operation on an existing feature.
enum UseCaseReturnType {
  /// Reports completion without a response entity.
  voidResult,

  /// Returns the selected feature's existing domain entity.
  entity,
}

/// Repository contract used by a generated operation.
enum UseCaseRepositoryBinding {
  /// Adds the operation to the feature's existing repository.
  feature,

  /// Preserves separately generated contracts in older projects.
  operation,
}

/// A validated, transport-independent operation added to a registered feature.
class UseCaseSpec {
  /// Uses snake_case for the filename and derives public Dart identifiers.
  UseCaseSpec({
    required this.name,
    required this.returnType,
    this.repositoryBinding = UseCaseRepositoryBinding.feature,
    this.entityType,
    this.entityPath,
    this.mappingPending = false,
    List<String>? entityFields,
  }) : entityFields = entityFields == null
           ? null
           : List.unmodifiable(entityFields) {
    validateName(name);
    if ((entityType == null) != (entityPath == null) ||
        (entityType != null &&
            (!RegExp(r'^[A-Z][A-Za-z0-9_]*$').hasMatch(entityType!) ||
                !RegExp(
                  r'^lib/(?:[A-Za-z0-9_]+/)*domain/entities/(?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.dart$',
                ).hasMatch(entityPath!)))) {
      throw const GenerationException('Invalid existing Entity reference.');
    }
    if (entityFields != null &&
        (entityFields.toSet().length != entityFields.length ||
            entityFields.any(
              (field) => !RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(field),
            ))) {
      throw const GenerationException(
        'Invalid use case entity mapping fields.',
      );
    }
    if (const {
      'add',
      'add_error',
      'close',
      'emit',
      'fetch',
      'load',
      'on',
      'on_change',
      'on_error',
      'on_event',
      'on_transition',
      'on_done',
      'state',
      'stream',
      'is_closed',
      'requested',
      'copy_with',
      'hash_code',
      'runtime_type',
      'to_string',
      'no_such_method',
      'use_case_state',
      'use_case_initial',
      'use_case_loading',
      'use_case_success',
      'use_case_failure',
    }.contains(name)) {
      throw GenerationException(
        'Use case name conflicts with a controller or datasource member: $name',
      );
    }
  }

  /// Stable operation name and filename, independent of feature renames.
  final String name;

  /// Whether success carries the existing feature Entity or no value.
  final UseCaseReturnType returnType;

  /// Shared feature contracts are the default; legacy operation contracts remain supported.
  final UseCaseRepositoryBinding repositoryBinding;

  /// Whether this operation extends the feature's existing repository.
  bool get usesFeatureRepository =>
      repositoryBinding == UseCaseRepositoryBinding.feature;

  /// Existing entity fields mapped from the feature model, when captured.
  final List<String>? entityFields;

  /// Existing Domain class and its project-relative source, when selected.
  final String? entityType;
  final String? entityPath;

  /// A developer-owned Data mapping hook is needed instead of guessed casts.
  final bool mappingPending;

  /// Resolved result type; old metadata keeps the conventional feature Entity.
  String valueType(String featureType) => returnType == UseCaseReturnType.entity
      ? entityType ?? '${featureType}Entity'
      : 'void';

  /// The import stays in Domain; no transport DTO is exposed to presentation.
  String entityUri(String package, String featurePath, String featureName) =>
      'package:$package/${(entityPath ?? '$featurePath/domain/entities/${featureName}_entity.dart').substring(4)}';

  /// Public operation class name.
  String get type => pascalCase(name);

  /// Repository method and Cubit action name.
  String get method => camelCase(name);

  /// Common, independently observable field on every feature state variant.
  String get statusField => '${method}Status';

  /// Optional constructor injection used by the central composition root.
  String get dependency => '${method}UseCase';

  /// Legacy single-operation repository name; shared operations use the feature name.
  String get repository => '${type}Repository';

  /// Serializes additive operation metadata into the feature registry.
  Map<String, Object> toJson() => {
    'name': name,
    'return_type': returnType == UseCaseReturnType.entity ? 'entity' : 'void',
    'repository_binding': repositoryBinding.name,
    'entity_fields': ?entityFields,
    'entity_type': ?entityType,
    'entity_path': ?entityPath,
    if (mappingPending) 'mapping_pending': true,
  };

  /// Restores and validates an operation definition.
  factory UseCaseSpec.fromJson(Map<String, dynamic> json) {
    final result = json['return_type'];
    if (result != 'void' && result != 'entity') {
      throw const GenerationException('Invalid use case return type.');
    }
    final binding = json['repository_binding'] ?? 'operation';
    if (binding != 'feature' && binding != 'operation') {
      throw const GenerationException('Invalid use case repository binding.');
    }
    return UseCaseSpec(
      repositoryBinding: UseCaseRepositoryBinding.values.byName(
        binding as String,
      ),
      name: json['name'] as String,
      entityFields: (json['entity_fields'] as List?)?.cast<String>(),
      entityType: json['entity_type'] as String?,
      entityPath: json['entity_path'] as String?,
      mappingPending: json['mapping_pending'] == true,
      returnType: result == 'entity'
          ? UseCaseReturnType.entity
          : UseCaseReturnType.voidResult,
    );
  }
}

/// Reads optional operation metadata; older feature records need no migration.
List<UseCaseSpec> entryUseCases(Map entry) =>
    (entry['use_cases'] as List? ?? [])
        .map(
          (value) =>
              UseCaseSpec.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList();
