import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/storage/session_store.dart';

import 'config/store_preferences.dart';

/// Navigation and language preference belong to App, outside business features.
class StoreShell extends StatelessWidget {
  const StoreShell({
    super.key,
    required this.child,
    required this.location,
    required this.preferences,
    required this.session,
  });
  final Widget child;
  final String location;
  final StorePreferences preferences;
  final SessionStore session;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final paths = ['/products', '/carts', '/users', '/auth'];
    final index = paths.indexOf(location);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF163F35),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'cleany / store',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('language-toggle'),
            onPressed: preferences.toggleLanguage,
            child: Text(l.language),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.go(paths[i]);
        },
        destinations: [
          NavigationDestination(
            key: const Key('nav-products'),
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l.catalog,
          ),
          NavigationDestination(
            key: const Key('nav-carts'),
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: l.carts,
          ),
          NavigationDestination(
            key: const Key('nav-users'),
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l.users,
          ),
          NavigationDestination(
            key: const Key('nav-auth'),
            icon: ValueListenableBuilder<SessionData?>(
              valueListenable: session,
              builder: (_, s, _) => Icon(
                s == null ? Icons.person_outline : Icons.verified_user_outlined,
              ),
            ),
            selectedIcon: const Icon(Icons.person),
            label: l.account,
          ),
        ],
      ),
    );
  }
}
