import 'package:floor/floor.dart';

@entity
class ToDoItem {
  @primaryKey
  final int id;
  final String item;  // This is the "name" of the item
  final String quantity;  // This stores the quantity

  ToDoItem(this.id, this.item, this.quantity);

  static int ID = 1;
  ToDoItem.create(String item, String quantity)
      : id = ID++,
        item = item,
        quantity = quantity;
}
