from mysocket.mysocket import ReadWriteSocket, ReadNtlProperty, pps, ntp, LoadConfig


#oadConfig("./configs/PtpGmNtpServer.ucm")
    
print(ReadNtlProperty(ntp.Index, ntp.ipaddress))


from network_manager import test_network

test_network()