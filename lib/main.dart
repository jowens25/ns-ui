import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/api/AuthApi.dart';
import 'package:ntsc_ui/api/SnmpApi.dart';
import 'package:ntsc_ui/api/UserApi.dart';
import 'package:ntsc_ui/api/NtpApi.dart';

import 'package:ntsc_ui/routes.dart';

void main() {
  //final ntpServerApi = NtpServerApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  //final ptpOcApi = PtpOcApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  //final userApi = UserApi(baseUrl: "http://100.127.98.7:5000");

  final authApi = AuthApi(serverHost: "10.1.10.205", serverPort: "5000");
  final ntpApi = NtpApi(serverHost: "10.1.10.205", serverPort: "5000");
  final snmpApi = SnmpApi(serverHost: "10.1.10.205", serverPort: "5000");
  final userApi = UserApi(serverHost: "10.1.10.205", serverPort: "5000");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authApi),
        ChangeNotifierProvider(create: (_) => ntpApi),
        ChangeNotifierProvider(create: (_) => snmpApi),
        ChangeNotifierProvider(create: (_) => userApi),
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
      title: 'Novus UI',
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

        cardTheme: CardTheme(
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
