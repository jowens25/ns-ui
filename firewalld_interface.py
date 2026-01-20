from dbus_next.service import ServiceInterface, method, signal

from firewalld_lib import StartFirewalld, StopFirewalld, IsActiveFirewalld, ResetFirewalld, RestartFirewalld

class FirewalldInterface(ServiceInterface):
    def __init__(self, name):
        super().__init__(name)


    @method()
    async def Stop(self) -> 'b':
        await StopFirewalld()
        self.daemon_changed()

        return await IsActiveFirewalld()

    @method()
    async def Start(self) -> 'b':
        await StartFirewalld()
        self.daemon_changed()

        return await IsActiveFirewalld()
    
    @method()
    async def Restart(self) -> 'b':
        await RestartFirewalld()
        self.daemon_changed()
        return await IsActiveFirewalld()
    
    @method()
    async def Reset(self):
        self.daemon_changed()

        await ResetFirewalld()
    
    @method()
    async def IsActive(self) -> 'b':
        return await IsActiveFirewalld()
    
    @signal()
    def daemon_changed(self) -> 's':
        return 'state change'
    
