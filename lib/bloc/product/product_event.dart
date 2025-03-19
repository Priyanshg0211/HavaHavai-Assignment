import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int limit;

  LoadProducts({required this.page, required this.limit});

  @override
  List<Object> get props => [page, limit];
}

class LoadMoreProducts extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;

  SearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

class FilterProductsByCategory extends ProductEvent {
  final String category;

  FilterProductsByCategory({required this.category});

  @override
  List<Object> get props => [category];
}
