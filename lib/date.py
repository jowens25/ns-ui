from nicegui import ui, app
from datetime import datetime, timezone

async def get_date(_label: ui.label):
    _label.set_text(datetime.now(timezone.utc).strftime('%m-%d-%Y %H:%M:%SZ'))