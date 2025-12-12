from nicegui import ui, app
from theme import init_colors


async def accounts_page():
    """user page content"""

    ui.label("User Configuration").classes("text-h5")
