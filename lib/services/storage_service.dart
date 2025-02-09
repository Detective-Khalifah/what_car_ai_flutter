import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:what_car_ai_flutter/data/database_helper.dart';
import 'package:what_car_ai_flutter/models/car.dart';
import 'package:what_car_ai_flutter/models/car_collection.dart';

class StorageService {
  final _databaseHelper = DatabaseHelper();

  Future<void> initDatabase() async {
    await _databaseHelper.database;
  }

  Future<String> saveImage(String base64Image, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/images/$id.jpg';

    // Decode base64 image
    final bytes = base64Decode(base64Image);
    final image = img.decodeImage(Uint8List.view(bytes.buffer))!;
    final compressedImage = img.copyResize(image, width: 300, height: 300);

    // Save image to disk
    final file = File(imagePath);
    await file.writeAsBytes(img.encodeJpg(compressedImage));

    return imagePath;
  }

  /// Saves a [Car] scan to the database.
  Future<void> saveScan(Car car) async {
    final db = await _databaseHelper.database;
    final id = Uuid().v4();

    // final scan = car.toJson();
    // scan['id'] = id;
    // scan['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    // scan['isSaved'] = scan['isSaved'] ? 1 : 0;

    await db.insert('scans', {
      ...car.toJson(),
      'specs': jsonEncode(car.specs ?? {}), // Ensure specs is stored as JSON
    });
  }

