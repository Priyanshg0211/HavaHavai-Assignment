import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      _currentPage = event.page;
      final products = await productRepository.getProducts(
        page: _currentPage,
        limit: event.limit,
      );

      final totalProducts = await productRepository.getTotalProductCount();
      final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

      emit(
        ProductLoaded(
          products: products,
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
      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;

        if (currentState.hasReachedMax) return;

        _currentPage++;

        List<Product> moreProducts;
        if (currentState.activeFilter != null) {
          moreProducts = await productRepository.getProductsByCategory(
            category: currentState.activeFilter!,
            page: _currentPage,
            limit: _itemsPerPage,
          );
        } else if (currentState.searchQuery != null) {
          moreProducts = await productRepository.searchProducts(
            query: currentState.searchQuery!,
            page: _currentPage,
            limit: _itemsPerPage,
          );
        } else {
          moreProducts = await productRepository.getProducts(
            page: _currentPage,
            limit: _itemsPerPage,
          );
        }

        final totalProducts = await productRepository.getTotalProductCount(
          category: currentState.activeFilter,
          searchQuery: currentState.searchQuery,
        );

        final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

        emit(
          currentState.copyWith(
            products: List.of(currentState.products)..addAll(moreProducts),
            hasReachedMax: hasReachedMax,
            currentPage: _currentPage,
            totalProducts: totalProducts,
          ),
        );
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      _currentPage = 1;

      final products = await productRepository.searchProducts(
        query: event.query,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      final totalProducts = await productRepository.getTotalProductCount(
        searchQuery: event.query,
      );

      final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

      emit(
        ProductLoaded(
          products: products,
          hasReachedMax: hasReachedMax,
          currentPage: _currentPage,
          totalProducts: totalProducts,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      _currentPage = 1;

      final products = await productRepository.getProductsByCategory(
        category: event.category,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      final totalProducts = await productRepository.getTotalProductCount(
        category: event.category,
      );

      final hasReachedMax = _currentPage * _itemsPerPage >= totalProducts;

      emit(
        ProductLoaded(
          products: products,
          hasReachedMax: hasReachedMax,
          currentPage: _currentPage,
          totalProducts: totalProducts,
          activeFilter: event.category,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
