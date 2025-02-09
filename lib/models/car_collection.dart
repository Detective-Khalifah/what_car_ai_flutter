import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

import 'car.dart';

/// Represents a collection of [Car]s saved by the user.
class CarCollection {
  final String id;
  final String name;
  final String icon;
  final List<Car> cars;

  CarCollection({
    required this.id,
    required this.name,
    required this.icon,
    required this.cars,
  });

  /// Creates a [CarCollection] from [Firestore].
  factory CarCollection.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CarCollection(
      id: data['id'],
      name: data['name'],
      icon: data['icon'],
      cars: (data['cars'] as List<dynamic>)
          .map((car) => Car.fromJson(car))
          .toList(),
    );
  }

  /// Converts the [CarCollection] into a [Firestore]-compatible [JSON] object.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'cars': cars.map((car) => car.toJson()).toList(),
    };
  }
}
