/// A business request, independent of HTTP and JSON.
class CartDraft {
  const CartDraft({
    required this.productId,
    this.quantity = 1,
    this.userId = 1,
  });
  final int productId;
  final int quantity;
  final int userId;
}
