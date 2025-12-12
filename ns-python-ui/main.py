"""
main.py - Single Page Application with dynamic content switching
"""

import datetime
from nicegui import ui, app

from api import APIClient

from networking import network_page
from accounts import accounts_page
from theme import init_colors
from login import login_page


api = APIClient(base_url="http://localhost:5000")


async def select_main_content(page_name: str, content_container: ui.column):
    """Switch to a different page by clearing and rebuilding content"""

    content_container.clear()
    with content_container:

        if page_name == "networking":
            await network_page()

        elif page_name == "user":
            await accounts_page()


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

    ui.query("body").classes("bg-secondary")

    left_drawer = ui.left_drawer(bordered=True).classes("bg-dark")

    with ui.header().classes("items-center justify-between").classes("bg-dark"):
        ui.button(on_click=lambda: left_drawer.toggle(), icon="menu").props(
            "flat color=white"
        )
        ui.image("NOVUS_LOGO.svg").classes("w-48")
        ui.label(f'Welcome {app.storage.user["username"]}!')

        label = ui.label()

        async def update_date():
            await get_date(label)

        ui.timer(1.0, update_date)

    content_container = ui.column()

    with left_drawer:

        ui.button(
            "Networking",
            on_click=lambda: select_main_content("networking", content_container),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "SNMP",
            on_click=lambda: select_main_content("networking", content_container),
            icon="settings_applications",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Users",
            on_click=lambda: select_main_content("user", content_container),
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

    await select_main_content("networking", content_container)


if __name__ in {"__main__", "__mp_main__"}:
    ui.run(
        reload=True,
        storage_secret="your-secret-key",
        title="Novus Configuration Tool",
        favicon="favicon.png",
    )
