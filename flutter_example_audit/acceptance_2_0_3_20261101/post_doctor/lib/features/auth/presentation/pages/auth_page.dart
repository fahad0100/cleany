import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/storage/session_store.dart';
import 'package:cleany_store/core/state/use_case_state.dart';

import '../../domain/entities/auth_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Public demo credentials are sent only to the configured API; sessions stay in memory.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.session});
  final ValueListenable<SessionData?> session;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => ValueListenableBuilder<SessionData?>(
        valueListenable: widget.session,
        builder: (context, session, _) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF163F35),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 65,
                color: Color(0xFFF0B68B),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              session == null ? l.signInTitle : l.signedIn,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(session == null ? l.signInSubtitle : l.sessionMemory),
            const SizedBox(height: 28),
            if (session != null) ...[
              Card(
                key: const Key('signed-in-panel'),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 38),
                      const SizedBox(height: 12),
                      Text(
                        '@${session.username}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${l.userLabel} #${session.userId}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                key: const Key('sign-out'),
                onPressed: state.signOutStatus is UseCaseLoading<void>
                    ? null
                    : () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout),
                label: Text(l.signOut),
              ),
            ] else
              Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('username'),
                      controller: _username,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l.username,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (s) => s == null || s.trim().isEmpty
                          ? l.requiredField
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('password'),
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: l.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (s) =>
                          s == null || s.isEmpty ? l.requiredField : null,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      key: const Key('demo-account'),
                      onPressed: () {
                        _username.text = 'mor_2314';
                        _password.text = '83r5^_';
                      },
                      child: Text(l.useDemoAccount),
                    ),
                    const SizedBox(height: 12),
                    if (state.signInStatus case UseCaseFailure<AuthEntity>(
                      :final failure,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          context.failureText(failure),
                          key: const Key('auth-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    FilledButton(
                      key: const Key('sign-in'),
                      onPressed:
                          state.signInStatus is UseCaseLoading<AuthEntity>
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (_form.currentState!.validate()) {
                                context.read<AuthCubit>().signIn(
                                  username: _username.text,
                                  password: _password.text,
                                );
                              }
                            },
                      child: state.signInStatus is UseCaseLoading<AuthEntity>
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l.signIn),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            Text(
              l.madeWith,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
