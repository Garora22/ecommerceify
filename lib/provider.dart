import 'package:flutter/material.dart';

import 'main.dart'; 
// ignore: camel_case_types
class provider extends ChangeNotifier {
  final List<Product> _cartlist = [];
  List<Product> get cartlist => _cartlist;

  get cartItems => null;

  add(dynamic pro) {
    _cartlist.add(pro);
    notifyListeners();
  }

  remove(int idtoremove) {
    _cartlist.removeWhere((element) => element.id == idtoremove);
    notifyListeners();
  }
}
