import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leetcodegptify/View/home_screen.dart';
import 'package:leetcodegptify/View/verification.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  String? verified = await storage.read(key: "isVerified");
  Widget homeScreen;
  if (verified != null && verified.toLowerCase() == "true") {
    homeScreen = const HomeScreen();
  } else {
    homeScreen = const MyHomePage();
  }
  tz.initializeTimeZones();
  runApp(MyApp(homeScreen: homeScreen));
}

class MyApp extends StatelessWidget {
  static const secureStorage = FlutterSecureStorage();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final Widget homeScreen;

  const MyApp({super.key, required this.homeScreen});

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: homeScreen,
        );
      },
    );
  }
}
