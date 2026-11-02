/// Encrypted values and opaque record identifiers work on IO and IndexedDB.
/// Keys are kept separately in platform secure storage, never in the DB file.
Map<String, String> storageTemplates() => {
  'LOCAL_STORAGE.md': '''
# Encrypted local storage

Bootstrap opens one AppLocalStorage in the application DI scope and closes it
when the application is disposed. Repositories should receive it by constructor
injection (container<AppLocalStorage>()); widgets can use
context.read<AppLocalStorage>() under the bootstrap RepositoryProvider.

```dart
final storage = context.read<AppLocalStorage>();
await storage.put(key: LocalKeys.languageCode, value: 'ar');
final language = await storage.get<String>(key: LocalKeys.languageCode);
final exists = await storage.containsKey(key: LocalKeys.languageCode);
await storage.remove(key: LocalKeys.languageCode);
await storage.clear();
```

Use local_keys.dart to centralize names. Supported payloads are Sembast JSON
values, Blob and Timestamp; root null is rejected (remove the key instead).
get<T> returns null for a missing key or type mismatch. For typed collections,
pass decode, for example decode: (value) => (value as List).cast<int>().
Authentication errors throw StorageIntegrityException and never look like a
missing value. Wrong keys and missing vault keys never erase the existing DB.

## Keys and configuration

DB_SECRET_KEY defaults to pass_key_storage in all flavor YAML files, AppConfig
and AppLocalStorage. This is a public scaffold password, not a production secret.
Replace it before shipping. Passwords derive a 256-bit key with PBKDF2-HMAC-SHA256
(600,000 iterations) and a persisted random 32-byte salt per database. The salt
format is versioned; missing/corrupt salts never trigger a silent replacement.

Each record has a fresh 96-bit nonce and AES-256-GCM authentication tag; record
names use HMAC-SHA256. Metadata (including the non-secret salt) remains visible.
Web uses the same encrypted records on IndexedDB. Encryption adapters, ciphers,
exceptions and key handling live in core/storage/storage_extension; the public
AppLocalStorage and LocalKeys remain directly under core/storage.

A dart-define overrides YAML, including an explicitly empty override (invalid
for a DB password). YAML assets and dart-defines are recoverable from client
builds: do not treat bundled passwords as protected. Use auto for a random
256-bit app/environment key held in the platform vault. Existing base64-encoded
32-byte raw keys also remain supported. Never log keys or passwords. Changing
the password, raw key, or mode requires an explicit data migration; a mismatch
fails authentication without resetting the database.

clear deletes logical records and compacts the DB, while retaining key metadata.
It cannot guarantee physical erasure from SSD blocks, OS snapshots or backups.
Encryption protects data at rest, not a compromised running application or XSS.
Open one owned instance through DI; do not open competing handles/isolates.

## Platform setup before release

- Android: minSdk 23 or newer. Disable app backup (android:allowBackup=false)
  or explicitly exclude the vault and DB from cloud/device-transfer backups.
- iOS/macOS: configure Keychain Sharing for all build configurations/flavors
  as described by flutter_secure_storage. Preserve existing access groups.
- Linux: install the flutter_secure_storage native prerequisites and run a
  supported keyring service. A headless environment needs an injected key store.
- Web: use HTTPS or localhost. Browser storage is origin-scoped and is not a
  substitute for backend secrets or protection against injected JavaScript.
- Backup/recovery must preserve the matching key as well as the encrypted DB.

See https://pub.dev/packages/flutter_secure_storage for platform setup.
Tests can inject a Sembast database and StorageKeyStore without native plugins;
configureDependencies also accepts an owned localStorage instance for tests.
''',
  'lib/core/storage/local_keys.dart': '''
abstract final class LocalKeys {
  static const languageCode = 'language_code';
  static const themeMode = 'theme_mode';
}
''',
  'lib/core/storage/storage_extension/storage_exceptions.dart': '''
/// Authentication failure or unsupported encrypted record; data is preserved.
class StorageIntegrityException implements Exception {
  const StorageIntegrityException();
  @override
  String toString() => 'Local storage could not be authenticated. Check its key and integrity; no data was reset.';
}

class StorageKeyUnavailableException implements Exception {
  const StorageKeyUnavailableException();
  @override
  String toString() => 'The secure key for existing local data is unavailable. Restore the key; no replacement key or database was created.';
}
''',
  'lib/core/storage/storage_extension/storage_cipher.dart': r'''
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:sembast/sembast.dart';
import 'storage_exceptions.dart';

/// AES-256-GCM authenticates values and binds each envelope to its record ID.
/// HMAC-SHA256 separates index/encryption keys and hides application key names.
class StorageCipher {
  StorageCipher(Uint8List key, this.namespace) {
    if (key.length != 32) { throw ArgumentError('Storage requires a 32-byte key.'); }
    _encryptionKey = _derive(key, 'encryption');
    _indexKey = _derive(key, 'index');
  }
  final String namespace;
  final Random _random = Random.secure();
  late final Uint8List _encryptionKey;
  late final Uint8List _indexKey;
  Uint8List _derive(Uint8List key, String purpose) => Uint8List.fromList(
    Hmac(sha256, key).convert(utf8.encode('cleany.storage.v1/$namespace/$purpose')).bytes,
  );
  String recordId(String key) => Hmac(sha256, _indexKey).convert(utf8.encode(key)).toString();

  Map<String, Object?> seal(Object value, String recordId) {
    final Object encoded;
    try {
      encoded = sembastCodecDefault.jsonEncodableCodec.encode(value);
    } catch (_) {
      throw ArgumentError('Use Sembast-compatible JSON values, Blob or Timestamp.');
    }
    final Uint8List bytes;
    try {
      bytes = Uint8List.fromList(utf8.encode(jsonEncode(encoded)));
    } catch (_) {
      throw ArgumentError('Use Sembast-compatible JSON values, Blob or Timestamp.');
    }
    final nonce = Uint8List.fromList(List.generate(12, (_) => _random.nextInt(256)));
    final cipher = GCMBlockCipher(AESEngine())..init(true, AEADParameters(
      KeyParameter(_encryptionKey), 128, nonce, _aad(recordId),
    ));
    return {'v': 1, 'n': base64Encode(nonce), 'c': base64Encode(cipher.process(bytes))};
  }

  Object unseal(Object? envelope, String recordId) {
    try {
      if (envelope is! Map || envelope['v'] != 1 || envelope['n'] is! String || envelope['c'] is! String) {
        throw const FormatException();
      }
      final nonce = base64Decode(envelope['n'] as String);
      final bytes = base64Decode(envelope['c'] as String);
      if (nonce.length != 12 || bytes.length < 16) { throw const FormatException(); }
      final cipher = GCMBlockCipher(AESEngine())..init(false, AEADParameters(
        KeyParameter(_encryptionKey), 128, nonce, _aad(recordId),
      ));
      final value = jsonDecode(utf8.decode(cipher.process(bytes)));
      if (value == null) { throw const FormatException(); }
      return sembastCodecDefault.jsonEncodableCodec.decode(value);
    } catch (_) {
      throw const StorageIntegrityException();
    }
  }
  Uint8List _aad(String id) => Uint8List.fromList(utf8.encode('cleany.storage.v1/$namespace/$id'));
}
''',
  'lib/core/storage/storage_extension/storage_key_store.dart': r'''
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'storage_exceptions.dart';

abstract interface class StorageKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// The optional auto mode keeps its key here; user values belong to AppLocalStorage.
class PlatformStorageKeyStore implements StorageKeyStore {
  const PlatformStorageKeyStore([this.storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  )]);
  final FlutterSecureStorage storage;
  @override
  Future<String?> read(String key) => storage.read(key: key);
  @override
  Future<void> write(String key, String value) => storage.write(key: key, value: value);
}

/// Serialize first-use read/create per vault and namespace in this isolate.
/// Open one owned storage instance through application DI, not per widget/isolate.
abstract final class StorageKeyResolver {
  static final _pending = Map<StorageKeyStore, Map<String, Future<Uint8List>>>.identity();
  /// Passphrases use a persisted random salt; existing raw base64 keys stay valid.
  static bool usesPassphrase(String value) {
    if (value == 'auto') { return false; }
    try { return base64Decode(value).length != 32; }
    catch (_) { return true; }
  }
  static Future<Uint8List> resolve({required String namespace,
    required String configuredKey, required bool hasData,
    required StorageKeyStore keyStore, Uint8List? passwordSalt}) async {
    if (configuredKey != 'auto') {
      if (!usesPassphrase(configuredKey)) { return _decode(configuredKey); }
      if (configuredKey.isEmpty) { throw ArgumentError('DB_SECRET_KEY cannot be empty.'); }
      if (passwordSalt == null || passwordSalt.length != 32) { throw const StorageIntegrityException(); }
      final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
        ..init(Pbkdf2Parameters(passwordSalt, 600000, 32));
      return derivator.process(Uint8List.fromList(utf8.encode(configuredKey)));
    }
    final requests = _pending.putIfAbsent(keyStore, () => {});
    final name = 'cleany.local_storage.v1.$namespace';
    final future = requests.putIfAbsent(name, () async {
      final existing = await keyStore.read(name);
      if (existing != null) {
        try { return _decode(existing); }
        on ArgumentError { throw const StorageKeyUnavailableException(); }
      }
      if (hasData) { throw const StorageKeyUnavailableException(); }
      final random = Random.secure();
      final key = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
      await keyStore.write(name, base64Encode(key));
      // Never silently continue when the platform vault did not persist the key.
      if (await keyStore.read(name) != base64Encode(key)) {
        throw const StorageKeyUnavailableException();
      }
      return key;
    });
    try {
      return Uint8List.fromList(await future);
    } finally {
      if (identical(requests[name], future)) { requests.remove(name); }
      if (requests.isEmpty && identical(_pending[keyStore], requests)) { _pending.remove(keyStore); }
    }
  }
  static Uint8List _decode(String value) {
    try {
      final bytes = base64Decode(value);
      if (bytes.length == 32) { return bytes; }
    } catch (_) { /* Do not expose key contents in diagnostics. */ }
    throw ArgumentError('The stored encryption key must be a base64-encoded 32-byte key.');
  }
}
''',
  'lib/core/storage/storage_extension/database_factory.dart': '''
/// Selects the native or browser adapter without importing dart:io on web.
library;

export 'database_factory_io.dart'
  if (dart.library.js_interop) 'database_factory_web.dart';
''',
  'lib/core/storage/storage_extension/database_factory_io.dart': '''
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openStorageDatabase(String environment) async {
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  return databaseFactoryIo.openDatabase(path.join(directory.path, 'app_local_v1_\$environment.db'));
}
''',
  'lib/core/storage/storage_extension/database_factory_web.dart': '''
import 'package:sembast_web/sembast_web.dart';

// IndexedDB has no Sembast codec support; values are encrypted before writes.
Future<Database> openStorageDatabase(String environment) =>
  databaseFactoryWeb.openDatabase('app_local_v1_\$environment');
''',
  'lib/core/storage/app_local_storage.dart': r'''
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:sembast/sembast.dart';
import 'storage_extension/database_factory.dart';
import 'storage_extension/storage_cipher.dart';
import 'storage_extension/storage_exceptions.dart';
import 'storage_extension/storage_key_store.dart';
export 'package:sembast/blob.dart';
export 'package:sembast/timestamp.dart';

/// One app-scoped, encrypted key/value store. Inject into Data repositories or
/// read the provided instance from BuildContext in presentation code.
class AppLocalStorage {
  AppLocalStorage._(this._db, this._cipher);
  final Database _db;
  final StorageCipher _cipher;
  final _store = StoreRef<String, Object?>.main();
  static final _metadata = StoreRef<String, Object?>('cleany_storage_metadata');
  bool _closed = false;
  Future<void>? _closing;

  /// Uses a platform DB and configured password; auto opts into the vault.
  /// Injectable adapters keep tests isolated.
  /// Wrong keys, missing vault keys and corruption fail without erasing records.
  static Future<AppLocalStorage> open({required String environment,
    String dbSecretKey = 'pass_key_storage', Database? database,
    StorageKeyStore keyStore = const PlatformStorageKeyStore()}) async {
    if (!{'dev', 'uat', 'prod'}.contains(environment)) {
      throw ArgumentError('Choose dev, uat or prod for local storage.');
    }
    if (dbSecretKey.isEmpty) { throw ArgumentError('DB_SECRET_KEY cannot be empty.'); }
    final db = database ?? await openStorageDatabase(environment);
    try {
      final hasData = await _metadata.record('key_check').exists(db) ||
        await StoreRef<String, Object?>.main().count(db) > 0;
      final salt = StorageKeyResolver.usesPassphrase(dbSecretKey)
        ? await _passwordSalt(db) : null;
      final key = await StorageKeyResolver.resolve(namespace: environment,
        configuredKey: dbSecretKey, hasData: hasData, keyStore: keyStore, passwordSalt: salt);
      final cipher = StorageCipher(key, environment);
      await db.transaction((transaction) async {
        final check = await _metadata.record('key_check').get(transaction);
        if (check == null) {
          if (await StoreRef<String, Object?>.main().count(transaction) != 0) {
            throw const StorageIntegrityException();
          }
          await _metadata.record('key_check').put(transaction, cipher.seal('cleany.storage.v1', 'metadata/key_check'));
        } else if (cipher.unseal(check, 'metadata/key_check') != 'cleany.storage.v1') {
          throw const StorageIntegrityException();
        }
      });
      return AppLocalStorage._(db, cipher);
    } catch (error, stack) {
      try { await db.close(); } catch (_) { /* Preserve the opening failure. */ }
      Error.throwWithStackTrace(error, stack);
    }
  }

  // Persist the salt before deriving a password key. Never replace an existing
  // database's missing/corrupt salt or convert its encryption mode implicitly.
  static Future<Uint8List> _passwordSalt(Database db) => db.transaction((transaction) async {
    final record = _metadata.record('password_salt_v1');
    final existing = await record.get(transaction);
    if (existing != null) {
      try {
        if (existing is! String) { throw const FormatException(); }
        final salt = base64Decode(existing);
        if (salt.length != 32) { throw const FormatException(); }
        return salt;
      } catch (_) { throw const StorageIntegrityException(); }
    }
    if (await _metadata.record('key_check').exists(transaction) ||
        await StoreRef<String, Object?>.main().count(transaction) != 0) {
      throw const StorageIntegrityException();
    }
    final random = Random.secure();
    final salt = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
    await record.put(transaction, base64Encode(salt));
    return salt;
  });

  void _check(String key) {
    if (_closed) { throw StateError('Local storage is closed.'); }
    if (key.trim().isEmpty) { throw ArgumentError('A non-empty local key is required.'); }
  }

  Future<void> put<T>({required String key, required T value}) async {
    _check(key);
    if (value == null) { throw ArgumentError('Root null values are not supported. Remove the key instead.'); }
    final id = _cipher.recordId(key);
    final encrypted = _cipher.seal(value, id);
    await _store.record(id).put(_db, encrypted);
  }

  /// A mismatch returns null; authentication failures always throw.
  /// Supply decode for typed collections or domain-specific reconstruction.
  Future<T?> get<T>({required String key, T Function(Object value)? decode}) async {
    _check(key);
    final id = _cipher.recordId(key);
    final encrypted = await _store.record(id).get(_db);
    if (encrypted == null) { return null; }
    final value = _cipher.unseal(encrypted, id);
    if (decode != null) { return decode(value); }
    if (value is T) { return value as T; }
    return null;
  }

  Future<bool> containsKey({required String key}) async {
    _check(key);
    return _store.record(_cipher.recordId(key)).exists(_db);
  }
  Future<void> remove({required String key}) async {
    _check(key);
    await _store.record(_cipher.recordId(key)).delete(_db);
  }
  /// Logical deletion plus compaction; does not erase external backups/SSD blocks.
  Future<void> clear() async {
    if (_closed) { throw StateError('Local storage is closed.'); }
    await _store.drop(_db);
    await _db.compact();
  }
  /// The owning DI scope closes the DB exactly once after application disposal.
  Future<void> close() => _closing ??= _close();
  Future<void> _close() async {
    _closed = true;
    await _db.close();
  }
}
''',
};
