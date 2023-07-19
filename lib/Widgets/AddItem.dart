import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppin_list/Model/Grocery_items.dart';

import 'package:shoppin_list/Model/category.dart';
import 'package:shoppin_list/data/categories.dart';
import 'package:http/http.dart' as http;


class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  var savedName = "";
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables];
  final formKey = GlobalKey<FormState>();
  var isSaving = false;
  String error ="";

  void saveItem() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        isSaving = true;
      });
      final url = Uri.https(
          "fir-b6d00-default-rtdb.asia-southeast1.firebasedatabase.app",
          "shoping-list.json");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': savedName,
            'quantity': enteredQuantity,
            'category': selectedCategory?.title,
          },
        ),
      );
      print(response.statusCode);
      final Map<String, dynamic> resdata = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
            id: resdata['name'],
            name: savedName,
            quantity: enteredQuantity,
            category: selectedCategory!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1) {
                    return "Name of the item should be atleast 2 characters";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  savedName = newValue!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      initialValue: enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value)! <= 0) {
                          return "The quantity should have a positive value";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            formKey.currentState!.reset();
                          },
                    child: const Text("Reset"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: isSaving ? null : saveItem,
                    child: isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Add Item"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
