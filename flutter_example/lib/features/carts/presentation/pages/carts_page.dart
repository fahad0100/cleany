import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';

import '../../domain/entities/carts_entity.dart';
import '../bloc/carts_bloc.dart';
import '../bloc/carts_event.dart';
import '../bloc/carts_state.dart';

class CartsPage extends StatelessWidget {
  const CartsPage({super.key});
  @override
  Widget build(BuildContext context) => BlocConsumer<CartsBloc, CartsState>(
    listenWhen: (a, b) => a.deleteCartStatus != b.deleteCartStatus,
    listener: (context, state) {
      if (state.deleteCartStatus is UseCaseSuccess<void>) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.cartDeleted)));
      }
      if (state.deleteCartStatus case UseCaseFailure<void>(:final failure)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.failureText(failure))));
      }
    },
    builder: (context, state) {
      final l = context.l10n;
      final bloc = context.read<CartsBloc>();
      final carts = state is CartsSuccess
          ? state.carts.where((c) => !state.deletedIds.contains(c.id)).toList()
          : <CartsEntity>[];
      final created = state.createCartStatus;
      return RefreshIndicator(
        onRefresh: bloc.reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              l.cartsTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(l.cartsSubtitle),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFDD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.science_outlined,
                    color: Color(0xFF9E6431),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.demoNotice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF87603A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (created is UseCaseLoading<CartsEntity>)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(l.creatingCart),
                  ],
                ),
              ),
            if (created case UseCaseFailure<CartsEntity>(:final failure))
              StatusPanelWidget(
                title: context.failureText(failure),
                retryLabel: l.browseProducts,
                onRetry: () => context.go('/products'),
              ),
            if (created case UseCaseSuccess<CartsEntity>(:final value))
              if (!state.deletedIds.contains(value.id)) ...[
                Text(l.newCart, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                _CartCard(
                  cart: value,
                  canDelete: state.deleteCartStatus is! UseCaseLoading<void>,
                ),
                const SizedBox(height: 22),
              ],
            if (state is CartsInitial || state is CartsLoading)
              const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state case CartsFailure(:final failure))
              StatusPanelWidget(
                title: context.failureText(failure),
                onRetry: () => bloc.add(const CartsEvent.requested()),
                retryLabel: l.retry,
              )
            else if (carts.isEmpty)
              StatusPanelWidget(
                title: l.emptyCarts,
                onRetry: () => context.go('/products'),
                retryLabel: l.browseProducts,
              )
            else ...[
              for (final cart in carts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _CartCard(
                    cart: cart,
                    canDelete: state.deleteCartStatus is! UseCaseLoading<void>,
                  ),
                ),
            ],
          ],
        ),
      );
    },
  );
}

class _CartCard extends StatelessWidget {
  const _CartCard({required this.cart, required this.canDelete});
  final CartsEntity cart;
  final bool canDelete;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final total = cart.products.fold<double>(
      0,
      (sum, p) => sum + p.quantity * p.unitPrice,
    );
    return Card(
      key: Key('cart-${cart.id}'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l.cartLabel} #${cart.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${l.userLabel} #${cart.userId}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              MaterialLocalizations.of(context).formatShortDate(cart.date),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            for (final line in cart.products)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 50,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: line.image.isEmpty
                          ? const Icon(Icons.shopping_bag_outlined)
                          : Image.network(
                              line.image,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.image_outlined),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        line.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '×${line.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.total,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: Key('delete-cart-${cart.id}'),
                onPressed: canDelete
                    ? () => context.read<CartsBloc>().add(
                        CartsEvent.deleteCartRequested(cart.id),
                      )
                    : null,
                icon: const Icon(Icons.delete_outline, size: 17),
                label: Text(
                  l.simulateDelete,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
