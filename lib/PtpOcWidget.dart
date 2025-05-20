import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CardInfo.dart';
import 'ApiService.dart';

class PtpOcWidget extends StatefulWidget {
  @override
  _PtpOcWidgetState createState() => _PtpOcWidgetState();
}

class _PtpOcWidgetState extends State<PtpOcWidget> {
  @override
  void initState() {
    super.initState();
    final PtpOcProvider = Provider.of<PtpOcApi>(context, listen: false);
    PtpOcProvider.getRequest("version");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 800,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: ptpcards.length,
          itemBuilder: (context, index) {
            final card = ptpcards[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Expanded(child: card.content),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<CardInfo> ptpcards = [
    CardInfo(
      title: 'Ptp Oc Configuration',
      content: Consumer<PtpOcApi>(
        builder:
            (context, api, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text('Core Version : ${api.get('version')}'),
                //Text('Instance Number: ${ntp.instance}'),
              ],
            ),
      ),
    ),
  ];
}
