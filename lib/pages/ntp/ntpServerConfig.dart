import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class NtpServerConfigCard extends StatelessWidget {
  const NtpServerConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NTP Server Config Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('Stratum')),
              ElevatedButton(onPressed: () => {}, child: Text('Poll Interval')),

              ElevatedButton(onPressed: () => {}, child: Text('Precision')),

              ElevatedButton(onPressed: () => {}, child: Text('Reference ID')),
            ],
          ),
        ),
      ),
    );
  }
}

class NtpServerConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server Version Info:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Actions
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [NtpServerConfigCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
