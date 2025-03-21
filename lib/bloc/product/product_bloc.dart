import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<Product> _cachedProducts = [];
  bool _isLoading = false;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      _currentPage = 1;
      final products = await productRepository.getProducts(
        page: _currentPage,
        limit: event.limit,
      );

      final totalProducts = await productRepository.getTotalProductCount();
      final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

      _cachedProducts = products;

      emit(
        ProductLoaded(
          products: _cachedProducts,
          hasReachedMax: hasReachedMax,
          currentPage: _currentPage,
          totalProducts: totalProducts,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      if (state is ProductLoaded && !_isLoading) {
        _isLoading = true;
        final currentState = state as ProductLoaded;

        if (currentState.hasReachedMax) {
          _isLoading = false;
          return;
        }

        _currentPage++;

        final moreProducts = await productRepository.getProducts(
          page: _currentPage,
          limit: _itemsPerPage,
        );

        final totalProducts = await productRepository.getTotalProductCount();
        final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

        // Filter out any duplicates when appending
        final existingIds = _cachedProducts.map((p) => p.id).toSet();
        final uniqueMoreProducts =
            moreProducts.where((p) => !existingIds.contains(p.id)).toList();
        _cachedProducts = [..._cachedProducts, ...uniqueMoreProducts];

        emit(
          currentState.copyWith(
            products: _cachedProducts,
            hasReachedMax: hasReachedMax,
            currentPage: _currentPage,
            totalProducts: totalProducts,
            isLoadingMore: false,
          ),
        );
        
        _isLoading = false;
      }
    } catch (e) {
      _isLoading = false;
      emit(ProductError(e.toString()));
    }
  }
}