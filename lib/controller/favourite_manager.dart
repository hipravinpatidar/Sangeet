import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/model/sangeet_model.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Sangeet> _favoriteList = [];

  List<Sangeet> get favoriteList => _favoriteList;

  void addToFavorites(Sangeet music) {
    if (!_favoriteList.contains(music)) {
      _favoriteList.add(music);
      notifyListeners();
    }
  }

  void removeFromFavorites(Sangeet music) {
    if (_favoriteList.contains(music)) {
      _favoriteList.remove(music);
      notifyListeners();
    }
  }

  bool isFavorite(Sangeet music) {
    return _favoriteList.contains(music);
  }
}
