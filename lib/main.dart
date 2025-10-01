import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:nct/api/SecurityApi.dart';
import 'package:nct/api/TimeApi.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:nct/api/UserApi.dart';

import 'package:nct/api/DeviceApi.dart';

import 'package:nct/routes.dart';

import 'package:web/web.dart' as web;

//import 'package:web/web.dart' as web;
final String frontendVersion = "1.1.65";

void main() {
  final bool development = false;
  String host = "";

  if (development) {
    host = "http://localhost:5000"; // development
  } else {
    host = web.window.location.origin;
  }

  final snmpApi = SnmpApi(serverHost: host);
  final deviceApi = DeviceApi(serverHost: host);
  final timeApi = TimeApi(serverHost: host);

  final userApi = UserApi(serverHost: host);
  final networkApi = NetworkApi(serverHost: host);
  final securityApi = SecurityApi(serverHost: host);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => deviceApi),
        ChangeNotifierProvider(create: (_) => timeApi),
        ChangeNotifierProvider(create: (_) => snmpApi),
        ChangeNotifierProvider(create: (_) => userApi),
        ChangeNotifierProvider(create: (_) => networkApi),
        ChangeNotifierProvider(create: (_) => securityApi),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Novus Configuration Tool',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,

          // Primary: Your neutral foundation
          primary: Colors.grey[800]!, // Dark grey surface
          onPrimary: Colors.white, // Text on primary
          // Secondary: Brand accent color
          secondary: const Color.fromARGB(80, 230, 57, 71), // Your brand accent
          onSecondary: Colors.white, // Text/icons on accent
          // Error colors
          error: Colors.red[700]!, // Deeper red for error
          onError: Colors.white, // Text on error
          // Background and surfaces
          surface: Colors.grey[300]!, // Light grey card/surface
          onSurface: Colors.black, // Text/icons on surfaces
        ),

        // Button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.2),
            backgroundColor: Colors.grey[800], // Matches primary
            foregroundColor: Colors.white, // Readable on dark
          ),
        ),

        iconTheme: IconThemeData(
          size: 20.0, // Set your desired icon size
        ),

        textTheme: GoogleFonts.robotoMonoTextTheme(Theme.of(context).textTheme),

        cardTheme: CardThemeData(
          color: Colors.grey[200], // Slightly lighter than surface
          elevation: 4, // Higher to make it pop
          shadowColor: Colors.black26, // Softer, more natural shadow
          shape: RoundedRectangleBorder(
            // Optional: style boost
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Optional: customize AppBar for consistency
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
          elevation: 1,
          shadowColor: Colors.black12,
        ),
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
