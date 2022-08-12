import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class SendMessageDto {
  final int chatId;
  final String? text;
  final Iterable<String>? images;
  final LatLng? coordinates;

  const SendMessageDto({
    required this.chatId,
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

  List<double> toGeoPoints() => <double>[
        latitude,
        longitude,
        if (zoom != null) zoom!,
      ];

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude, zoom: $zoom}';
  }
}
