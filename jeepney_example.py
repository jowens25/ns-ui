import asyncio
from jeepney.io.asyncio import open_dbus_router, Proxy, message_bus
from jeepney.bus_messages import MatchRule

NM_BUS = "org.freedesktop.NetworkManager"
PROPS_IFACE = "org.freedesktop.DBus.Properties"

async def watch_nm():
    match_rule = MatchRule(
        type="signal",
        sender=NM_BUS,
        interface=PROPS_IFACE,
        member="PropertiesChanged",
        # omit path to match ALL NM objects
    )

    async with open_dbus_router() as router:
        await Proxy(message_bus,
            router=router
        ).AddMatch(match_rule)

        print("[watcher] listening for NetworkManager changes")

        with router.filter(match_rule) as q:
            while True:
                msg = await q.get()
                iface, changed, invalidated = msg.body
                print("Interface:", iface)
                print("Changed:", changed.keys())
                print()
                
asyncio.run(watch_nm())
