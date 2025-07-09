class Flight {
  final String airline;
  final String from;
  final String to;
  final String departTime;
  final String arriveTime;
  final String price;
  final String token;

  Flight({
    required this.airline,
    required this.from,
    required this.to,
    required this.departTime,
    required this.arriveTime,
    required this.price,
        required this.token,

  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      airline: json['airline'] ?? 'Unknown Airline',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      departTime: json['departTime'] ?? '',
      arriveTime: json['arriveTime'] ?? '',
      price: json['price'].toString(), // Safely convert int to string
            token: json['token'], // Safely convert int to string

    );
  }
}
