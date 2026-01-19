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

@binding.bindable_dataclass
class ConnectionDetails:
    Id:          Optional[str] = ''
    Permissions: Optional[list[str]] = None
    Timestamp:   Optional[int] = 0
    Type:        Optional[str] = ''
    Uuid:        Optional[str] = ''

class IpAddress:
    Address: Optional[str] = None
    Prefix: Optional[int] = None

class IpRoute:
    Dest: Optional[str] = None
    Prefix: Optional[int] = None
    NextHop: Optional[str] = None
    Metric: Optional[int] = None

@binding.bindable_dataclass
class Ip4:
    AddressData:      Optional[list[IpAddress]] = None
    Addresses:        Optional[list[list[int]]] = None
    Dns:              Optional[list[list[int]]] = None
    DnsData:          Optional[list[str]] = None
    DnsSearch:        Optional[list[str]] = None
    Gateway:          Optional[str] = ''
    IgnoreAutoDns:    Optional[bool] = False
    IgnoreAutoRoutes: Optional[bool] = False
    Method:           Optional[str] = ''
    RouteData:        Optional[list[IpRoute]] = None
    Routes:           Optional[list[list[int]]] = None


class Ip6:
    AddrGenMod:       Optional[str] = ''
    AddressData:      Optional[list[IpAddress]] = None
    Addresses:        Optional[list[list[int]]] = None
    Dns:              Optional[list[list[int]]] = None
    DnsData:          Optional[list[str]] = None
    DnsSearch:        Optional[list[str]] = None
    Gateway:          Optional[str] = ''
    IgnoreAutoDns:    Optional[bool] = False
    IgnoreAutoRoutes: Optional[bool] = False
    Method:           Optional[str] = ''
    RouteData:        Optional[list[IpRoute]] = None
    Routes:           Optional[list[list[int]]] = None

@binding.bindable_dataclass
class Settings:
    Connection: Optional[ConnectionDetails] = None
    Ipv4:       Optional[Ip4] = None
    Ipv6:       Optional[Ip6] = None
    Proxy:      Optional[str]  = ''





@binding.bindable_dataclass
class Ip4Route:
    Dest: Optional[str] = None
    Prefix: Optional[int] = None
    NextHop: Optional[str] = None
    Metric: Optional[int] = None



@binding.bindable_dataclass
class Ip4DnsServer:
    Address: Optional[str] = ''

@binding.bindable_dataclass
class Ip4DnsSearch:
    Address: Optional[str] = ''

@binding.bindable_dataclass
class Ip4Method:
    Method: Optional[str] = ''


@binding.bindable_dataclass

class Ip4DnsMethod:
    Auto: Optional[bool] = False

@binding.bindable_dataclass
class Ip4RouteMethod:
    Auto: Optional[bool] = False




@binding.bindable_dataclass
class Ipv6Address:
    Address: Optional[str] = None
    Prefix: Optional[int] = None






@binding.bindable_dataclass
class Device:
    Proxy:           Optional[ProxyInterface] = None
    Path:            Optional[str] = ''
    ActiveConnectionPath: Optional[str] = ''
    HardwareAddress: Optional[str] = ''
    Flags:           Optional[int] = None
    Carrier:         Optional[str] = ''
    State:           Optional[int] = True
    DeviceState:     Optional[str] = ''
    Ip4ConfigPath :  Optional[str] = ''
    Ip6ConfigPath :  Optional[str] = ''




@binding.bindable_dataclass
class Ip4Address:
    Address: Optional[str] = None
    Prefix: Optional[int] = None

@binding.bindable_dataclass
class Ip4DnsServer:
    Server: Optional[str] = None

@binding.bindable_dataclass
class Ip4DnsSearch:
    Search: Optional[str] = None

@binding.bindable_dataclass
class Ip4Gateway:
    Address: Optional[str] = ''



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




async def GetSettings(dev: ProxyInterface) -> dict:
    active_connection_path = await dev.get_active_connection()
    if len(active_connection_path) > 1:
        activeConnection = GetActiveConnection(dbus.Bus, active_connection_path)
        connection_path = await activeConnection.get_connection()
        connection = GetConnection(dbus.Bus, connection_path)
        connection_settings = await connection.call_get_settings()

        #settings = Settings(**connection_settings)

    return connection_settings


def unpack_settings(settings: dict) -> Settings:

    connection = ConnectionDetails(
        settings['connection']['id'].value,
        settings['connection']['permissions'].value,
        settings['connection']['timestamp'].value,
        settings['connection']['type'].value,
        settings['connection']['uuid'].value,
    )

    pprint(connection)


def GetIp4Addresses(settings :dict) -> List[Ip4Address]:
    ip4Addresses: List[Ip4Address] = []
    ipv4 = settings.get('ipv4')
    addrData = ipv4.get('address-data').value
    for addr in addrData:
        a = addr.get('address').value
        p = addr.get('prefix').value
        addr = Ip4Address(a, p)
        ip4Addresses.append(addr)
    return ip4Addresses

def GetIp4Routes(settings :dict) -> List[Ip4Route]:
    routes: List[Ip4Route] = []
    ipv4 = settings.get('ipv4')
    routeData = ipv4.get('route-data').value
    for route in routeData:
        a = route.get('dest').value
        p = route.get('prefix').value
        n = route.get('next-hop').value
        m = route.get('metric').value
        addr = Ip4Route(a, p, n, m)
        routes.append(addr)
    return routes




def GetIp4DnsServers(settings :dict) -> List[Ip4DnsServer]:
    servers: List[Ip4DnsServer] = []
    ipv4 = settings.get('ipv4')
    dnsData = ipv4.get('dns-data')
    #dnsData = ipv4.get('dns-data').value
    if dnsData:
        for dns in dnsData.value:
            servers.append(Ip4DnsServer(dns))
        return servers
    else:
        return []

