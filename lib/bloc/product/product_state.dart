import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  final int currentPage;
  final int totalProducts;
  final bool isLoadingMore;

  const ProductLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalProducts,
    this.isLoadingMore = false,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    int? currentPage,
    int? totalProducts,
    bool? isLoadingMore,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalProducts: totalProducts ?? this.totalProducts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        products,
        hasReachedMax,
        currentPage,
        totalProducts,
        isLoadingMore,
      ];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}