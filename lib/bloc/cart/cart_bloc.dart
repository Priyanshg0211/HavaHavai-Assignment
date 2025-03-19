import 'package:ecommerce/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoaded(items: [])) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final productIndex = currentState.items.indexWhere((p) => p.id == event.product.id);

        if (productIndex >= 0) {
          // Product already in cart, update quantity
          final updatedItems = List<Product>.from(currentState.items);
          final currentProduct = updatedItems[productIndex];
          updatedItems[productIndex] = currentProduct.copyWith(
            quantity: currentProduct.quantity + 1,
          );
          emit(CartLoaded(items: updatedItems));
        } else {
          // Add new product to cart
          emit(CartLoaded(
            items: [...currentState.items, event.product.copyWith(quantity: 1)],
          ));
        }
      }
    } catch (e) {
      emit(CartError(message: 'Failed to add product to cart: $e'));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final updatedItems = currentState.items.where((p) => p.id != event.product.id).toList();
        emit(CartLoaded(items: updatedItems));
      }
    } catch (e) {
      emit(CartError(message: 'Failed to remove product from cart: $e'));
    }
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    try {
      final currentState = state;
      if (currentState is CartLoaded) {
        final updatedItems = List<Product>.from(currentState.items);
        final productIndex = updatedItems.indexWhere((p) => p.id == event.product.id);

        if (productIndex >= 0) {
          if (event.quantity <= 0) {
            // Remove product if quantity is 0 or less
            updatedItems.removeAt(productIndex);
          } else {
            // Update quantity
            updatedItems[productIndex] = updatedItems[productIndex].copyWith(
              quantity: event.quantity,
            );
          }
          emit(CartLoaded(items: updatedItems));
        }
      }
    } catch (e) {
      emit(CartError(message: 'Failed to update product quantity: $e'));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartLoaded(items: []));
  }
}