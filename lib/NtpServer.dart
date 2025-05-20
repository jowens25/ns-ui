class NtpServer {
  final String status;
  final String instanceNumber;
  final String ipMode;
  final String ipAddress;
  final String macAddress;
  final String vlanStatus;
  final String vlanAddress;
  final String unicastMode;
  final String multicastMode;
  final String broadcastMode;
  final String precisionValue;
  final String pollIntervalValue;
  final String stratumValue;
  final String referenceId;
  final String smearingStatus;
  final String leap61Progress;
  final String leap59Progress;
  final String leap61Status;
  final String leap59Status;
  final String utcOffsetStatus;
  final String utcOffsetValue;
  final String requestsValue;
  final String responsesValue;
  final String requestsDroppedValue;
  final String broadcastsValue;
  final String clearCountersStatus;
  final String version;
  final String root;

  const NtpServer({
    required this.status,
    required this.instanceNumber,
    required this.ipMode,
    required this.ipAddress,
    required this.macAddress,
    required this.vlanStatus,
    required this.vlanAddress,
    required this.unicastMode,
    required this.multicastMode,
    required this.broadcastMode,
    required this.precisionValue,
    required this.pollIntervalValue,
    required this.stratumValue,
    required this.referenceId,
    required this.smearingStatus,
    required this.leap61Progress,
    required this.leap59Progress,
    required this.leap61Status,
    required this.leap59Status,
    required this.utcOffsetStatus,
    required this.utcOffsetValue,
    required this.requestsValue,
    required this.responsesValue,
    required this.requestsDroppedValue,
    required this.broadcastsValue,
    required this.clearCountersStatus,
    required this.version,
    required this.root,
  });
}

const ntpServer = NtpServer(
  status: "status",
  instanceNumber: "instance",
  ipMode: "ip-mode",
  ipAddress: "ip-address",
  macAddress: "mac-address",
  vlanStatus: "vlan-status",
  vlanAddress: "vlan-address",
  unicastMode: "unicast",
  multicastMode: "multicast",
  broadcastMode: "broadcast",
  precisionValue: "precision",
  pollIntervalValue: "poll-interval",
  stratumValue: "stratum",
  referenceId: "reference-id",
  smearingStatus: "smearing-status",
  leap61Progress: "leap61-progress",
  leap59Progress: "leap59-progress",
  leap61Status: "leap61-status",
  leap59Status: "leap59-status",
  utcOffsetStatus: "utc-offset-status",
  utcOffsetValue: "utc-offset",
  requestsValue: "requests",
  responsesValue: "responses",
  requestsDroppedValue: "requestsdropped",
  broadcastsValue: "broadcasts",
  clearCountersStatus: "clearcounters",
  version: "version",
  root: "ntp-server",
);
