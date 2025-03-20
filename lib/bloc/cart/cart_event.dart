import 'package:ecommerce/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;

  const AddToCart(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveFromCart extends CartEvent {
  final Product product;

  const RemoveFromCart(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateQuantity extends CartEvent {
  final Product product;
  final int quantity;

  const UpdateQuantity(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}

class ClearCart extends CartEvent {}
