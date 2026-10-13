import '../../data/models/product_model.dart';

abstract class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsLoaded extends ProductDetailsState {
  final ProductModel product;

  const ProductDetailsLoaded(this.product);
}

class ProductDetailsUnavailable extends ProductDetailsState {
  const ProductDetailsUnavailable();
}

class ProductDetailsFailure extends ProductDetailsState {
  final String message;

  const ProductDetailsFailure(this.message);
}
