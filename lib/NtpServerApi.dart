import 'api.dart';

class NtpServerApi extends ApiService {
  NtpServerApi({required String baseUrl})
    : super(baseUrl: '$baseUrl/ntp-server/');

  static const String _statusKey = 'status';
  static const String _instanceNumberKey = 'instance';
  static const String _ipModeKey = 'ip-mode';
  static const String _ipAddressKey = 'ip-address';
  static const String _macAddressKey = 'mac-address';
  static const String _vlanStatusKey = 'vlan-status';
  static const String _vlanAddressKey = 'vlan-address';
  static const String _unicastModeKey = 'unicast';
  static const String _multicastModeKey = 'multicast';
  static const String _broadcastModeKey = 'broadcast';
  static const String _precisionValueKey = 'precision';
  static const String _pollIntervalValueKey = 'poll-interval';
  static const String _stratumValueKey = 'stratum';
  static const String _referenceIdKey = 'reference-id';
  static const String _smearingStatusKey = 'smearing-status';
  static const String _leap61ProgressKey = 'leap61-progress';
  static const String _leap59ProgressKey = 'leap59-progress';
  static const String _leap61StatusKey = 'leap61-status';
  static const String _leap59StatusKey = 'leap59-status';
  static const String _utcOffsetStatusKey = 'utc-offset-status';
  static const String _utcOffsetValueKey = 'utc-offset';
  static const String _requestsValueKey = 'requests';
  static const String _responsesValueKey = 'responses';
  static const String _requestsDroppedValueKey = 'requestsdropped';
  static const String _broadcastsValueKey = 'broadcasts';
  static const String _clearCountersStatusKey = 'clearcounters';
  static const String _versionKey = 'version';
  //static const String _rootKey = '';

  final Map<String, String> ntpServer = {
    _statusKey: '',
    _instanceNumberKey: '',
    _ipModeKey: '',
    _ipAddressKey: '',
    _macAddressKey: '',
    _vlanStatusKey: '',
    _vlanAddressKey: '',
    _unicastModeKey: '',
    _multicastModeKey: '',
    _broadcastModeKey: '',
    _precisionValueKey: '',
    _pollIntervalValueKey: '',
    _stratumValueKey: '',
    _referenceIdKey: '',
    _smearingStatusKey: '',
    _leap61ProgressKey: '',
    _leap59ProgressKey: '',
    _leap61StatusKey: '',
    _leap59StatusKey: '',
    _utcOffsetStatusKey: '',
    _utcOffsetValueKey: '',
    _requestsValueKey: '',
    _responsesValueKey: '',
    _requestsDroppedValueKey: '',
    _broadcastsValueKey: '',
    _clearCountersStatusKey: '',
    _versionKey: '',
    //_rootKey: 'ntp-server',
  };

  String get status => ntpServer[_statusKey] ?? '';
  String get instanceNumber => ntpServer[_instanceNumberKey] ?? '';
  String get ipMode => ntpServer[_ipModeKey] ?? '';
  String get ipAddress => ntpServer[_ipAddressKey] ?? '';
  String get macAddress => ntpServer[_macAddressKey] ?? '';
  String get vlanStatus => ntpServer[_vlanStatusKey] ?? '';
  String get vlanAddress => ntpServer[_vlanAddressKey] ?? '';
  String get unicastMode => ntpServer[_unicastModeKey] ?? '';
  String get multicastMode => ntpServer[_multicastModeKey] ?? '';
  String get broadcastMode => ntpServer[_broadcastModeKey] ?? '';
  String get precisionValue => ntpServer[_precisionValueKey] ?? '';
  String get pollIntervalValue => ntpServer[_pollIntervalValueKey] ?? '';
  String get stratumValue => ntpServer[_stratumValueKey] ?? '';
  String get referenceId => ntpServer[_referenceIdKey] ?? '';
  String get smearingStatus => ntpServer[_smearingStatusKey] ?? '';
  String get leap61Progress => ntpServer[_leap61ProgressKey] ?? '';
  String get leap59Progress => ntpServer[_leap59ProgressKey] ?? '';
  String get leap61Status => ntpServer[_leap61StatusKey] ?? '';
  String get leap59Status => ntpServer[_leap59StatusKey] ?? '';
  String get utcOffsetStatus => ntpServer[_utcOffsetStatusKey] ?? '';
  String get utcOffsetValue => ntpServer[_utcOffsetValueKey] ?? '';
  String get requestsValue => ntpServer[_requestsValueKey] ?? '';
  String get responsesValue => ntpServer[_responsesValueKey] ?? '';
  String get requestsDroppedValue => ntpServer[_requestsDroppedValueKey] ?? '';
  String get broadcastsValue => ntpServer[_broadcastsValueKey] ?? '';
  String get clearCountersStatus => ntpServer[_clearCountersStatusKey] ?? '';
  String get version => ntpServer[_versionKey] ?? '';
  //String get root => ntpServer[_rootKey] ?? '';

  String get statusKey => _statusKey;
  String get instanceNumberKey => _instanceNumberKey;
  String get ipModeKey => _ipModeKey;
  String get ipAddressKey => _ipAddressKey;
  String get macAddressKey => _macAddressKey;
  String get vlanStatusKey => _vlanStatusKey;
  String get vlanAddressKey => _vlanAddressKey;
  String get unicastModeKey => _unicastModeKey;
  String get multicastModeKey => _multicastModeKey;
  String get broadcastModeKey => _broadcastModeKey;
  String get precisionValueKey => _precisionValueKey;
  String get pollIntervalValueKey => _pollIntervalValueKey;
  String get stratumValueKey => _stratumValueKey;
  String get referenceIdKey => _referenceIdKey;
  String get smearingStatusKey => _smearingStatusKey;
  String get leap61ProgressKey => _leap61ProgressKey;
  String get leap59ProgressKey => _leap59ProgressKey;
  String get leap61StatusKey => _leap61StatusKey;
  String get leap59StatusKey => _leap59StatusKey;
  String get utcOffsetStatusKey => _utcOffsetStatusKey;
  String get utcOffsetValueKey => _utcOffsetValueKey;
  String get requestsValueKey => _requestsValueKey;
  String get responsesValueKey => _responsesValueKey;
  String get requestsDroppedValueKey => _requestsDroppedValueKey;
  String get broadcastsValueKey => _broadcastsValueKey;
  String get clearCountersStatusKey => _clearCountersStatusKey;
  String get versionKey => _versionKey;
  //String get rootKey => _rootKey;

  @override
  Map<String, String> get properties => ntpServer;
}
