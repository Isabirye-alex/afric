import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../others/models/user_model.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;
  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        code Text NULL,
        phoneNumber TEXT UNIQUE
      )
    ''');
  }

  Future<void> insertOrUpdateUser(UserView user) async {
    final db = await instance.database;

    // Check if user already exists
    final existing = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );

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

  Future<List<UserView>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users');

    return result.map((map) => UserView.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

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
