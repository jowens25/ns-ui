import 'api.dart';

class PtpOcApi extends ApiService {
  PtpOcApi({required String baseUrl}) : super(baseUrl: '$baseUrl/ptp-oc/');
  static const String _versionKey = 'version';

  @override
  Map<String, String> get properties => ptpOc;
  final Map<String, String> ptpOc = {_versionKey: ''};
  String get version => ptpOc[_versionKey] ?? '';
  String get versionKey => _versionKey;
}
