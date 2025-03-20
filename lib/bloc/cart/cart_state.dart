import 'package:ecommerce/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Product> items;

  const CartLoaded({required this.items});

  double get totalPrice {
    return items.fold(0, (sum, item) {
      // Calculate with discount
      final discountedPrice =
          item.price - (item.price * item.discountPercentage / 100);
      return sum + (discountedPrice * item.quantity);
    });
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  List<Object> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}
