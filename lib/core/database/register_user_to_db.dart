import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../others/models/user_model.dart';
// This class manages the user database, allowing for user registration and retrieval.
// It provides methods to insert, update, delete, and fetch user data from the SQLite database
class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;
  UserDatabase._init();
// This is a singleton class, ensuring only one instance of UserDatabase exists throughout the app.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_database.db');
    return _database!;
  }
// This method initializes the database, creating it if it doesn't exist.
  // It uses the getDatabasesPath function to determine the path for the database file.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
// This method creates the database schema, defining the structure of the 'users' table.
  // It is called when the database is created for the first time.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        code Text NULL,
        phoneNumber TEXT UNIQUE
      )
    ''');
  }
// This method inserts or updates a user in the database.
  // It checks if a user with the same ID already exists and updates it if so,
  Future<void> insertOrUpdateUser(UserView user) async {
    final db = await instance.database;

    // Check if user already exists
    final existing = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );
// If the user exists, update it; otherwise, insert a new user
    if (existing.isNotEmpty) {
      Get.snackbar(
        'Warning',
        'A phone number already exists for your account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 6),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        icon: Icon(Icons.check, color: Colors.white),
      );
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } else {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }
// This method retrieves all users from the database.
  // It returns a list of UserView objects representing the users stored in the database.
  Future<List<UserView>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users');

    return result.map((map) => UserView.fromMap(map)).toList();
  }

// This method deletes a user from the database by their ID.
  Future<void> deleteUser(int id) async {
    final db = await instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
// This method updates a user's information in the database.
  // It takes a UserView object and updates the corresponding record in the 'users' table
  Future<void> updateUser(UserView user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
