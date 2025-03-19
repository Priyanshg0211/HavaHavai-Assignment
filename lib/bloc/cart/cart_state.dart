import 'package:ecommerce/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<Product> items;

  const CartLoaded({this.items = const []});

  double get totalPrice => items.fold(0, (total, product) =>
      total + (product.discountedPrice * product.quantity));

  int get itemCount => items.fold(0, (count, product) => count + product.quantity);

  @override
  List<Object> get props => [items, totalPrice, itemCount];

  CartLoaded copyWith({List<Product>? items}) {
    return CartLoaded(items: items ?? this.items);
  }
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}