

import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  String _searchQuery = '';

  int get selectedIndex => _selectedIndex;
  String get searchQuery => _searchQuery;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}