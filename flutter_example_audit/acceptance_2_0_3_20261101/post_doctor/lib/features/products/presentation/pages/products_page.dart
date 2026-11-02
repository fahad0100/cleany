import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/core/state/use_case_state.dart';
import 'package:cleany_store/components/product_card/product_card_widget.dart';
import 'package:cleany_store/components/status_panel/status_panel_widget.dart';
import 'package:cleany_store/components/quantity_stepper/cubit/quantity_stepper_cubit.dart';
import 'package:cleany_store/components/quantity_stepper/quantity_stepper_widget.dart';
import 'package:cleany_store/features/carts/domain/entities/cart_draft.dart';

import '../../domain/entities/products_entity.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.createQuantityController});
  final QuantityStepperCubit Function() createQuantityController;
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(ProductsEntity product, int quantity) => context.go(
    '/carts',
    extra: CartDraft(productId: product.id, quantity: quantity),
  );
  void _details(ProductsEntity product) {
    var quantity = 1;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => BlocProvider(
        create: (_) => widget.createQuantityController(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.network(
                    product.image,
                    height: 210,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_outlined, size: 80),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 1,
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF163F35),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(product.description),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.quantity,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    QuantityStepperWidget(
                      onChanged: (value) => quantity = value,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('detail-add-to-cart'),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _add(product, quantity);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(context.l10n.addToCart),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ProductsCubit, ProductsState>(
    builder: (context, state) {
      final l = context.l10n;
      final cubit = context.read<ProductsCubit>();
      final items = cubit.visibleProducts;
      final categories = state is ProductsSuccess
          ? state.products.map((p) => p.category).toSet().toList()
          : <String>[];
      return RefreshIndicator(
        onRefresh: cubit.load,
        child: CustomScrollView(
          key: const PageStorageKey('catalog-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF378E65),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          l.demo,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: Color(0xFF5D786B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.catalogTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(l.catalogSubtitle),
                    const SizedBox(height: 20),
                    TextField(
                      key: const Key('product-search'),
                      controller: _search,
                      onChanged: cubit.search,
                      decoration: InputDecoration(
                        hintText: l.searchProducts,
                        prefixIcon: const Icon(Icons.search, size: 22),
                        suffixIcon: IconButton(
                          tooltip: l.refresh,
                          onPressed: () {
                            _search.clear();
                            cubit.search('');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.getFeaturedProductStatus
                        case UseCaseSuccess<ProductsEntity>(:final value)) ...[
                      InkWell(
                        onTap: () => _details(value),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFEAE1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.spotlight,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF397361),
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Text(
                                      value.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF163F35),
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Text(
                                      l.viewProduct,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                        color: Color(0xFF397361),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(10),
                                  child: Image.network(
                                    value.image,
                                    width: 82,
                                    height: 92,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final category in <String?>[null, ...categories])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                label: Text(category ?? l.all),
                                selected: state.category == category,
                                onSelected: (_) =>
                                    cubit.selectCategory(category),
                                showCheckmark: false,
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFF163F35),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: state.category == category
                                      ? Colors.white
                                      : const Color(0xFF52625D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${items.length} ${l.items}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: cubit.toggleSort,
                          icon: const Icon(Icons.swap_vert, size: 16),
                          label: Text(
                            state.priceAscending ? l.priceSort : l.featuredSort,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (state is ProductsLoading || state is ProductsInitial)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state case ProductsFailure(:final failure))
              SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanelWidget(
                  title: context.failureText(failure),
                  onRetry: cubit.load,
                  retryLabel: l.retry,
                  icon: Icons.wifi_off_rounded,
                ),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StatusPanelWidget(
                  title: l.noResults,
                  description: l.noProductsHint,
                  onRetry: () {
                    _search.clear();
                    cubit.search('');
                    cubit.selectCategory(null);
                  },
                  retryLabel: l.all,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) => SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = items[index];
                      return ProductCardWidget(
                        product: product,
                        onTap: () => _details(product),
                        onAdd: () => _add(product, 1),
                      );
                    }, childCount: items.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.crossAxisExtent > 800 ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 292,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
