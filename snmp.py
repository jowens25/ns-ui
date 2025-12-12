from nicegui import ui, app
from theme import init_colors


async def snmp_page():
    """user page content"""

    ui.label("snmp Configuration").classes("text-h5")