def GetIp4DnsMethod(settings :dict) -> Ip4DnsMethod:
    ipv4 = settings.get('ipv4')
    # if it exisits its true so auto is false
    ignore = ipv4.get('ignore-auto-dns', None)
    # if it doesnt its false so auto is true
    if ignore:
        return Ip4DnsMethod(False)
    else:
        return Ip4DnsMethod(True)


def GetIp4RouteMethod(settings :dict) -> Ip4RouteMethod:
    ipv4 = settings.get('ipv4')
    # if it exisits its true so auto is false
    ignore = ipv4.get('ignore-auto-routes', None)
    # if it doesnt its false so auto is true
    if ignore:
        return Ip4RouteMethod(False)
    else:
        return Ip4RouteMethod(True)

def GetIp4DnsSearches(settings :dict) -> List[Ip4DnsSearch]:
    searches: List[Ip4DnsSearch] = []
    ipv4 = settings.get('ipv4')
    dnsData = ipv4.get('dns-search')
    if dnsData != None:
        for s in dnsData.value:
            searches.append(Ip4DnsSearch(s))
        return searches
    else:
        return []

def GetIp4Method(settings :dict) -> Ip4Method:
    ipv4 = settings.get('ipv4')
    meth = ipv4.get('method').value
    return Ip4Method(meth)


async def GetIp6Addresses(settings :dict) -> List[Ipv6Address]:
    ip4Addresses: List[Ipv6Address] = []

    ipv6 = settings.get('ipv6')
    addrData = ipv6.get('address-data').value
    for addr in addrData:
        a = addr.get('address').value
        p = addr.get('prefix').value
        addr = Ipv6Address(a, p)
        ip4Addresses.append(addr)

    return ip4Addresses


    
    


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


def GetAutoConnect(settings :dict) -> bool:
    return settings['connection'].get('autoconnect', Variant('b', True)).value



async def GetDeviceFromInterface(iface :str) -> Device:
    nm = GetNetworkManager(dbus.Bus)
    device_path = await nm.call_get_device_by_ip_iface(iface)
    device = GetDevice(dbus.Bus, device_path)

    hwaddr = await device.get_hw_address()
    flags = await device.get_interface_flags()
    carrier = processInterfaceFlags(flags)

    #autoConnect = await device.get_autoconnect()
    state = await device.get_state()
    deviceState = processDeviceState(state)
    ip4_config_path = await device.get_ip4_config()
    ip4_config_path = await device.get_ip6_config()
    active_connection_path = await device.get_active_connection()

    myDevice = Device(
    Proxy = device,
    Path = device_path,
    ActiveConnectionPath = active_connection_path,
    HardwareAddress = hwaddr,
    Flags = flags,
    Carrier = carrier,
    State = state,
    DeviceState = deviceState,
    Ip4ConfigPath = ip4_config_path,
    Ip6ConfigPath = ip4_config_path)

    return myDevice

    #return Device(device, )


def isAutoconnect(settings :dict) -> bool:
    return settings['connection']

async def  EnableConnection(devicePath):
    nm = GetNetworkManager(dbus.Bus)
    await nm.call_activate_connection("/", devicePath, "/")

async def DisableConnection(activeConnectionPath):
    nm = GetNetworkManager(dbus.Bus)
    await nm.call_deactivate_connection(activeConnectionPath)

async def GetConnectionFromDevice(device :ProxyInterface) -> ProxyInterface:
    active_connection_path = await device.get_active_connection()
    if len(active_connection_path) > 1:
        activeConnection = GetActiveConnection(dbus.Bus, active_connection_path)
        connection_path = await activeConnection.get_connection()
        return GetConnection(dbus.Bus, connection_path)

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



def GetIp4Gateway(settings :dict) -> str:
    ipv4 = settings.get('ipv4')
    gw = ipv4.get('gateway')
    if gw:
    #gw = ipv4.get('gateway').value
        return Ip4Gateway(gw.value)
    else:
        return Ip4Gateway()

def SetIp4Gateway(settings :dict, gw :str):
    settings['ipv4']['gateway'].value = gw




def SetIp4Method(settings :dict, method :str):
    settings['ipv4']['method'].value = method



def apply_settings(settings: dict):

    # remove depreciated 
    settings["ipv4"].pop('addresses', None)
    settings["ipv4"].pop('dns', None)
    settings["ipv4"].pop('routes', None)

    settings["ipv6"].pop('addresses', None)
    settings["ipv6"].pop('dns', None)
    settings["ipv6"].pop('routes', None)


    settings['ipv4']['method'] = ipv4_method_to_dbus(method)
    if method == 'auto':
        settings['ipv4'].pop('address-data', None)
        settings['ipv4'].pop('gateway', None)
    
    if method == 'manual':
        settings['ipv4']['gateway'] = ip4_gateway_to_dbus(gateway)
        settings['ipv4']['address-data'] = ip4_addresses_to_dbus(addresses)
    if method == 'disabled':
        print()




    
def ip4_addresses_to_dbus(ip :list[Variant]):
    return Variant('aa{sv}', [{'address': Variant('s', i.Address), 'prefix': Variant('u', int(i.Prefix))} for i in ip])

def dns_servers_to_dbus(servers :list[str]):
    return Variant('as', servers)

def dns_searches_to_dbus(search: list[str]):
    return Variant('as', search)

def ip4_gateway_to_dbus(gw: str):
    return Variant('s', gw)

def ipv4_method_to_dbus(method :str):
    return Variant('s', method)



#async def GetIp4Gateway(settings :dict) -> Ip4Gateway:
