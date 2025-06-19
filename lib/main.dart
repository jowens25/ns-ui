import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/routes.dart';

void main() {
  //final ntpServerApi = NtpServerApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  //final ptpOcApi = PtpOcApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  final loginApi = LoginApi(baseUrl: "http://10.1.10.205:8080");

  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (_) => ntpServerApi),
        //ChangeNotifierProvider(create: (_) => ptpOcApi),
        ChangeNotifierProvider(create: (_) => loginApi),
        // Add more providers here as needed
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
      title: 'Explorer UI',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
