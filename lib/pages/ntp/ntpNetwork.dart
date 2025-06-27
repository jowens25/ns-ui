import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class NtpNetworkCard extends StatelessWidget {
  const NtpNetworkCard({super.key});

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
                'NTP Network Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('Mac Address')),
              ElevatedButton(onPressed: () => {}, child: Text('Vlan')),
              ElevatedButton(onPressed: () => {}, child: Text('Vlan Enabled')),
              ElevatedButton(onPressed: () => {}, child: Text('Ip Address')),
              ElevatedButton(onPressed: () => {}, child: Text('Ip Version')),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Unicast Enabled'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Multicast Enabled'),
              ),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Broadcast Enabled'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NtpNetworkPage extends StatelessWidget {
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
                  children: [NtpNetworkCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
