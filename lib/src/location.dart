class Location {
  final double lat;
  final double lon;
  String? address;
  Location({
    required this.lat,
    required this.lon,
    this.address,
  });

  Location.fromMap(Map<String, Object?> data)
      : lat = data['lat'] as double,
        lon = data['lon'] as double,
        address = data['address'] as String?;

  Map<String, Object?> toMap() => {
        'lat': lat,
        'lon': lon,
        'address': address,
      };

  @override
  String toString() {
    return address ?? '$lat, $lon';
  }

  String get gmapsUrl =>
      'https://www.google.com/maps/search/?api=1&${address == null ? Uri.encodeComponent('query=$lat,$lon') : Uri.encodeComponent(address!)}';
}

final dummyLocation = Location(
  lat: 61.7859675,
  lon: 34.3523533,
  address:
      "Петрозаводский государственный университет, проспект Ленина, Центр (район Петрозаводска), Петрозаводск, Республика Карелия, Россия, 185000",
);
