from NetworkManager import NetworkManager


nm  = NetworkManager()

devices = nm.GetAllDevices()

print(devices)