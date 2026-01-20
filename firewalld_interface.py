from dbus_next.service import ServiceInterface, method

from firewalld_lib import StartFirewalld, StopFirewalld, IsActiveFirewalld, ResetFirewalld, RestartFirewalld

class FirewalldInterface(ServiceInterface):
    def __init__(self, name):
        super().__init__(name)


    @method()
    async def Stop(self) -> 'b':
        await StopFirewalld()
        return await IsActiveFirewalld()

    @method()
    async def Start(self) -> 'b':
        await StartFirewalld()
        return await IsActiveFirewalld()
    
    @method()
    async def Restart(self) -> 'b':
        await RestartFirewalld()
        return await IsActiveFirewalld()
    
    @method()
    async def Reset(self):
        await ResetFirewalld()
    
    @method()
    async def IsActive(self) -> 'b':
        return await IsActiveFirewalld()