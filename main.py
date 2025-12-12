
import datetime
from nicegui import ui, app

from dbus_next.aio import MessageBus
from dbus_next import BusType

from api import APIClient


from networking import network_page, interface_page
from accounts import accounts_page
from theme import init_colors
from login import login_page
from home import home_page
from snmp import snmp_page

api = APIClient(base_url="http://localhost:5000")







async def get_date(_label: ui.label):
    result = await api.get("/api/v1/network/date")
    if result and "date" in result:
        _label.set_text(result["date"])


@ui.page('/networking/{interface_name}')
@ui.page('/networking')
@ui.page('/snmp')
#@ui.page('/accounts')
@ui.page('/')
async def main_page():

    init_colors()

    if not app.storage.user.get("authenticated", False):
        ui.navigate.to("/login")
        return


    with ui.header().classes("items-center justify-between").classes("bg-dark"):
        ui.button(on_click=lambda: left_drawer.toggle(), icon="menu").props(
            "flat color=white"
        )
        ui.image("assets/NOVUS_LOGO.svg").classes("w-48")
        ui.label(f'Welcome {app.storage.user["username"]}!')

        label = ui.label()

        async def update_date():
            await get_date(label)

        ui.timer(1.0, update_date)


    with ui.left_drawer(bordered=True).classes("bg-dark") as left_drawer:


        ui.button(
            "Overview",
            on_click=lambda: ui.navigate.to('/'),
            icon="dashboard",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Networking",
            on_click=lambda: ui.navigate.to('/networking'),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "SNMP",
            on_click=lambda: ui.navigate.to('/snmp'),
            icon="settings_applications",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Accounts",
            on_click=lambda: ui.navigate.to('/accounts'),
            icon="group",
        ).props("flat color=white align=left").classes("full-width")

        ui.separator()

        ui.button(
            "Logout",
            on_click=lambda: (app.storage.user.clear(), ui.navigate.to("/login")),
            icon="logout",
        ).props("flat color=negative align=left").classes("full-width")

    # Footer
    with ui.footer().classes("bg-dark"):
        ui.label("FOOTER")


    ui.sub_pages({'/': home_page, '/networking': network_page, '/snmp': snmp_page, '/accounts': accounts_page, '/networking/{interface_name}': interface_page})







if __name__ in {"__main__", "__mp_main__"}:

    ui.run(
        reload=True,
        storage_secret="your-secret-key",
        title="Novus Configuration Tool",
        favicon="assets/favicon.png",
    )


