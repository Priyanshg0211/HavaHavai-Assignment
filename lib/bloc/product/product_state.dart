import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  final int currentPage;
  final int totalProducts;
  final String? activeFilter;
  final String? searchQuery;

  ProductLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalProducts,
    this.activeFilter,
    this.searchQuery,
  });

  @override
  List<Object> get props => [
    products,
    hasReachedMax,
    currentPage,
    totalProducts,
    activeFilter ?? '',
    searchQuery ?? '',
  ];

  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    int? currentPage,
    int? totalProducts,
    String? activeFilter,
    String? searchQuery,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalProducts: totalProducts ?? this.totalProducts,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);

  @override
  List<Object> get props => [message];
}
