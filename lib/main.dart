import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/view/sangeet_home/sangit_home.dart';
import 'controller/audio_manager.dart';
import 'controller/favourite_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(
          create: (context) => LanguageManager(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (BuildContext context, languageManager, Widget? child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(languageManager.nameLanguage),
            home: const SangitHome(myLanguage: ""));
      },
    );
  }
}
