import 'package:flutter/material.dart';
import 'package:nct/old_prototype/LoginWidget.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/NtpServerApi.dart';
import 'package:nct/old_prototype/NtpServerWidget.dart';
import 'package:nct/api/PtpOcApi.dart';
import 'package:nct/old_prototype/PtpOcWidget.dart';

class MyTabbedPage extends StatefulWidget {
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchTab(int index) {
    _tabController.animateTo(index);
  }

  Widget getTabContent(int index) {
    switch (index) {
      case 1:
        return LoginWidget();
      case 3:
        return PtpOcWidget();
      case 4:
        return NtpServerWidget(); // No need to pass api anymore
      // Add other tabs...
      default:
        return Center(child: Text('Unknown Tab'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novus Time Server Config'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.settings), text: 'Config'),
            Tab(icon: Icon(Icons.tune), text: 'Advanced'),
            Tab(icon: Icon(Icons.lock_clock), text: 'CLK Clock'),
            Tab(icon: Icon(Icons.sync), text: 'PTP OC'),
            Tab(icon: Icon(Icons.access_time), text: 'NTP Server'),
            Tab(icon: Icon(Icons.monitor_heart), text: 'PPS Slave'),
            Tab(icon: Icon(Icons.satellite_alt), text: 'TOD Slave'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(7, (index) => getTabContent(index)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => switchTab(4),
        child: Icon(Icons.access_time),
      ),
    );
  }
}

void main() {
  final ntpServerApi = NtpServerApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  final ptpOcApi = PtpOcApi(baseUrl: "http://100.127.98.7:8080/api/v1");
  // final loginApi = LoginApi(baseUrl: "http://localhost:8080");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ntpServerApi),
        ChangeNotifierProvider(create: (_) => ptpOcApi),
        //ChangeNotifierProvider(create: (_) => loginApi),
        // Add more providers here as needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyTabbedPage());
  }
}
