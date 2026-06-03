class Reservation {
  final int id;
  final String name;
  final String status;
  final String? city;
  final DateTime dateTime;
  final int numberOfGuests;
  final String? restoPhone;
  final String? restoAddress;
  final String? specialRequests;
  final int? restoId;

  const Reservation({
    required this.id,
    required this.name,
    required this.status,
    this.city,
    required this.dateTime,
    required this.numberOfGuests,
    this.restoAddress,
    this.restoPhone,
    this.specialRequests,
    this.restoId


  });

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        city: json['city'],
        dateTime: DateTime.parse(json['datetime']),
        numberOfGuests: json['number_of_guests'],
        restoAddress : json['address'],
        restoPhone : json['phone'],
      specialRequests: json['special_request'],
      restoId: json['resto_id']
    );
  }


}