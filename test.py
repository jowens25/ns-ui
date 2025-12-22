
from commands import runCmd



status = runCmd(["sudo", "systemctl", "is-active", "snmpd"])
print(status)