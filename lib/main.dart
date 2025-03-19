import 'package:ecommerce/repositories/product_repository.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/product/product_event.dart';
import 'bloc/cart/cart_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  ProductBloc(repository: ProductRepository())
                    ..add(FetchProducts()),
        ),
        BlocProvider(create: (context) => CartBloc()),
      ],
      child: MaterialApp(
        title: 'Shopping Cart App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.pinkAccent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pinkAccent,
            primary: Colors.pinkAccent,
          ),
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xffFAE1EB),
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(), // Add this line
      ),
    );
  }
}
