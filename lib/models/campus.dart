import 'dart:convert';

import 'package:here_sdk/core.dart';

class Campus {
  int id;
  DateTime createdAt;
  String name;
  String slug;
  String domain;
  GeoCoordinates? location;
  String state;
  String country;

  Campus({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.slug,
    required this.domain,
    this.location,
    required this.state,
    required this.country,
  });

  Campus copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    String? slug,
    String? domain,
    GeoCoordinates? location,
    String? state,
    String? country,
  }) {
    return Campus(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      domain: domain ?? this.domain,
      location: location ?? this.location,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'name': name,
      'slug': slug,
      'domain': domain,
      'location': {
        'latitude': location?.latitude,
        'longitude': location?.longitude,
      },
      'state': state,
      'country': country,
    };
  }

  factory Campus.fromMap(Map<String, dynamic> map) {
    return Campus(
      id: map['id']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt'] ?? map['created_at']),
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      domain: map['domain'] ?? '',
      location: map['geoloc'] != null
          ? GeoCoordinates(
              map['geoloc']['latitude']?.toDouble() ?? 0,
              map['geoloc']['longitude']?.toDouble() ?? 0,
            )
          : null,
      state: map['state'] ?? '',
      country: map['country'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Campus.fromJson(String source) => Campus.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Campus(id: $id, createdAt: $createdAt, name: $name, slug: $slug, domain: $domain, location: $location, state: $state, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Campus &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.name == name &&
        other.slug == slug &&
        other.domain == domain &&
        other.location == location &&
        other.state == state &&
        other.country == country;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        name.hashCode ^
        slug.hashCode ^
        domain.hashCode ^
        location.hashCode ^
        state.hashCode ^
        country.hashCode;
  }
}
