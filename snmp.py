from nicegui import ui, app
from theme import init_colors
from rest_api import APIClient


api = APIClient(base_url="http://localhost:5000")





async def get_v2s() -> list:
    result = await api.get("/api/v1/snmp/v1v2c_user")
    print(result)
    if result and "v1v2c_users" in result:

        return result.get('v1v2c_users')
    
async def get_v3s() -> list:
    result = await api.get("/api/v1/snmp/v3_user")
    print(result)
    if result and "v3_users" in result:

        return result.get('v3_users')


async def on_row_selected(event):
    row = event.args[1] if event.args[1] else None
    if row:
        with ui.dialog() as interface_dialog, ui.card():
            ui.label(f"Interface Details: {row['community']}").classes("text-h6 mb-4")
            await interface_card(row["community"])
            ui.button("Close", on_click=interface_dialog.close).classes("bg-secondary")

        interface_dialog.open()
        

async def snmp_page():

 

    with ui.column():
        v2s = await get_v2s()
        #v3s = await get_v3s()

        #users = v2s.append(v3s)

        ui.label("SNMP").classes("text-h5")

        interface_table = ui.table(
            title="Users",
            rows=v2s,
            column_defaults={
                "align": "left",
                "headerClasses": "uppercase text-primary",
            },
        )


        interface_table.add_slot('body-cell-community', '''
            <q-td :props="props">
                <a :href="'/snmp/' + props.row.community" 
                   class="text-accent cursor-pointer hover:underline"
                   >
                    {{ props.value }}
                </a>
            </q-td>
        ''')


async def snmp_user_page(user: str):

    with ui.row():
        ui.link('SNMP', '/snmp')
        ui.label('>')
        ui.label(user)



        await user_card(user)



async def user_card(user :str ):

    #result = await api.get(f"/api/v1/network/interfaces/{iface}")
    #if result and "interface" in result:
        #print(result['interface'])

    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(user).classes("text-h6")
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
                    #on_change=update_dhcp_mode,
                )

            with ui.row().classes("items-center gap-4"):
                ui.label("DNS:").classes("font-bold")
                ui.input(placeholder="8.8.8.8").classes("flex-grow")