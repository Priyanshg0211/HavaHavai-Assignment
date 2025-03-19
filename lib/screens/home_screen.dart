import 'package:ecommerce/widgets/product_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10; // Define how many items per page

  @override
  void initState() {
    super.initState();
    // Load initial products
    context.read<ProductBloc>().add(
      LoadProducts(page: 1, limit: _itemsPerPage),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductLoaded && _isLoadingMore) {
            setState(() {
              _isLoadingMore = false;
              _currentPage = state.currentPage;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductInitial ||
              (state is ProductLoading && !(state is ProductLoaded))) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            return _buildProductGrid(context, state);
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        LoadProducts(page: 1, limit: _itemsPerPage),
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 60,
      centerTitle: true,
      title: const Text(
        'Catalogue',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int itemCount = 0;
            if (state is CartLoaded) {
              itemCount = state.itemCount;
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                ),
                if (itemCount > 0)
                  Positioned(
                    top: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context, ProductLoaded state) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Products grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(
                LoadProducts(page: 1, limit: _itemsPerPage),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.65,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  return ProductGridItem(product: state.products[index]);
                },
              ),
            ),
          ),
        ),

        // Pagination controls at bottom
        _buildPaginationControls(state),
      ],
    );
  }

  Widget _buildPaginationControls(ProductLoaded state) {
    final int totalPages = (state.totalProducts / _itemsPerPage).ceil();

    return Container(
      height: 64, // Fixed height for the pagination container
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed:
                _currentPage > 1
                    ? () {
                      setState(() {
                        _isLoadingMore = true;
                      });
                      context.read<ProductBloc>().add(
                        LoadProducts(
                          page: _currentPage - 1,
                          limit: _itemsPerPage,
                        ),
                      );
                    }
                    : null,
          ),

          // Page indicators
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildPageIndicators(totalPages),
            ),
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed:
                _currentPage < totalPages
                    ? () {
                      setState(() {
                        _isLoadingMore = true;
                      });
                      context.read<ProductBloc>().add(
                        LoadProducts(
                          page: _currentPage + 1,
                          limit: _itemsPerPage,
                        ),
                      );
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(int totalPages) {
    // Show a maximum of 5 page indicators
    const int maxVisiblePages = 5;
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > maxVisiblePages) {
      int middlePoint = maxVisiblePages ~/ 2;

      if (_currentPage <= middlePoint) {
        endPage = maxVisiblePages;
      } else if (_currentPage >= totalPages - middlePoint) {
        startPage = totalPages - maxVisiblePages + 1;
      } else {
        startPage = _currentPage - middlePoint;
        endPage = _currentPage + middlePoint;
      }
    }

    List<Widget> indicators = [];

    if (startPage > 1) {
      indicators.add(_buildPageButton(1));
      if (startPage > 2) {
        indicators.add(_buildEllipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      indicators.add(_buildPageButton(i));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        indicators.add(_buildEllipsis());
      }
      indicators.add(_buildPageButton(totalPages));
    }

    return Row(children: indicators);
  }

  Widget _buildPageButton(int pageNumber) {
    final bool isCurrentPage = pageNumber == _currentPage;

    return InkWell(
      onTap:
          isCurrentPage
              ? null
              : () {
                setState(() {
                  _isLoadingMore = true;
                });
                context.read<ProductBloc>().add(
                  LoadProducts(page: pageNumber, limit: _itemsPerPage),
                );
              },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCurrentPage ? Colors.pinkAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrentPage ? Colors.pinkAccent : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isCurrentPage ? Colors.white : Colors.black87,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: const Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
