import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../api_service/api_services.dart';
import '../model/language_model.dart';

class LanguageManager extends ChangeNotifier {
  String _nameLanguage = "hindi";
  String get nameLanguage => _nameLanguage;

  void setLanguage(String langName) {
    _nameLanguage = langName;
    notifyListeners();

    print("My Provider data language $_nameLanguage");
  }

  // List of Datum, which represents individual language entries
  List<Datum> _languagemodel = [];
  List<Datum> get languagemodel => _languagemodel;

  Future<void> getLanguageData() async {
    try {
      // Fetching the language data from the API
      final response = await ApiService()
          .getLanguage("https://mahakal.rizrv.in/api/v1/sangeet/language");
      print("My Language response is $response");

      if (response != null && response['data'] != null) {
        // Parse the response into a LanguageModel
        LanguageModel languageModel = LanguageModel.fromJson(response);

        // Clear the existing list and add all fetched data
        _languagemodel.clear();
        _languagemodel.addAll(languageModel.data);

        // Notify listeners that the data has changed
        notifyListeners();

        // If there are languages, print the first one
        if (_languagemodel.isNotEmpty) {
          print("First Language: ${_languagemodel[0].name}");
        } else {
          print("No languages found.");
        }
      } else {
        print("Error: 'data' key is missing or null in the response.");
      }
    } catch (e) {
      print("Error fetching languages: $e");
    }
  }
}
