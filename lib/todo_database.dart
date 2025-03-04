import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'todo_dao.dart';
import 'todo_item.dart';

part 'todo_database.g.dart'; // Auto-generated

@Database(version: 1, entities: [ToDoItem])
abstract class ToDoDatabase extends FloorDatabase {
  ToDoDao get todoDao;
}
