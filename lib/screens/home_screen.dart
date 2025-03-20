  import 'package:ecommerce/widgets/product_grid_item.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:google_fonts/google_fonts.dart';
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
    final int _itemsPerPage = 10;

    // Define fonts
    final headlineFont = GoogleFonts.poppins();
    final bodyFont = GoogleFonts.inter();

    @override
    void initState() {
      super.initState();
      // Load initial products
      context.read<ProductBloc>().add(
        LoadProducts(page: 1, limit: _itemsPerPage),
      );

      // Add scroll listener for infinite scrolling
      _scrollController.addListener(_onScroll);
    }

    void _onScroll() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        // Load more products when approaching the end of the list
        final state = context.read<ProductBloc>().state;
        if (state is ProductLoaded) {
          final totalPages = (state.totalProducts / _itemsPerPage).ceil();
          if (_currentPage < totalPages) {
            setState(() {
              _isLoadingMore = true;
            });
            context.read<ProductBloc>().add(
              LoadProducts(page: _currentPage + 1, limit: _itemsPerPage),
            );
          }
        }
      }
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.pinkAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Loading products...',
                      style: bodyFont.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ProductLoaded) {
              return _buildProductGrid(context, state);
            } else if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: bodyFont.copyWith(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(
                          LoadProducts(page: 1, limit: _itemsPerPage),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: bodyFont.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  'Unknown state',
                  style: bodyFont.copyWith(color: Colors.grey[800]),
                ),
              );
            }
          },
        ),
      );
    }

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        centerTitle: true,
        title: Text(
          'Catalogue',
          style: headlineFont.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int itemCount = 0;
              if (state is CartLoaded) {
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.shopping_cart_outlined,
                        size: 24,
                        color: Colors.grey[800],
                      ),
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
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          itemCount > 99 ? '99+' : '$itemCount',
                          style: bodyFont.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
          // Products grid
          SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              color: Colors.pinkAccent,
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
                  itemCount: state.products.length + (_isLoadingMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index < state.products.length) {
                      return ProductGridItem(
                        product: state.products[index],
                        headlineFont: headlineFont,
                        bodyFont: bodyFont,
                      );
                    } else {
                      // Show loading indicator at the end
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          // Pagination controls at bottom
          SafeArea(child: _buildPaginationControls(state)),
        ],
      );
    }

    Widget _buildPaginationControls(ProductLoaded state) {
      final int totalPages = (state.totalProducts / _itemsPerPage).ceil();

      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 6),
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
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: _currentPage > 1 ? Colors.grey[800] : Colors.grey[400],
                ),
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
            ),

            // Page indicators
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildPageIndicators(totalPages),
              ),
            ),

            // Next button
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color:
                      _currentPage < totalPages
                          ? Colors.grey[800]
                          : Colors.grey[400],
                ),
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
            ),
          ],
        ),
      );
    }

    Widget _buildPageIndicators(int totalPages) {
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
          width: 30,
          height: 30,
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
              style: bodyFont.copyWith(
                color: isCurrentPage ? Colors.white : Colors.grey[800],
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildEllipsis() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          '...',
          style: bodyFont.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      );
    }
  }
