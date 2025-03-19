import 'package:ecommerce/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/cart/cart_event.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/orders');
            },
            tooltip: 'Your Orders',
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                      onPressed:
                          () => Navigator.of(context).pushNamed('/products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'} in your cart',
                        style: const TextStyle(fontSize: 16),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear Cart'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Clear cart?'),
                                  content: const Text(
                                    'This will remove all items from your cart.',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('CANCEL'),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: const Text(
                                        'CLEAR',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                          ClearCart(),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItem(product: item);
                    },
                  ),
                ),
                CartSummary(state: state),
              ],
            );
          } else if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(fontSize: 16, color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Product product;

  const CartItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Remove Item'),
              content: Text(
                'Are you sure you want to remove ${product.title} from your cart?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'REMOVE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<CartBloc>().add(RemoveFromCart(product));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} removed from cart'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                context.read<CartBloc>().add(AddToCart(product));
              },
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Image.network(
                        product.thumbnail,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuantityButton(context, Icons.remove, () {
                          if (product.quantity > 1) {
                            context.read<CartBloc>().add(
                              UpdateQuantity(product, product.quantity - 1),
                            );
                          } else {
                            _showRemoveConfirmation(context);
                          }
                        }),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            '${product.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildQuantityButton(context, Icons.add, () {
                          if (product.quantity < 10) {
                            context.read<CartBloc>().add(
                              UpdateQuantity(product, product.quantity + 1),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maximum quantity reached'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () => _showRemoveConfirmation(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: Text('Remove ${product.title} from your cart?'),
            actions: [
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text(
                  'REMOVE',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  context.read<CartBloc>().add(RemoveFromCart(product));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[100],
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final CartLoaded state;

  const CartSummary({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = state.totalPrice;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.08; // Assuming 8% tax
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Shipping',
              shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
              secondaryColor: shipping == 0 ? Colors.green : null,
            ),
            if (shipping > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Free shipping on orders over \$50',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            _buildSummaryRow('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              '\$${total.toStringAsFixed(2)}',
              isBold: true,
              primaryColor: Colors.pinkAccent,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('CONTINUE SHOPPING'),
                    onPressed:
                        () => Navigator.of(context).pushNamed('/products'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.pinkAccent),
                      foregroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('CHECKOUT'),
                    onPressed: () {
                      // Placeholder for checkout functionality
                      Navigator.of(context).pushNamed('/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: primaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: secondaryColor ?? primaryColor,
          ),
        ),
      ],
    );
  }
}
