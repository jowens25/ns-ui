

from dataclasses import asdict
from dbus_next.service import ServiceInterface, method

from snmp_lib import *

class SnmpInterface(ServiceInterface):
    def __init__(self, name):
        super().__init__(name)


    @method()
    async def GetV2Users(self) -> 'aa{ss}':
        return [asdict(u) for u in ReadV2Users()]
    
    @method()
    async def GetV3Users(self) -> 'aa{ss}':
        return [asdict(u) for u in ReadV3Users()]
    
    @method()
    async def AddV2User(self, v2User: 'a{ss}') -> 'b':
        user = V2User.from_dict(v2User)
        if user:
            AddV2User(user)
            return True
        else:
            return False
        
    @method()
    async def Reset(self) -> 's':
        return await ResetSnmpd()

    @method()
    async def IsActive(self) -> 'b':
        return await IsActiveSnmpd()

