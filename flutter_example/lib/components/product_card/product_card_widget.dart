import 'package:flutter/material.dart';
import 'package:cleany_store/core/localization/store_localization.dart';
import 'package:cleany_store/features/products/domain/entities/products_entity.dart';

/// Domain-only input makes this generated stateless component reusable and testable.
class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });
  final ProductsEntity product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      key: Key('product-${product.id}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    cacheWidth: 420,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 38,
                      color: Colors.grey,
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.category.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                letterSpacing: .8,
                color: Color(0xFF6D7C75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Color(0xFF163F35),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFD5933C),
                  size: 14,
                ),
                const SizedBox(width: 3),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6D7C75),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  key: Key('add-${product.id}'),
                  tooltip: context.l10n.addToCart,
                  onPressed: onAdd,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF163F35),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(32, 32),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
