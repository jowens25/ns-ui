from jeepney.io.asyncio import  DBusRouter, open_dbus_connection

global Connection, Router

async def setup():
    global Connection, Router
    Connection = await open_dbus_connection(bus="SYSTEM")
    Router = DBusRouter(Connection)

async def cleanup():
    global Connection
    await Connection.close()

