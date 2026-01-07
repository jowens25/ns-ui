import asyncio
from dataclasses import asdict
from pprint import pprint
from typing import List, Optional
from nicegui import ui, app, binding
from theme import init_colors
from rest_api import APIClient


from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus_next.aio import MessageBus
from dbus import dbus


def GetNetworkManager(bus: MessageBus):
    file_name = 'org.freedesktop.NetworkManager.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', introspection)
    return obj.get_interface('org.freedesktop.NetworkManager')

def GetDevice(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Device.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Device')


def GetActiveConnection(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Connection.Active.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Connection.Active')


def GetIp4Config(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.IP4Config.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.IP4Config')

def GetIp6Config(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.IP6Config.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.IP6Config')


def GetSettingsManager(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Settings.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Settings')

def GetConnection(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Settings.Connection.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Settings.Connection')



def addressDataToAddress(addressdata: list[dict]) -> list:
    formatted = []
    for addr in addressdata:
        address = addr.get('address')
        prefix = addr.get('prefix')
        if address and prefix:
            formatted.append(f"{address.value}/{prefix.value}")
    return formatted


def formatAddressString(addresses: list[str]) -> str:
    return ', '.join(addresses) if addresses else ' '

def formatInterfaceRow(interface :str, addresses: str):
    return {"name": interface, "addresses": addresses}


def addressDataToString(addressData):
    addresses = []
    addresses.extend(addressDataToAddress(addressData))
    return formatAddressString(addresses)

def dnsDataToString(dnsData):
    return formatAddressString(dnsData)

def processDeviceState(state: int) -> str:
    state_dict = {0:  ["UNKNOWN",        "the device's state is unknown"],
                 10:  ["UNMANAGED",     "the device is recognized, but not managed by NetworkManager"],
                 20:  ["UNAVAILABLE",   "the device is managed by NetworkManager, but is not available for use. Reasons may include the wireless switched off, missing firmware, no ethernet carrier, missing supplicant or modem manager, etc."],
                 30:  ["DISCONNECTED",  "the device can be activated, but is currently idle and not connected to a network."],
                 40:  ["PREPARE",       "the device is preparing the connection to the network. This may include operations like changing the MAC address, setting physical link properties, and anything else required to connect to the requested network."],
                 50:  ["CONFIG",        "the device is connecting to the requested network. This may include operations like associating with the Wi-Fi AP, dialing the modem, connecting to the remote Bluetooth device, etc."],
                 60:  ["NEED_AUTH",     "the device requires more information to continue connecting to the requested network. This includes secrets like WiFi passphrases, login passwords, PIN codes, etc."],
                 70:  ["IP_CONFIG",     "the device is requesting IPv4 and/or IPv6 addresses and routing information from the network."],
                 80:  ["IP_CHECK",      "the device is checking whether further action is required for the requested network connection. This may include checking whether only local network access is available, whether a captive portal is blocking access to the Internet, etc."],
                 90:  ["SECONDARIES",   "the device is waiting for a secondary connection (like a VPN) which must activated before the device can be activated"],
                 100: ["ACTIVATED",    "the device has a network connection, either local or global."],
                 110: ["DEACTIVATING", "a disconnection from the current network connection was requested, and the device is cleaning up resources used for that connection. The network connection may still be valid."],
                 120: ["FAILED",       "the device failed to connect to the requested network and is cleaning up the connection request"]}
    nmState = state_dict.get(state, "STATE NOT FOUND")
    return nmState[0]


def processInterfaceFlags(flags: int) -> str:
    NM_DEVICE_INTERFACE_FLAG_NONE= 0 # an alias for numeric zero, no flags set. 
    NM_DEVICE_INTERFACE_FLAG_UP= 0x1 # the interface is enabled from the administrative point of view. Corresponds to kernel IFF_UP. 
    NM_DEVICE_INTERFACE_FLAG_LOWER_UP= 0x2 # the physical link is up. Corresponds to kernel IFF_LOWER_UP. 
    NM_DEVICE_INTERFACE_FLAG_PROMISC= 0x4 # receive all packets. Corresponds to kernel IFF_PROMISC. Since: 1.32. 
    NM_DEVICE_INTERFACE_FLAG_CARRIER= 0x10000 # the interface has carrier. In most cases this is equal to the value of @NM_DEVICE_INTERFACE_FLAG_LOWER_UP. However some devices have a non-standard carrier detection mechanism. 
    NM_DEVICE_INTERFACE_FLAG_LLDP_CLIENT_ENABLED= 0x20000 # the flag to indicate device LLDP status. Since: 1.32.
    """Convert interface flags to detailed status string"""
    
    if flags == 0:
        return "Interface disabled (no flags set)"
    
    status = []
    
    if flags & NM_DEVICE_INTERFACE_FLAG_UP:
        status.append("administratively up")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_LOWER_UP:
        status.append("physical link up")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_CARRIER:
        status.append("carrier detected")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_PROMISC:
        status.append("promiscuous mode")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_LLDP_CLIENT_ENABLED:
        status.append("LLDP enabled")
    
    if not status:
        return f"Unknown flags: 0x{flags:x}"
    
    return " | ".join(status)


def combineAddresses(ipv4AddressData, ipv6AddressData) -> str:
    
    addresses = []
    addresses.extend(addressDataToAddress(ipv4AddressData))
    addresses.extend(addressDataToAddress(ipv6AddressData))
    return formatAddressString(addresses)



        


async def GetInterfacesAndAddresses() -> list:

    rows = []

    nm = GetNetworkManager(dbus.Bus)
    
    device_paths = await nm.call_get_devices()
    
    for devicePath in device_paths:

        device = GetDevice(dbus.Bus, devicePath)
        interface = await device.get_interface()

        ip4_config_path = await device.get_ip4_config()
        ip6_config_path = await device.get_ip6_config()
        if len(ip4_config_path) > 1:

            ip4Config = GetIp4Config(dbus.Bus, ip4_config_path)
            ip6Config = GetIp6Config(dbus.Bus, ip6_config_path)

            ip4AddressData = await ip4Config.get_address_data()
            ip6AddressData = await ip6Config.get_address_data()
    
            rows.append({'name': interface,'addresses': 
                combineAddresses(ip4AddressData, ip6AddressData)})
        
    return rows



@binding.bindable_dataclass
class Connection:
    Autoconnect:           Optional[bool] = None
    

    def to_dbus(self):
        return {Variant('b', self.Autoconnect),}


@binding.bindable_dataclass
class Ipv4:
    AddressData: Optional[list[dict[str]]] = None
    Addresses:   Optional[list[list[int]]] = None
    Dns:         Optional[list[int]] = None
    DnsData:     Optional[list[str]] = None
    DnsSearch:   Optional[str] = ''
    RouteData:   Optional[list[dict[str]]] = None
  



@binding.bindable_dataclass
class Device:
    AutoConnect: Optional[bool] = True
    State: Optional[int] = True
  

@binding.bindable_dataclass
class Ip4Address:
    Address: Optional[str] = None
    Prefix: Optional[int] = None

@binding.bindable_dataclass
class DnsServer:
    Server: Optional[str] = None

@binding.bindable_dataclass
class DnsSearch:
    Search: Optional[str] = None

@binding.bindable_dataclass
class Ip4Gateway:
    Address: Optional[str] = ''
    
def ip4_addresses_to_dbus(ip :list[Variant]):
    return Variant('aa{sv}', [{'address': Variant('s', i.Address), 'prefix': Variant('u', int(i.Prefix))} for i in ip])

def dns_servers_to_dbus(servers :list[str]):
    return Variant('as', servers)

def dns_searches_to_dbus(search: list[str]):
    return Variant('as', search)

def ip4_gateway_to_dbus(gw: str):
    return Variant('s', gw.Address)

def ipv4_method_to_dbus(method :str):
    return Variant('s', method)

