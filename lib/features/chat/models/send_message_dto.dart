import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class SendMessageDto {
  final String? text;
  final Iterable<String>? images;
  final LatLng? coordinates;

  const SendMessageDto({
    this.text,
    this.images,
    this.coordinates,
  });
}

@immutable
class LatLng {
  final double latitude;
  final double longitude;
  final double? zoom;

  const LatLng({
    required this.latitude,
    required this.longitude,
    this.zoom,
  });

  factory LatLng.fromGeopoints(List<double> geopoints) {
    assert(geopoints.length >= 2);

    return LatLng(
      latitude: geopoints[0],
      longitude: geopoints[1],
      zoom: geopoints.length > 2 ? geopoints[2] : null,
    );
  }

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude, zoom: $zoom}';
  }
}