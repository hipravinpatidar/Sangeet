import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangit/controller/language_manager.dart';
import 'package:sangit/view/sangeet_home/sangit%20_home.dart';
import 'controller/audio_manager.dart';
import 'controller/favourite_manager.dart';

void main() {
  runApp(  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
      ChangeNotifierProvider(create: (context) => FavoriteProvider()),
      ChangeNotifierProvider(create: (context) => LanguageManager(),),
    ],
    child: MyApp(),
  ),);
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (BuildContext context, languageManager, Widget? child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(languageManager.nameLanguage),
            home: SangitHome(myLanguage: '',)
        );
      },
    );
  }
}

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sangit/view/audioplayer_handler.dart';
// import 'package:sangit/view/sangeet_home/sangit%20_home.dart';
// import 'controller/audio_manager.dart';
// import 'controller/favourite_manager.dart';
//
// // Initialize AudioService and run the app
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize the AudioService with the AudioPlayerHandler
//   final audioHandler = await AudioService.init(
//     builder: () => AudioPlayerHandler(),
//     config: const AudioServiceConfig(
//       androidNotificationChannelId: 'com.example.sangit.audio',
//       androidNotificationChannelName: 'Sangit Audio',
//       androidNotificationOngoing: true,
//     ),
//   );
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
//         ChangeNotifierProvider(create: (context) => FavoriteProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SangitHome(),
//     );
//   }
// }

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sangit/view/audioplayer_handler.dart';
// import 'package:sangit/view/sangeet_home/sangit%20_home.dart';
// import 'controller/audio_manager.dart';
// import 'controller/favourite_manager.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize the AudioService with error handling
//   AudioHandler? audioHandler;
//   try {
//     audioHandler = await AudioService.init(
//       builder: () => AudioPlayerHandler(),
//       config: const AudioServiceConfig(
//         androidNotificationChannelId: 'com.example.sangit.audio',
//         androidNotificationChannelName: 'Sangit Audio',
//         androidNotificationOngoing: true,
//       ),
//     );
//   } catch (e) {
//     print('Error initializing AudioService: $e');
//   }
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
//         ChangeNotifierProvider(create: (context) => FavoriteProvider()),
//         Provider.value(value: audioHandler),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sangit/view/audioplayer_handler.dart';
// import 'package:sangit/view/sangeet_home/sangit%20_home.dart';
//
// import 'controller/audio_manager.dart';
// import 'controller/favourite_manager.dart';
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Check if audioHandler was initialized correctly
//     final audioHandler = Provider.of<AudioHandler?>(context);
//     if (audioHandler == null) {
//       return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: ErrorScreen(), // Show an error screen if initialization failed
//       );
//     }
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SangitHome(), // Your main home screen
//     );
//   }
// }
//
// class ErrorScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           'Failed to initialize audio service. Please try again later.',
//           style: TextStyle(fontSize: 18, color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize the AudioService with error handling
//   AudioHandler? audioHandler;
//   try {
//     audioHandler = await AudioService.init(
//       builder: () => AudioPlayerHandler(),
//       config: const AudioServiceConfig(
//         androidNotificationChannelId: 'com.example.sangit.audio',
//         androidNotificationChannelName: 'Sangit Audio',
//         androidNotificationOngoing: true,
//       ),
//     );
//     print('AudioService initialized successfully');
//   } catch (e) {
//     print('Error initializing AudioService: $e');
//   }
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
//         ChangeNotifierProvider(create: (context) => FavoriteProvider()),
//         Provider.value(value: audioHandler),
//       ],
//       child: MyApp(),
//     ),
//   );
// }



// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sangit/view/audioplayer_handler.dart';
// import 'package:sangit/view/sangeet_home/sangit%20_home.dart';
// import 'controller/audio_manager.dart';
// import 'controller/favourite_manager.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   AudioHandler? audioHandler;
//   try {
//     audioHandler = await AudioService.init(
//       builder: () => AudioPlayerHandler(),
//       config: const AudioServiceConfig(
//         androidNotificationChannelId: 'com.example.sangit.audio',
//         androidNotificationChannelName: 'Sangit Audio',
//         androidNotificationOngoing: true,
//       ),
//     );
//     print('AudioService initialized successfully');
//   } catch (e, s) {
//     print('Error initializing AudioService: $e');
//     print('Stack trace: $s');
//   }
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AudioPlayerManager()),
//         ChangeNotifierProvider(create: (context) => FavoriteProvider()),
//         Provider.value(value: audioHandler),
//       ],
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final audioHandler = Provider.of<AudioHandler?>(context);
//
//     if (audioHandler != null) {
//       return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: ErrorScreen(),
//       );
//     }
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SangitHome(),
//     );
//   }
// }
//
// class ErrorScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           'Failed to initialize audio service. Please try again later.',
//           style: TextStyle(fontSize: 18, color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
