import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Dashboard',
      description: 'Welcome to your dashboard! Here you can see an overview.',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [DashboardCard(), SizedBox(height: 16)],
                ),
              ),
              //SizedBox(
              //  width: 500,
              //  child: Column(
              //    crossAxisAlignment: CrossAxisAlignment.start,
              //    children: [DashboardCard(), SizedBox(height: 16)],
              //  ),
              //),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardCard extends StatefulWidget {
  @override
  _DashboardCard createState() => _DashboardCard();
}

class _DashboardCard extends State<DashboardCard> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // final loginApi = context.read<LoginApi>();
    //loginApi.getAllUsers();
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return Card(
          child: Container(
            height: 400,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),

                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      loginApi.getUser(1);
                      // print(user)
                    },
                    child: Text('Post User'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
