from dbus_next.aio import MessageBus
from dbus_next import BusType


class NM:

    def __init__(self):
        self.bus = MessageBus(bus_type=BusType.SYSTEM)

    async def connect(self):
        await self.bus.connect()


    async def disconnect(self):
        await self.bus.disconnect()


    async def getNetworkManger(self):
        intr = await self.bus.introspect('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
        obj = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', intr)
        interface = obj.get_interface('org.freedesktop.DBus.Properties')
        ret = await interface.call_get('org.freedesktop.NetworkManager')

        return ret

    #async def getProperties(self, path, selected_interface):
    #    introspection = await self.dbus.introspect('org.freedesktop.NetworkManager', path)
    #    obj = self.dbus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    #    interface = obj.get_interface('org.freedesktop.DBus.Properties')
    #    ret = await interface.call_get(f'org.freedesktop.NetworkManager.{selected_interface}', prop)
#
#
#
    #async def nmGetProp(self, iface :str, path :str, prop :str) -> str:
    #    introspection = await self.bus.introspect('org.freedesktop.NetworkManager', path)
    #    obj = self.bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    #    interface = obj.get_interface('org.freedesktop.DBus.Properties')
    #    ret = await interface.call_get(f'org.freedesktop.NetworkManager.{iface}', prop)
    #    return ret.value
#
#
    #async def getDevices(self, path :str):
    #    introspection = await self.dbus.introspect('org.freedesktop.NetworkManager', path)
    #    obj = self.dbus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    #    interface = obj.get_interface('org.freedesktop.NetworkManager')
    #    ret = await interface.call_get_devices()
    #    return ret
#
#
    #async def getInterfaces(self):
    #    interfaces = []
    #    devices = await self.getDevices('/org/freedesktop/NetworkManager')
    #    for device in devices:
    #        i = await nmGetProp("Device", device, "Interface")
    #        interfaces.append(i)
    #    return interfaces
#

#async def main():
#
#    print(await getInterfaces())
    
   # bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
   # devices = await getDevices('/org/freedesktop/NetworkManager')
#
   # for device in devices:
   #     if await nmGetProp("Device", device, "Interface") == 'enp3s0':
   #         
   #         Udi = await nmGetProp("Device", device, "Udi")
   #         Interface = await nmGetProp("Device", device, "Interface")
   #         IpInterface = await nmGetProp("Device", device, "IpInterface")
   #         Driver = await nmGetProp("Device", device, "Driver")
   #         DriverVersion = await nmGetProp("Device", device, "DriverVersion")
   #         FirmwareVersion = await nmGetProp("Device", device, "FirmwareVersion")
   #         Capabilities = await nmGetProp("Device", device, "Capabilities")
   #         Ip4Address = await nmGetProp("Device", device, "Ip4Address")
   #         State = await nmGetProp("Device", device, "State")
   #         StateReason = await nmGetProp("Device", device, "StateReason")
   #         ActiveConnection = await nmGetProp("Device", device, "ActiveConnection")
   #         Ip4Config = await nmGetProp("Device", device, "Ip4Config")
   #         Dhcp4Config = await nmGetProp("Device", device, "Dhcp4Config")
   #         Ip6Config = await nmGetProp("Device", device, "Ip6Config")
   #         Dhcp6Config = await nmGetProp("Device", device, "Dhcp6Config")
   #         Managed = await nmGetProp("Device", device, "Managed")
   #         Autoconnect = await nmGetProp("Device", device, "Autoconnect")
   #         FirmwareMissing = await nmGetProp("Device", device, "FirmwareMissing")
   #         NmPluginMissing = await nmGetProp("Device", device, "NmPluginMissing")
   #         DeviceType = await nmGetProp("Device", device, "DeviceType")
   #         AvailableConnections = await nmGetProp("Device", device, "AvailableConnections")
   #         PhysicalPortId = await nmGetProp("Device", device, "PhysicalPortId")
   #         Mtu = await nmGetProp("Device", device, "Mtu")
   #         Metered = await nmGetProp("Device", device, "Metered")
   #         LldpNeighbors = await nmGetProp("Device", device, "LldpNeighbors")
   #         Real = await nmGetProp("Device", device, "Real")
#
   #         print(Interface)
#
   #         #for cfg in Ip4Config:
   #             #print(cfg)
   #         ipv4s = await nmGetProp("IP4Config", Ip4Config, "AddressData")
#
   #         print(ipv4s[0].values)







