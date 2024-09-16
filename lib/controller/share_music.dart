import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../model/sangeet_model.dart';

class ShareMusic extends ChangeNotifier {
  void shareSong(Sangeet song) {
    print("My Share Song ${song.title}");
    Share.share(
      'Check out this song: ${song.title} by ${song.singerName}\nListen here: ${song.audio}',
    );
    notifyListeners();
  }
}
