import 'package:flutter/material.dart';
import 'todo_database.dart';
import 'todo_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Shopping List")),
        body: ListPage(),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late ToDoDatabase database;
  List<ToDoItem> shoppingList = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Initialize SQLite database
  Future<void> _initDatabase() async {
    database = await $FloorToDoDatabase.databaseBuilder('todo_database.db').build();
    _loadItems();
  }

  // Load saved To-Do items from database
  Future<void> _loadItems() async {
    final items = await database.todoDao.getAllItems();
    setState(() {
      shoppingList = items;
      if (items.isNotEmpty) {
        ToDoItem.ID = items.last.id + 1;
      }
    });
  }

  // Add item with quantity to database
  Future<void> _addItem() async {
    String item = _itemController.text.trim();
    String quantity = _quantityController.text.trim();

    if (item.isNotEmpty && quantity.isNotEmpty) {
      final newItem = ToDoItem.create(item, quantity);
      await database.todoDao.insertItem(newItem);
      setState(() {
        shoppingList.add(newItem);
      });

      _itemController.clear();
      _quantityController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an item and quantity")),
      );
    }
  }

  // Confirm before deleting an item
  Future<void> _confirmDelete(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item?"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await database.todoDao.deleteItem(shoppingList[index]);
                setState(() {
                  shoppingList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(hintText: "Enter item"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(hintText: "Enter quantity"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _addItem, child: const Text("Add")),
            ],
          ),
        ),
        Expanded(
          child: shoppingList.isEmpty
              ? const Center(child: Text("There are no items in the list"))
              : ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () => _confirmDelete(index),
                child: ListTile(
                  title: Text("${index + 1}: ${shoppingList[index].item}"),
                  trailing: Text("Quantity: ${shoppingList[index].quantity}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
