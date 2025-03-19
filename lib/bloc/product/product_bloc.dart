import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  final int limit = 10;
  
  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }
  
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final result = await repository.fetchProducts(event.page, limit);
      final products = result['products'] as List<Product>;
      final total = result['total'] as int;
      
      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length >= total,
        currentPage: event.page,
        totalProducts: total,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
  
  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final result = await repository.fetchProducts(nextPage, limit);
        final newProducts = result['products'] as List<Product>;
        final total = result['total'] as int;
        
        emit(ProductLoaded(
          products: [...currentState.products, ...newProducts],
          hasReachedMax: (currentState.products.length + newProducts.length) >= total,
          currentPage: nextPage,
          totalProducts: total,
        ));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }
}
