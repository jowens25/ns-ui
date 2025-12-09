import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'BaseApi.dart';

class TimeApi extends BaseApi {
  Timer? _timeTimer;

  String _time = '';
  String get time => _time;

  String _date = '';
  String get date => _date;

  String _debugMessgae = '';
  String get debugMessgae => _debugMessgae;

  bool _backendReady = false;
  bool get backendReady => _backendReady;

  bool _session_valid = false;
  bool get session_valid => _session_valid;

  int _delay = 1;
  int get currentDelay => _delay;

  @override
  String get baseUrl => '$serverHost/api/v1/network';

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
  }

  Future<void> getDate() async {
    final response = await getRequest("date");
    final decoded = jsonDecode(response.body);
    _date = decoded['date'] ?? "01/01/1972";
    notifyListeners();
  }

  TimeApi({required super.serverHost}) {
    _startPolling();
    //getDate();
  }

  void _startPolling() {
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    _timeTimer?.cancel();
    _timeTimer = Timer(Duration(seconds: _delay), _pollTime);
  }

  Future<void> _pollTime() async {
    try {
      final response = await getRequest("date");

      if (response.statusCode == 200) {
        // Success - backend is ready
        _backendReady = true;
        _session_valid = true;
        _delay = 1; // Reset delay on success

        final decoded = jsonDecode(response.body);
        _time = decoded['date'] ?? "00:00:00";
      } else {
        // Non-200 status - backend not ready
        _handleFailure();
      }
    } catch (e, _) {
      // Connection error - backend not ready
      print("TimeApi error: $e");
      _handleFailure();
    } finally {
      notifyListeners();
      _scheduleNextPoll(); // Schedule next poll
    }
  }

  void _handleFailure() {
    _backendReady = false;
    _session_valid = false;
    _delay = min(10, _delay + 1); // Exponential backoff, max 60 seconds
    _debugMessgae =
        "Loading. Please wait.\r\n Retrying in $_delay seconds...\r\n";
  }

  // Optional: Manual retry with immediate attempt
  void retryNow() {
    _delay = 1;
    _scheduleNextPoll();
  }
}
