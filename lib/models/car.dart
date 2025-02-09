import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, FieldValue;

/// Represents a [Car] identified by the AI system.
class Car {
  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final Map<String, dynamic>? specs; // Power & acceleration stored here
  final String productionYears;
  final String relativeTime;
  final String rarity;
  final String description;
  final List<String>? alsoKnownAs;
  final String year;
  final double matchAccuracy;
  final List<String> images;
  final bool isSaved; // INT in sqlite
  final String power; // in sqlite's specs
  final String acceleration; // in sqlite's specs
  final int timestamp; // timestamp for sorting recent scans

  /// Creates a new [Car] instance.
  Car(
      {required this.id,
      required this.name,
      required this.category,
      required this.manufacturer,
      this.specs,
      required this.productionYears,
      required this.relativeTime,
      required this.rarity,
      required this.description,
      this.alsoKnownAs,
      required this.year,
      required this.matchAccuracy,
      required this.images,
      this.isSaved = false,
      required this.power,
      required this.acceleration,
      required this.timestamp});

  /// Creates a [Car] object from [Firestore] data.
  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      specs: data['specs'] != null ? jsonDecode(data['specs']) : null,
      productionYears: data['productionYears'] ?? '',
      relativeTime: data['relativeTime'] ?? '',
      rarity: data['rarity'] ?? '',
      description: data['description'] ?? '',
      alsoKnownAs: data['alsoKnownAs'] != null
          ? List<String>.from(jsonDecode(data['alsoKnownAs']))
          : [],
      year: data['year'] ?? '',
      matchAccuracy: data['matchAccuracy'].toDouble() ?? 0.0,
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      // images: List<String>.from(data['images'] ?? []),
      isSaved: data['isSaved'] ?? false,
      power: data['power'] ?? '',
      acceleration: data['acceleration'] ?? '',
      timestamp: data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'name': name,
      'rarity': rarity,
      'matchAccuracy': matchAccuracy,
      'power': power,
      'acceleration': acceleration,
      'images': images,
      'timestamp': FieldValue.serverTimestamp(), // Ensures Firestore timestamp
      // 'specs': specs,
      'specs': {
        'power': power,
        'acceleration': acceleration,
      },
    };
  }

  /// Creates a Car object from a JSON map (used for SQLite).
  factory Car.fromJson(Map<String, dynamic> json) {
    final specs =
        json['specs'] != null ? jsonDecode(json['specs']) : <String, dynamic>{};

    return Car(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      specs: json['specs'] != null ? jsonDecode(json['specs']) : null,
      power: specs['power'] ?? '',
      acceleration: specs['acceleration'] ?? '',
      productionYears: json['productionYears'] ?? '',
      rarity: json['rarity'] ?? '',
      description: json['description'] ?? '',
      alsoKnownAs: json['alsoKnownAs'] != null
          ? List<String>.from(jsonDecode(json['alsoKnownAs']))
          : [],
      year: json['year'] ?? '',
      matchAccuracy: (json['matchAccuracy'] as num).toDouble(),
      images: json['images'] != null
          ? List<String>.from(jsonDecode(json['images']))
          : [],
      isSaved: json['isSaved'] == 1, // Convert SQLite integer to boolean
      relativeTime: json['relativeTime'] ?? '',
      timestamp: json['timestamp'] ??
          DateTime.now().millisecondsSinceEpoch, // Handle missing timestamp
    );
  }

  /// Converts the Car object into a JSON map (for SQLite).
  Map<String, dynamic> toJson() {
    final specs = this.specs ?? <String, dynamic>{};
    specs['power'] = power;
    specs['acceleration'] = acceleration;

    return {
      'id': id,
      'name': name,
      'category': category,
      'manufacturer': manufacturer,
      'specs': specs != null ? jsonEncode(specs) : null,
      'power': power,
      'acceleration': acceleration,
      'productionYears': productionYears,
      'rarity': rarity,
      'description': description,
      'alsoKnownAs': alsoKnownAs != null ? jsonEncode(alsoKnownAs) : null,
      'year': year,
      'matchAccuracy': matchAccuracy,
      'images': jsonEncode(images),
      'isSaved': isSaved ? 1 : 0, // Convert boolean to SQLite integer
      'relativeTime': relativeTime,
      'timestamp': timestamp, // Ensure timestamp is stored
    };
  }

  /// Creates a copy of the car with modified fields.
  Car copyWith({
    String? id,
    String? name,
    String? category,
    String? manufacturer,
    Map<String, dynamic>? specs,
    String? productionYears,
    String? rarity,
    String? description,
    List<String>? alsoKnownAs,
    String? year,
    double? matchAccuracy,
    List<String>? images,
    bool? isSaved,
    String? relativeTime,
    int? timestamp, // Ensure timestamp can be updated
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      specs: specs ?? this.specs,
      power: specs?['power'] ?? this.power,
      acceleration: specs?['acceleration'] ?? this.acceleration,
      productionYears: productionYears ?? this.productionYears,
      rarity: rarity ?? this.rarity,
      description: description ?? this.description,
      alsoKnownAs: alsoKnownAs ?? this.alsoKnownAs,
      year: year ?? this.year,
      matchAccuracy: matchAccuracy ?? this.matchAccuracy,
      images: images ?? this.images,
      isSaved: isSaved ?? this.isSaved,
      relativeTime: relativeTime ?? this.relativeTime,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
