import '../entities/carts_entity.dart';
import '../../../products/domain/entities/products_entity.dart';

/// Joins business entities; transport DTOs never cross this boundary.
CartsEntity enrichCart(CartsEntity cart, List<ProductsEntity> products) {
  final index = {for (final product in products) product.id: product};
  return cart.copyWith(
    products: cart.products.map((line) {
      final p = index[line.productId];
      return line.copyWith(
        title: p?.title ?? 'Product #${line.productId}',
        image: p?.image ?? '',
        unitPrice: p?.price ?? 0,
      );
    }).toList(),
  );
}
