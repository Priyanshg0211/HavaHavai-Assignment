import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';

class ProductGridItem extends StatefulWidget {
  final Product product;
  final TextStyle headlineFont;
  final TextStyle bodyFont;

  const ProductGridItem({
    Key? key,
    required this.product,
    required this.headlineFont,
    required this.bodyFont,
  }) : super(key: key);

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  bool _showQuantityControls = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Initialize from cart state
    _syncWithCartState();
  }

  void _syncWithCartState() {
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      final productInCart = cartState.items.firstWhere(
        (p) => p.id == widget.product.id,
        orElse: () => widget.product.copyWith(quantity: 0),
      );

      if (productInCart.quantity > 0) {
        setState(() {
          _quantity = productInCart.quantity;
          _showQuantityControls = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithCartState();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the discounted price
    final discountedPrice =
        widget.product.price -
        (widget.product.price * widget.product.discountPercentage / 100);

    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          final productInCart = state.items.firstWhere(
            (p) => p.id == widget.product.id,
            orElse: () => widget.product.copyWith(quantity: 0),
          );

          setState(() {
            if (productInCart.quantity > 0) {
              _quantity = productInCart.quantity;
              _showQuantityControls = true;
            } else {
              _quantity = 1;
              _showQuantityControls = false;
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    // Product image
                    Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Image.network(
                        widget.product.thumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                              strokeWidth: 2,
                              color: Colors.pinkAccent,
                            ),
                          );
                        },
                      ),
                    ),

                    // Discount badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, size: 18),
                          color: Colors.pinkAccent,
                          constraints: const BoxConstraints(
                            minHeight: 36,
                            minWidth: 36,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // Favorite action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added ${widget.product.title} to favorites',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product info
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product brand and title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.brand,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Price and add to cart button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${discountedPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          // Add to cart button or quantity controls
                          _showQuantityControls
                              ? _buildQuantityControls()
                              : _buildAddToCartButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showQuantityControls = true;
        });
        // Add to cart when button is first pressed
        context.read<CartBloc>().add(AddToCart(widget.product));

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${widget.product.title} to cart'),
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          InkWell(
            onTap: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
                // Update cart quantity when decreased
                context.read<CartBloc>().add(
                  UpdateQuantity(widget.product, _quantity),
                );
              } else {
                // If quantity is 1, hide controls and remove from cart
                setState(() {
                  _showQuantityControls = false;
                  _quantity = 1;
                });
                context.read<CartBloc>().add(RemoveFromCart(widget.product));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                _quantity > 1 ? Icons.remove : Icons.delete,
                size: 16,
                color: Colors.grey[700],
              ),
            ),
          ),

          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '$_quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Increase button
          InkWell(
            onTap: () {
              setState(() {
                _quantity++;
              });

              // Update quantity in cart
              context.read<CartBloc>().add(
                UpdateQuantity(widget.product, _quantity),
              );

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${widget.product.title} to cart'),
                  duration: const Duration(milliseconds: 500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.add, size: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
