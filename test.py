from mysocket.mysocket import ReadWriteSocket, ReadNtlProperty, pps, ntp, LoadConfig


#oadConfig("./configs/PtpGmNtpServer.ucm")
    
print(ReadNtlProperty(ntp.Index, ntp.ipaddress))