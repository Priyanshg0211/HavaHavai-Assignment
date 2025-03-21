class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final List<String> images;
  final String thumbnail;
  int quantity;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.images,
    required this.thumbnail,
    this.quantity = 1,
  });

  double get discountedPrice {
    return price - (price * discountPercentage / 100);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, 
      title: json['title'] ?? 'No Title', 
      description: json['description'] ?? 'No Description', 
      category: json['category'] ?? 'No Category', 
      price: (json['price'] ?? 0.0).toDouble(),
      discountPercentage:
          (json['discountPercentage'] ?? 0.0).toDouble(), 
      rating: (json['rating'] ?? 0.0).toDouble(), 
      stock: json['stock'] ?? 0, 
      tags: List<String>.from(json['tags'] ?? []),
      brand: json['brand'] ?? 'No Brand', 
      sku: json['sku'] ?? 'No SKU', 
      weight: (json['weight'] ?? 0.0).toDouble(), 
      warrantyInformation:
          json['warrantyInformation'] ?? 'No Warranty', 
      shippingInformation:
          json['shippingInformation'] ?? 'No Shipping Info', 
      availabilityStatus:
          json['availabilityStatus'] ?? 'No Availability', 
      returnPolicy: json['returnPolicy'] ?? 'No Return Policy', 
      minimumOrderQuantity: json['minimumOrderQuantity'] ?? 0, 
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'] ?? 'No Thumbnail', 
    );
  }

  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      tags: tags,
      brand: brand,
      sku: sku,
      weight: weight,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus,
      returnPolicy: returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity,
      images: images,
      thumbnail: thumbnail,
      quantity: quantity ?? this.quantity,
    );
  }
}
