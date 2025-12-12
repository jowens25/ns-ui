from nicegui import ui, app
from theme import init_colors


async def home_page():
    """user page content"""

    ui.label("User Configuration").classes("text-h5")
