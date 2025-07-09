class HotelDetail {
  final String hotelID;
  final String name;
  final String arrivalDate;
  final String departureDate;
  final String latitude;
  final String longitude;
  final String address;
  final String city;
  final String totalPrice;
  final String reviewCount;
  final String reviewScore;


  HotelDetail({
    required this.hotelID,
    required this.name,
    required this.arrivalDate,
    required this.departureDate,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.totalPrice,
    required this.reviewCount,
    required this.reviewScore,
  });

  factory HotelDetail.fromJson(Map<String,dynamic> json){
    return HotelDetail(
    hotelID: json['hotelID'].toString(),
    name: json['name'] ?? "",
    arrivalDate: json['arrivalDate'] ?? "", // corrected key
    departureDate: json['departureDate'] ?? "", // corrected key
    latitude: json['latitude']?.toString() ?? "",       
    longitude: json['longitude']?.toString() ?? "",    
    address: json['address'] ?? "", // corrected key
    city: json['city'] ?? "Singapore",
    totalPrice: json['totalPrice'].toString(), // corrected key
    reviewCount: json['reviewCount'].toString(),
    reviewScore: json['reviewScore'].toString(),
    );
  }
}

