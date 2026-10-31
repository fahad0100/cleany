import 'dart:convert';

import 'project.dart';

/// Fixed-template release recorded for newly generated entries.
const templateVersion = '2.0.0';

/// Current ownership-registry schema version, independent of package semver.
const registryVersion = 2;

/// A constrained Dart field, with an independently configurable JSON key.
class FieldSpec {
  /// Validates a lowerCamelCase field, supported Dart type, and JSON alias.
  FieldSpec(this.name, this.type, {String? jsonKey})
    : jsonKey = jsonKey ?? name {
    if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(name)) {
      throw const GenerationException('Field names must be lowerCamelCase.');
    }
    validateName(
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}'),
    );
    if (!types.contains(type.replaceFirst(RegExp(r'\?$'), ''))) {
      throw const GenerationException('Choose a supported field type.');
    }
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
  ];

  /// Dart property name used in both Model and Entity.
  final String name;

  /// Canonical Dart type, optionally ending in `?`.
  final String type;

  /// Transport key mapped by the generated JSON model.
  final String jsonKey;

  /// Whether the field accepts null values.
  bool get nullable => type.endsWith('?');

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