  /// Retrieves a list of recent [Car] scans from the database.
  Future<List<Car>> getRecentScans(int limit, int offset) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'scans',
      // columns: [ unnecessary as all fields are queried
      //   'id',
      //   'name',
      //   'category',
      //   'manufacturer',
      //   'specs',
      //   'productionYears',
      //   'rarity',
      //   'description',
      //   'alsoKnownAs',
      //   'year',
      //   'matchAccuracy',
      //   'timestamp',
      //   'images',
      //   'isSaved',
      // ],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((row) {
      final car = Car.fromJson(row);
      // Extract power & acceleration from specs JSON
      final specs = car.specs ?? {};
      return car.copyWith(
        specs: specs,
      );
    }).toList();
    // {
    //   return {
    //     'id': row['id'],
    //     'name': row['name'],
    //     'category': row['category'],
    //     'manufacturer': row['manufacturer'],
    //     'specs':
    //         row['specs'] != null ? jsonDecode(row['specs'] as String) : null,
    //     'productionYears': row['productionYears'],
    //     'rarity': row['rarity'],
    //     'description': row['description'],
    //     'alsoKnownAs': row['alsoKnownAs'] != null
    //         ? jsonDecode(row['alsoKnownAs'] as String)
    //         : null,
    //     'year': row['year'],
    //     'matchAccuracy': row['matchAccuracy'],
    //     'timestamp': row['timestamp'],
    //     'images':
    //         row['images'] != null ? jsonDecode(row['images'] as String) : null,
    //     'isSaved': row['isSaved'] == 1,
    //   };
    // }).toList();
  }

  Future<List<Map<String, dynamic>>> getSavedCollection(
      int limit, int offset) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'scans',
      columns: [
        'id',
        'name',
        'category',
        'manufacturer',
        'specs',
        'productionYears',
        'rarity',
        'description',
        'alsoKnownAs',
        'year',
        'matchAccuracy',
        'timestamp',
        'images',
        'isSaved',
      ],
      where: 'isSaved = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'category': row['category'],
        'manufacturer': row['manufacturer'],
        'specs':
            row['specs'] != null ? jsonDecode(row['specs'] as String) : null,
        'productionYears': row['productionYears'],
        'rarity': row['rarity'],
        'description': row['description'],
        'alsoKnownAs': row['alsoKnownAs'] != null
            ? jsonDecode(row['alsoKnownAs'] as String)
            : null,
        'year': row['year'],
        'matchAccuracy': row['matchAccuracy'],
        'timestamp': row['timestamp'],
        'images':
            row['images'] != null ? jsonDecode(row['images'] as String) : null,
        'isSaved': row['isSaved'] == 1,
      };
    }).toList();
  }

  /// Toggles the saved status of a scan.
  Future<bool> toggleSavedScan(String scanId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawUpdate(
      'UPDATE scans SET isSaved = CASE WHEN isSaved = 1 THEN 0 ELSE 1 END WHERE id = ?',
      [scanId],
    );

    return result > 0; // Returns [true] if a row was updated.
  }

  Future<List<Map<String, dynamic>>> searchScans(String query) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM scans WHERE name LIKE ? OR manufacturer LIKE ? ORDER BY timestamp DESC',
      ['%$query%', '%$query%'],
    );

    return result.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'category': row['category'],
        'manufacturer': row['manufacturer'],
        'specs':
            row['specs'] != null ? jsonDecode(row['specs'] as String) : null,
        'productionYears': row['productionYears'],
        'rarity': row['rarity'],
        'description': row['description'],
        'alsoKnownAs': row['alsoKnownAs'] != null
            ? jsonDecode(row['alsoKnownAs'] as String)
            : null,
        'year': row['year'],
        'matchAccuracy': row['matchAccuracy'],
        'timestamp': row['timestamp'],
        'images':
            row['images'] != null ? jsonDecode(row['images'] as String) : null,
        'isSaved': row['isSaved'] == 1,
      };
    }).toList();
  }

  Future<void> clearAllData() async {
    final db = await _databaseHelper.database;
    await db.execute('DELETE FROM scans');
    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory('${directory.path}/images/');
    await imagesDirectory.delete(recursive: true);
  }

  /// Retrieves a list of collections from the database.
  Future<List<CarCollection>> getCollections() async {
    final db = await _databaseHelper.database;
    final collections = await db.query('collections');

    // return collections
    //     .map((collection) => CarCollection.fromFirestore(collection))
    //     .toList();

    // OR
    final List<CarCollection> collectionList = [];
    for (var collection in collections) {
      final cars = await db.query(
        'id',
        where: 'id = ?',
        whereArgs: [collection['id']],
      );

      final carList = cars.map((car) => Car.fromJson(car)).toList();
      collectionList.add(CarCollection(
        id: collection['id'] as String,
        name: collection['name'] as String,
        icon: collection['icon'] as String,
        cars: carList,
      ));
    }

    return collectionList;

    // return collections.map((collection) { verbose version UP
    //   return {
    //     'id': collection['id'],
    //     'name': collection['name'],
    //     'icon': collection['icon'],
    //   };
    // }).toList();
  }

  Future<String> createCollection(String name, String icon) async {
    final db = await _databaseHelper.database;
    final id = Uuid().v4();
    await db.insert('collections', {
      'id': id,
      'name': name,
      'icon': icon,
    });

    return id;
  }

  Future<void> addToCollection(String collectionId, Car car) async {
    final db = await _databaseHelper.database;
    await db.insert('collection_cars', {
      'collection_id': collectionId,
      'car_id': car.id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFromCollection(String collectionId, String carId) async {
    final db = await _databaseHelper.database;
    await db.delete('collection_cars',
        where: 'collection_id = ? AND car_id = ?',
        whereArgs: [collectionId, carId]);
  }

  Future<Map<String, int>> getStats() async {
    final db = await _databaseHelper.database;

    final totalScans = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM scans')) ??
        0;
    final weeklyScans = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*)
      FROM scans
      WHERE timestamp > ?
    ''', [DateTime.now().millisecondsSinceEpoch - 7 * 24 * 60 * 60 * 1000])) ??
        0;
    final totalSaved = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(DISTINCT car_id)
      FROM collection_cars
    ''')) ?? 0;
    final newSaves = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(DISTINCT car_id)
      FROM collection_cars
      WHERE timestamp > ?
    ''', [DateTime.now().millisecondsSinceEpoch - 7 * 24 * 60 * 60 * 1000])) ??
        0;

    return {
      'totalScans': totalScans,
      'weeklyScans': weeklyScans,
      'totalSaved': totalSaved,
      'newSaves': newSaves,
    };
  }

  Future<void> deleteCollection(String collectionId) async {
    final db = await _databaseHelper.database;

    if (collectionId == '1') {
      return; // Don't allow deletion of Favorites collection
    }

    await db.delete('collection_cars',
        where: 'collection_id = ?', whereArgs: [collectionId]);
    await db.delete('collections', where: 'id = ?', whereArgs: [collectionId]);
  }
}
