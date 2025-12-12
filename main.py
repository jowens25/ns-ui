
import datetime
from nicegui import ui, app

from api import APIClient

from networking import network_page
from accounts import accounts_page
from theme import init_colors
from login import login_page


api = APIClient(base_url="http://localhost:5000")



async def select_main_content(page_name: str):
  
    match page_name:
        case "networking":
            await network_page()
        case "accounts":
            await accounts_page()
        case _:
            await page_not_found()


def main_content():
    select_main_content(page)

async def get_date(_label: ui.label):
    result = await api.get("/api/v1/network/date")
    if result and "date" in result:
        _label.set_text(result["date"])


@ui.page("/")
async def main_page():

    init_colors()

    if not app.storage.user.get("authenticated", False):
        ui.navigate.to("/login")
        return

    with ui.column():
        ui.query("body").classes("bg-secondary")
        await  network_page()

    left_drawer = ui.left_drawer(bordered=True).classes("bg-dark")

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

    

    with left_drawer:

        ui.button(
            "Networking",
            on_click=lambda: select_main_content("networking"),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "SNMP",
            on_click=lambda: select_main_content("networking"),
            icon="settings_applications",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Users",
            on_click=lambda: select_main_content("accounts"),
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

    #await select_main_content("networking")


if __name__ in {"__main__", "__mp_main__"}:
    ui.run(
        reload=True,
        storage_secret="your-secret-key",
        title="Novus Configuration Tool",
        favicon="assets/favicon.png",
    )
