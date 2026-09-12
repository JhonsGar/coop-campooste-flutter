import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void goToTienda() => setIndex(1);
  void goToCarrito() => setIndex(2);
  void goToMisCompras() => setIndex(3);
  void goToInicio() => setIndex(0);
}