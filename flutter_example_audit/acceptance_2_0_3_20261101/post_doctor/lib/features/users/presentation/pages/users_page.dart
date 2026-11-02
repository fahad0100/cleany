import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';

import '../../domain/entities/users_entity.dart';
import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';

/// Displays domain profiles, never the API's password fields.
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  void _profile(BuildContext context, int id) {
    final cubit = context.read<UsersCubit>();
    cubit.getUserProfile(id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: switch (state.getUserProfileStatus) {
                  UseCaseLoading<UsersEntity>() => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  UseCaseSuccess<UsersEntity>(:final value) => Column(
                    key: const Key('profile-details'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_pin_circle_outlined, size: 50),
                      const SizedBox(height: 16),
                      Text(
                        '${value.firstName} ${value.lastName}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text('@${value.username}'),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.alternate_email),
                        title: Text(value.email),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(value.phone),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(
                          '${value.street}, ${value.city} ${value.zipcode}',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  UseCaseFailure<UsersEntity>(:final failure) =>
                    StatusPanelWidget(
                      title: context.failureText(failure),
                      onRetry: () => cubit.getUserProfile(id),
                      retryLabel: context.l10n.retry,
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        final cubit = context.read<UsersCubit>();
        return RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                l.usersTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(l.usersSubtitle),
              const SizedBox(height: 22),
              TextField(
                key: const Key('user-search'),
                onChanged: cubit.search,
                decoration: InputDecoration(
                  hintText: l.searchUsers,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 22),
              if (state is UsersLoading)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state case UsersFailure(:final failure))
                StatusPanelWidget(
                  title: context.failureText(failure),
                  onRetry: cubit.load,
                  retryLabel: l.retry,
                ),
              if (state is UsersSuccess && cubit.visibleUsers.isEmpty)
                StatusPanelWidget(title: l.noResults),
              for (final user in cubit.visibleUsers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      key: Key('user-${user.id}'),
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEAF0E6),
                        foregroundColor: const Color(0xFF163F35),
                        child: Text(
                          (user.firstName.isEmpty
                              ? '?'
                              : user.firstName.substring(0, 1).toUpperCase()),
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('@${user.username}  ·  ${user.city}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _profile(context, user.id),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
