from nicegui import ui, app
from theme import init_colors
from api import APIClient

api = APIClient(base_url="http://localhost:5000")


def update_dhcp_mode(dhcp_value):  # Receives the selected value
    print(f"Selected DHCP mode: {dhcp_value}")


def format_interfaces(result):
    table_rows = []
    for iface in result["interfaces"]:
        addresses_str = (
            ", ".join(iface.get("addresses", [])) if iface.get("addresses") else "None"
        )
        table_rows.append({"name": iface["name"], "addresses": addresses_str})
    return table_rows


async def get_interfaces() -> list:
    result = await api.get("/api/v1/network/interfaces")
    if result and "interfaces" in result:

        return format_interfaces(result)


# Correct async handler:
async def on_row_selected(event):
    row = event.args[1] if event.args[1] else None
    if row:
        ui.notify(f"Selected interface: {row['name']}")

        with ui.dialog() as interface_dialog, ui.card():
            ui.label(f"Interface Details: {row['name']}").classes("text-h6 mb-4")
            interface_card(row["name"])
            ui.button("Close", on_click=interface_dialog.close).classes("bg-secondary")

        interface_dialog.open()


async def network_page():
    init_colors()

    interfaces = await get_interfaces()

    ui.label("Networking").classes("text-h5")

    interface_table = ui.table(
        title="Interfaces",
        rows=interfaces,
        column_defaults={
            "align": "left",
            "headerClasses": "uppercase text-primary",
        },
    )

    # Important: Don't call the function directly — pass the reference
    interface_table.on("rowClick", on_row_selected)


def interface_card(iface):
    """Reusable interface card component"""
    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(iface).classes("text-h6")
            ui.label("driver info").classes("text-caption")
            ui.label("control info").classes("text-caption")
            ui.link("mac address", "#")
            ui.switch("Connected").props("disable")

        ui.separator()

        # Main content
        with ui.column().classes("w-full gap-2"):
            with ui.row().classes("items-center gap-4"):
                ui.label("Status:").classes("font-bold")
                ui.label("Active").classes("text-positive")

            with ui.row().classes("items-center gap-4"):
                ui.label("IP Address:").classes("font-bold")
                ui.label("192.168.1.100")

            with ui.row().classes("items-center gap-4"):
                ui.label("Connection:").classes("font-bold")
                ui.select(
                    ["DHCP", "MANUAL", "Static"],
                    value="DHCP",
                    on_change=update_dhcp_mode,
                )

            with ui.row().classes("items-center gap-4"):
                ui.label("DNS:").classes("font-bold")
                ui.input(placeholder="8.8.8.8").classes("flex-grow")
