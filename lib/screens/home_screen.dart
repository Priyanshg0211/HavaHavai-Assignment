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
    final state = context.read<ProductBloc>().state;
    if (!(state is ProductLoaded)) return;
    
    final ProductLoaded productState = state;
    
    // Load more when scrolled to 80% of the content
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        !productState.hasReachedMax) {
      setState(() {
        _isLoadingMore = true;
      });
      context.read<ProductBloc>().add(LoadMoreProducts());
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
          if (state is ProductLoaded) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductInitial ||
              (state is ProductLoading && !(state is ProductLoaded))) {
            return _buildLoadingIndicator();
          } else if (state is ProductLoaded) {
            return _buildProductGrid(context, state);
          } else if (state is ProductError) {
            return _buildErrorWidget(state);
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

  Widget _buildLoadingIndicator() {
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
  }

  Widget _buildErrorWidget(ProductError state) {
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
              // This part needs to be implemented based on your CartState
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
    return RefreshIndicator(
      color: Colors.pinkAccent,
      onRefresh: () async {
        context.read<ProductBloc>().add(
          LoadProducts(page: 1, limit: _itemsPerPage),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ProductGridItem(
                      product: state.products[index],
                      headlineFont: headlineFont,
                      bodyFont: bodyFont,
                    );
                  },
                  childCount: state.products.length,
                ),
              ),
            ),
            
            // Loading indicator at the bottom
            SliverToBoxAdapter(
              child: _isLoadingMore
                  ? Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.pinkAccent,
                      ),
                    )
                  : state.hasReachedMax
                      ? Container(
                          height: 60,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No more products to load',
                            style: bodyFont.copyWith(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        )
                      : const SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}