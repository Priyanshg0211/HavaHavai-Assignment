import 'package:ecommerce/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/cart/cart_event.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a consistent typography theme
    final headingStyle = GoogleFonts.montserrat(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final bodyStyle = GoogleFonts.inter(color: Colors.black87);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: headingStyle.copyWith(fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is empty',
                      style: headingStyle.copyWith(
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items to get started',
                      style: bodyStyle.copyWith(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Continue Shopping'),
                      onPressed:
                          () => Navigator.of(context).pushNamed('/products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'} in your cart',
                        style: headingStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        label: Text(
                          'Clear Cart',
                          style: bodyStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    'Clear cart?',
                                    style: headingStyle.copyWith(fontSize: 18),
                                  ),
                                  content: Text(
                                    'This will remove all items from your cart.',
                                    style: bodyStyle.copyWith(fontSize: 16),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: bodyStyle.copyWith(fontSize: 16),
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Clear',
                                        style: bodyStyle.copyWith(
                                          fontSize: 16,
                                          color: Colors.redAccent,
                                        ),
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
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItem(
                        product: item,
                        headingStyle: headingStyle,
                        bodyStyle: bodyStyle,
                      );
                    },
                  ),
                ),
                CartSummary(
                  state: state,
                  headingStyle: headingStyle,
                  bodyStyle: bodyStyle,
                ),
              ],
            );
          } else if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: headingStyle.copyWith(
                      fontSize: 20,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${state.message}',
                    style: bodyStyle.copyWith(
                      fontSize: 16,
                      color: Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    onPressed: () {
                      // Add retry logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.pinkAccent),
                const SizedBox(height: 24),
                Text(
                  'Loading your cart...',
                  style: headingStyle.copyWith(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Product product;
  final TextStyle headingStyle;
  final TextStyle bodyStyle;

  const CartItem({
    Key? key,
    required this.product,
    required this.headingStyle,
    required this.bodyStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Remove Item',
                style: headingStyle.copyWith(fontSize: 18),
              ),
              content: Text(
                'Are you sure you want to remove ${product.title} from your cart?',
                style: bodyStyle.copyWith(fontSize: 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: bodyStyle.copyWith(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Remove',
                    style: bodyStyle.copyWith(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
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
            content: Text(
              '${product.title} removed from cart',
              style: bodyStyle.copyWith(fontSize: 14, color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () {
                context.read<CartBloc>().add(AddToCart(product));
              },
            ),
            backgroundColor: Colors.pinkAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 32,
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
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
                      style: headingStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: bodyStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '\$${product.discountedPrice.toStringAsFixed(2)}',
                          style: headingStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: bodyStyle.copyWith(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
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
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            '${product.quantity}',
                            style: bodyStyle.copyWith(
                              fontSize: 14,
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
                              SnackBar(
                                content: Text(
                                  'Maximum quantity reached',
                                  style: bodyStyle.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.pinkAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        }),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.grey[700],
                          ),
                          onPressed: () => _showRemoveConfirmation(context),
                          tooltip: 'Remove from cart',
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
            title: Text(
              'Remove Item',
              style: headingStyle.copyWith(fontSize: 18),
            ),
            content: Text(
              'Remove ${product.title} from your cart?',
              style: bodyStyle.copyWith(fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: bodyStyle.copyWith(fontSize: 16)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'Remove',
                  style: bodyStyle.copyWith(
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
        ),
        child: Icon(icon, size: 16, color: Colors.grey[800]),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final CartLoaded state;
  final TextStyle headingStyle;
  final TextStyle bodyStyle;

  const CartSummary({
    Key? key,
    required this.state,
    required this.headingStyle,
    required this.bodyStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = state.totalPrice;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.08; // Assuming 8% tax
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Shipping',
              shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
              secondaryColor: shipping == 0 ? Colors.green : null,
            ),
            if (shipping > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'Free shipping on orders over \$50',
                  style: bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            _buildSummaryRow('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 1,
              color: Colors.grey[200],
            ),
            _buildSummaryRow(
              'Total',
              '\$${total.toStringAsFixed(2)}',
              isBold: true,
              primaryColor: Colors.pinkAccent,
            ),
            const SizedBox(height: 24),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.shopping_cart_checkout,
                      color: Colors.white,
                    ),
                    label: const Text('CHECKOUT'),
                    onPressed: () {
                      // Placeholder for checkout functionality
                      Navigator.of(context).pushNamed('/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
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
          style: (isBold ? headingStyle : bodyStyle).copyWith(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: primaryColor ?? Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: (isBold ? headingStyle : bodyStyle).copyWith(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: secondaryColor ?? primaryColor ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
