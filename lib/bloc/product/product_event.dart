import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int limit;

  const LoadProducts({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}

class LoadMoreProducts extends ProductEvent {}