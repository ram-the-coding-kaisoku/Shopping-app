import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppin_list/Model/Grocery_items.dart';
import 'package:shoppin_list/Widgets/AddItem.dart';
import 'package:http/http.dart' as http;
import 'package:shoppin_list/data/categories.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({
    super.key,
  });

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  List<GroceryItem> grocerieslist = [];
  var isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
        "fir-b6d00-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shoping-list.json");
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        error = "OOPS some error , Please try again later!";
      });
    }
    if(response.body=='null'){
      setState(() {
        isLoading=false;
      });
      return;
    }
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final items in listdata.entries) {
      var category = categories.entries
          .firstWhere(
              (element) => element.value.title == items.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
            id: items.key,
            name: items.value['name'],
            quantity: items.value['quantity'],
            category: category),
      );
    }
    setState(() {
      grocerieslist = loadedItems;
      isLoading = false;
    });
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      grocerieslist.add(newItem);
    });
  }

  void remove(GroceryItem item) {
    final url = Uri.https("fir-b6d00-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shoping-list/${item.id}.json");
    http.delete(url);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Groceries found!!!",
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Try adding a grocery item."),
        ],
      ),
    );
    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (grocerieslist.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (context, index) => Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.redAccent,
            child: const Icon(Icons.delete),
          ),
          onDismissed: (direction) {
            remove(grocerieslist[index]);

          },
          child: ListTile(
            title: Text(grocerieslist[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: grocerieslist[index].category.color,
            ),
            trailing: Text(
              grocerieslist[index].quantity.toString(),
            ),
          ),
        ),
        itemCount: grocerieslist.length,
      );
    }
    if (error != null) {
      content = Center(
        child: Text(error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }
}
