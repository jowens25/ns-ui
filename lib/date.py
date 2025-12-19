from nicegui import ui, app
from datetime import datetime

async def get_date(_label: ui.label):
    _label.set_text(datetime.now())