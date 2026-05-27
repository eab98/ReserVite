class Reservation {
  final int id;
  final String name;
  final String status;
  final String city;
  final DateTime dateTime;
  final int numberOfGuests;

  const Reservation({
    required this.id,
    required this.name,
    required this.status,
    required this.city,
    required this.dateTime,
    required this.numberOfGuests
  });

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        city: json['city'],
        dateTime: DateTime.parse(json['datetime']),
        numberOfGuests: json['number_of_guests']);
  }


}