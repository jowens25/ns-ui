import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class TimeApi extends BaseApi {
  late Timer timeTimer;

  String _time = '';
  String get time => _time;

  @override
  String get baseUrl => '$serverHost/api/v1/network';

  @override
  void dispose() {
    timeTimer.cancel();
    super.dispose();
  }

  TimeApi({required super.serverHost}) {
    getTime();
  }

  void getTime() {
    timeTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      final response = await getRequest("time");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _time = decoded['time'] ?? "00:00:00";
        notifyListeners();
      }
    });
  }
}
