String exceptionsFile() {
  return '''import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

class FailureExceptions {
  static Failure getException(Object error) {
    return switch (error) {
      DioException e => _handleDio(e),
      AuthException e => _handleAuth(e),
      PostgrestException e => _handlePostgrest(e),
      StorageException e => _handleStorage(e),
      SocketException e => _handleSocket(e),
      FormatException _ => const FormatFailure(),
      TimeoutException _ => const TimeoutFailure(),
      _ => UnknownFailure(error.toString()),
    };
  }

  // ══════════════════════════════════════════════════════════════
  // DIO EXCEPTIONS
  // ══════════════════════════════════════════════════════════════

  static Failure _handleDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => const TimeoutFailure(
        'Connection timeout',
      ),
      DioExceptionType.sendTimeout => const TimeoutFailure('Send timeout'),
      DioExceptionType.receiveTimeout => const TimeoutFailure(
        'Receive timeout',
      ),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.cancel => const CancelledFailure(),
      DioExceptionType.badResponse => _handleStatusCode(
        error.response?.statusCode,
      ),
      _ => const UnknownFailure('Network error'),
    };
  }

  static Failure _handleStatusCode(int? code) {
    return switch (code) {
      400 => const ValidationFailure('Bad request'),
      401 => const UnauthorizedFailure(),
      403 => const UnauthorizedFailure('Access denied'),
      404 => const NotFoundFailure(),
      409 => const ValidationFailure('Data conflict'),
      422 => const ValidationFailure('Invalid data'),
      429 => const TooManyRequestsFailure(),
      500 => const ServerFailure(),
      502 => const ServerFailure('Bad gateway'),
      503 => const ServerFailure('Service unavailable'),
      _ => ServerFailure('Server error: \$code'),
    };
  }

  // ══════════════════════════════════════════════════════════════
  // SUPABASE AUTH EXCEPTIONS
  // https://supabase.com/docs/reference/javascript/auth-error-codes
  // ══════════════════════════════════════════════════════════════

  static Failure _handleAuth(AuthException error) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    return switch (code) {
      // ─── Anonymous Sign-ins ───
      'anonymous_provider_disabled' => const UnauthorizedFailure(
        'Anonymous sign-in is disabled',
      ),

      // ─── Email/Phone ───
      'email_provider_disabled' => const UnauthorizedFailure(
        'Email sign-in is disabled',
      ),
      'phone_provider_disabled' => const UnauthorizedFailure(
        'Phone sign-in is disabled',
      ),
      'email_exists' => const EmailAlreadyExistsFailure(),
      'email_not_confirmed' => const UnauthorizedFailure(
        'Please verify your email',
      ),
      'phone_not_confirmed' => const UnauthorizedFailure(
        'Please verify your phone',
      ),
      'email_address_invalid' => const ValidationFailure(
        'Invalid email address',
      ),
      'email_address_not_authorized' => const UnauthorizedFailure(
        'Email not authorized',
      ),

      // ─── Credentials ───
      'invalid_credentials' => const InvalidCredentialsFailure(),
      'user_not_found' => const InvalidCredentialsFailure('Account not found'),
      'wrong_password' => const InvalidCredentialsFailure('Wrong password'),

      // ─── Password ───
      'weak_password' => const WeakPasswordFailure(),
      'same_password' => const ValidationFailure(
        'New password must be different',
      ),

      // ─── OTP ───
      'otp_expired' => const ValidationFailure(
        'Code expired, request a new one',
      ),
      'otp_disabled' => const UnauthorizedFailure('OTP is disabled'),

      // ─── Session/Token ───
      'session_expired' => const SessionExpiredFailure(),
      'session_not_found' => const SessionExpiredFailure('Please login again'),
      'refresh_token_not_found' => const SessionExpiredFailure(
        'Please login again',
      ),
      'refresh_token_already_used' => const SessionExpiredFailure(
        'Please login again',
      ),

      // ─── User Status ───
      'user_banned' => const AccountDisabledFailure('Account is banned'),
      'user_already_exists' => const EmailAlreadyExistsFailure(),

      // ─── Rate Limiting ───
      'over_request_rate_limit' => const TooManyRequestsFailure(
        'Too many attempts, try later',
      ),
      'over_email_send_rate_limit' => const TooManyRequestsFailure(
        'Too many emails, try later',
      ),
      'over_sms_send_rate_limit' => const TooManyRequestsFailure(
        'Too many SMS, try later',
      ),

      // ─── OAuth/SSO ───
      'oauth_provider_not_supported' => const UnauthorizedFailure(
        'Provider not supported',
      ),
      'provider_disabled' => const UnauthorizedFailure(
        'This login method is disabled',
      ),
      'sso_provider_not_found' => const NotFoundFailure(
        'SSO provider not found',
      ),

      // ─── MFA ───
      'mfa_required' => const UnauthorizedFailure(
        'Two-factor authentication required',
      ),
      'mfa_challenge_expired' => const ValidationFailure('MFA code expired'),
      'mfa_verification_failed' => const ValidationFailure('Invalid MFA code'),
      'mfa_factor_not_found' => const NotFoundFailure('MFA not set up'),
      'insufficient_aal' => const UnauthorizedFailure(
        'Additional verification required',
      ),

      // ─── Signup ───
      'signup_disabled' => const UnauthorizedFailure('Registration is closed'),

      // ─── CAPTCHA ───
      'captcha_failed' => const ValidationFailure(
        'Captcha verification failed',
      ),

      // ─── Validation ───
      'validation_failed' => const ValidationFailure('Invalid data'),
      'bad_json' => const FormatFailure('Invalid request format'),

      // ─── Invite ───
      'invite_not_found' => const NotFoundFailure('Invite not found'),
      'expired_link' => const ValidationFailure('Link has expired'),

      // ─── SAML ───
      'saml_assertion_no_email' => const ValidationFailure(
        'No email in SAML response',
      ),
      'saml_idp_not_found' => const NotFoundFailure(
        'Identity provider not found',
      ),

      // ─── Flow State ───
      'flow_state_not_found' => const SessionExpiredFailure(
        'Session expired, try again',
      ),
      'flow_state_expired' => const SessionExpiredFailure(
        'Session expired, try again',
      ),

      // ─── Unexpected ───
      'unexpected_failure' => const UnknownFailure('Unexpected error occurred'),

      // ─── Fallback (check message) ───
      _ => _handleAuthMessage(message, error.message),
    };
  }

  static Failure _handleAuthMessage(String message, String original) {
    if (message.contains('invalid login') ||
        message.contains('invalid email or password')) {
      return const InvalidCredentialsFailure();
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return const EmailAlreadyExistsFailure();
    }
    if (message.contains('weak password') ||
        message.contains('password should be')) {
      return const WeakPasswordFailure();
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return const TooManyRequestsFailure();
    }
    if (message.contains('network') || message.contains('connection')) {
      return const NetworkFailure();
    }
    return UnauthorizedFailure(original);
  }

  // ══════════════════════════════════════════════════════════════
  // SUPABASE POSTGREST EXCEPTIONS
  // https://postgrest.org/en/stable/references/errors.html
  // ══════════════════════════════════════════════════════════════

  static Failure _handlePostgrest(PostgrestException error) {
    final code = error.code ?? '';

    return switch (code) {
      // ─── PostgreSQL Errors ───

      // Integrity Constraints (23xxx)
      '23000' => const ValidationFailure('Data integrity violation'),
      '23001' => const ValidationFailure('Cannot delete, data is in use'),
      '23502' => const ValidationFailure('Required field is missing'),
      '23503' => const ValidationFailure('Referenced data not found'),
      '23505' => const ValidationFailure('Data already exists'),
      '23514' => const ValidationFailure('Data validation failed'),

      // Data Errors (22xxx)
      '22000' => const ValidationFailure('Invalid data'),
      '22001' => const ValidationFailure('Text is too long'),
      '22003' => const ValidationFailure('Number out of range'),
      '22007' => const ValidationFailure('Invalid date format'),
      '22008' => const ValidationFailure('Date out of range'),
      '22012' => const ValidationFailure('Division by zero'),
      '22023' => const ValidationFailure('Invalid parameter'),
      '22P02' => const ValidationFailure('Invalid data type'),

      // Authorization (42xxx)
      '42501' => const UnauthorizedFailure('No permission for this action'),
      '42601' => const ServerFailure('Query syntax error'),
      '42703' => const ValidationFailure('Column not found'),
      '42883' => const ServerFailure('Function not found'),
      '42P01' => const NotFoundFailure('Table not found'),
      '42P02' => const ValidationFailure('Parameter not found'),

      // Transaction (40xxx)
      '40001' => const ServerFailure('Transaction conflict, try again'),
      '40P01' => const ServerFailure('Deadlock detected'),

      // Connection (08xxx)
      '08000' => const NetworkFailure('Database connection failed'),
      '08003' => const NetworkFailure('Database connection lost'),
      '08006' => const NetworkFailure('Database connection failed'),

      // Resources (53xxx)
      '53000' => const ServerFailure('Server resources exhausted'),
      '53100' => const ServerFailure('Out of disk space'),
      '53200' => const ServerFailure('Out of memory'),
      '53300' => const TooManyRequestsFailure('Too many connections'),

      // ─── PostgREST Errors ───
      'PGRST000' => const NetworkFailure('Could not connect to database'),
      'PGRST001' => const ServerFailure('Database connection pool timeout'),
      'PGRST002' => const ServerFailure('Database schema cache error'),

      'PGRST100' => const ValidationFailure('Invalid request syntax'),
      'PGRST102' => const ValidationFailure('Invalid request format'),
      'PGRST103' => const ValidationFailure('Invalid range'),

      'PGRST105' => const ValidationFailure('Invalid column'),
      'PGRST106' => const ValidationFailure('Invalid filter'),
      'PGRST107' => const ValidationFailure('Invalid operator'),
      'PGRST108' => const ValidationFailure('Invalid order'),
      'PGRST109' => const ValidationFailure('Invalid limit'),
      'PGRST110' => const ValidationFailure('Invalid offset'),

      'PGRST116' => const NotFoundFailure('No data found'),
      'PGRST117' => const ValidationFailure('Multiple rows returned'),

      'PGRST200' => const UnauthorizedFailure('Authentication required'),
      'PGRST201' => const UnauthorizedFailure('Invalid token'),
      'PGRST202' => const UnauthorizedFailure('Token expired'),
      'PGRST203' => const UnauthorizedFailure('Insufficient privileges'),
      'PGRST204' => const UnauthorizedFailure('RLS policy violation'),

      'PGRST300' => const ValidationFailure('Function error'),
      'PGRST301' => const ValidationFailure('Invalid function parameters'),
      'PGRST302' => const NotFoundFailure('Function not found'),

      // ─── Fallback ───
      _ => _handlePostgrestMessage(error.message),
    };
  }

  static Failure _handlePostgrestMessage(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('permission denied')) return const UnauthorizedFailure();
    if (msg.contains('violates row-level security'))
      return const UnauthorizedFailure('Access denied');
    if (msg.contains('duplicate key'))
      return const ValidationFailure('Data already exists');
    if (msg.contains('not found')) return const NotFoundFailure();
    if (msg.contains('foreign key'))
      return const ValidationFailure('Invalid reference');
    if (msg.contains('null value'))
      return const ValidationFailure('Required field is missing');
    if (msg.contains('timeout')) return const TimeoutFailure();

    return ServerFailure(message);
  }

  // ══════════════════════════════════════════════════════════════
  // SUPABASE STORAGE EXCEPTIONS
  // ══════════════════════════════════════════════════════════════

  static Failure _handleStorage(StorageException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // Check status code first
    if (statusCode != null) {
      return switch (statusCode) {
        '400' => const ValidationFailure('Invalid file request'),
        '401' => const UnauthorizedFailure('Storage access denied'),
        '403' => const UnauthorizedFailure('Storage permission denied'),
        '404' => const NotFoundFailure('File not found'),
        '409' => const ValidationFailure('File already exists'),
        '413' => const StorageFailure('File too large'),
        '415' => const StorageFailure('File type not supported'),
        '422' => const ValidationFailure('Invalid file'),
        '429' => const TooManyRequestsFailure(),
        _ => _handleStorageMessage(message, error.message),
      };
    }

    return _handleStorageMessage(message, error.message);
  }

  static Failure _handleStorageMessage(String message, String original) {
    if (message.contains('not found') || message.contains('does not exist')) {
      return const NotFoundFailure('File not found');
    }
    if (message.contains('too large') ||
        message.contains('size limit') ||
        message.contains('exceeded')) {
      return const StorageFailure('File too large');
    }
    if (message.contains('permission') ||
        message.contains('not allowed') ||
        message.contains('denied')) {
      return const UnauthorizedFailure('Storage access denied');
    }
    if (message.contains('type') ||
        message.contains('mime') ||
        message.contains('format')) {
      return const StorageFailure('File type not allowed');
    }
    if (message.contains('duplicate') || message.contains('already exists')) {
      return const ValidationFailure('File already exists');
    }
    if (message.contains('bucket')) {
      return const NotFoundFailure('Storage bucket not found');
    }
    if (message.contains('network') || message.contains('connection')) {
      return const NetworkFailure();
    }

    return StorageFailure(original);
  }

  // ══════════════════════════════════════════════════════════════
  // SOCKET EXCEPTIONS
  // ══════════════════════════════════════════════════════════════

  static Failure _handleSocket(SocketException error) {
    final message = error.message.toLowerCase();

    if (message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('no address associated')) {
      return const NetworkFailure();
    }
    if (message.contains('connection refused')) {
      return const ServerFailure('Connection refused');
    }
    if (message.contains('timed out')) {
      return const TimeoutFailure();
    }

    return const NetworkFailure();
  }
}


''';
}
