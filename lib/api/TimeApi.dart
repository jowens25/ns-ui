import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class TimeApi extends BaseApi {
  late Timer timeTimer;

  String _time = '';
  String get time => _time;

  bool _valid = false;
  bool get valid => _valid;

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
    bool lastState = _valid;
    timeTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      final response = await getRequest("time");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _time = decoded['time'] ?? "00:00:00";

        _valid = true;
      } else {
        _valid = false;
      }

      notifyListeners();
    });
  }
}
