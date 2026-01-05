import asyncio
from mysocket.mysocket import socket_received, write_socket
from rest_api import APIClient
from nicegui import ui, app, background_tasks, events

api = APIClient(base_url="http://localhost:5000")
from dataclasses import dataclass, field

@dataclass
class NtpServer:
	version: str =  field(default="")
	status: str =  field(default="")
	ipmode: str =  field(default="")
	ipaddress: str =  field(default="")
	macaddress: str =  field(default="")
	vlanstatus: str =  field(default="")
	vlanaddress: str =  field(default="")
	unicastmode: str =  field(default="")
	multicastmode: str =  field(default="")
	broadcastmode: str =  field(default="")
	precisionvalue: str =  field(default="")
	pollintervalvalue: str =  field(default="")
	stratumvalue: str =  field(default="")
	referenceid: str =  field(default="")
	smearingstatus: str =  field(default="")
	leap61inprogress: str =  field(default="")
	leap59inprogress: str =  field(default="")
	leap61status: str =  field(default="")
	leap59status: str =  field(default="")
	utcoffsetstatus: str =  field(default="")
	utcoffsetvalue: str =  field(default="")
	requestsvalue: str =  field(default="")
	responsesvalue: str =  field(default="")
	requestsdroppedvalue: str =  field(default="")
	broadcastsvalue: str =  field(default="")
	clearcountersstatus: str =  field(default="")


ntp = NtpServer()

async def get_requests(_label):
    result = await api.get("/api/v1/ntl/ntp/broadcastsvalue")
    if result and "broadcastsvalue" in result:
        _label.set_text(result["broadcastsvalue"])

async def get_version(_label):
    result = await api.get(f"/api/v1/ntl/ntp/{ntp.version}")
    if result and ntp.version in result:
        _label.set_text(result[ntp.version])


async def get_ntp_prop(prop):
    result = await api.get(f"/api/v1/ntl/ntp/{prop}")
    if result and prop in result:
        print()
        #_label.set_text(result[prop])



#async def get_all_ntp_prop

async def load_ntp_properties():
    for field_name in NtpServer.__dataclass_fields__.keys():
        prop_value = getattr(ntp, field_name)
        print(prop_value)
        if prop_value.strip() == "":  # Empty check
            result = await api.get(f"/api/v1/ntl/ntp/{field_name}")
            if result and field_name in result:
                setattr(ntp, field_name, result[field_name])  # Update field
                print(f"Updated {field_name}: {result[field_name]}")

#async def get_ntp_property(field_name):
#    result = await api.get(f"/api/v1/ntl/ntp/{field_name}")
#    if result and field_name in result:
#        setattr(ntp, field_name, result[field_name])  # Update field
#        print(f"Updated {field_name}: {result[field_name]}")

async def writeNtlConfig(content: str):
    content.splitlines()
    for line in content.splitlines():
        if line.startswith("$WC"):
            await write_socket(line)



async def ntp_page():

    with ui.column() as pageContainer:
        ui.label("NTP").classes("text-h5")
        with ui.card().classes('size-120 resize overflow-auto'):
            terminal = ui.xterm({'convertEol': True}).classes('size-full')
            ui.element('q-resize-observer').on('resize', terminal.fit)
            socket_received.subscribe(lambda data: terminal.write(data))
            
        with ui.card():
            async def on_cmd():
                await write_socket(cmd.value)
            cmd = ui.input("command: ").on("keydown.enter", on_cmd)

        
        

        with ui.card():
            async def handle_upload(e: events.UploadEventArguments):
                ui.notify(f'Uploaded {e.file.name}')
                await writeNtlConfig(await e.file.text())

            ui.upload(on_upload=handle_upload).classes('max-w-full').props("flat color=accent")

            
        with ui.card():
            ui.label(f"version: {ntp.version}")
            ui.select(label="Status", options=["Enabled", "Disabled"], value="Enabled").classes('w-full')
        ui.select(label="Ip Mode", options=["IPv4", "IPv6"], value="IPv4").classes('w-full')
        ui.input(f"ip address: {ntp.ipaddress}")
        ui.input(f"mac address: {ntp.macaddress}")
        with ui.card():
            ui.label(f"vlanstatus: {ntp.vlanstatus}")
            ui.label(f"vlanaddress: {ntp.vlanaddress}")
        ui.label(f"unicastmode: {ntp.unicastmode}")
        ui.label(f"multicastmode: {ntp.multicastmode}")
        ui.label(f"broadcastmode: {ntp.broadcastmode}")
        ui.label(f"precisionvalue: {ntp.precisionvalue}")
        ui.label(f"pollintervalvalue: {ntp.pollintervalvalue}")
        ui.label(f"stratumvalue: {ntp.stratumvalue}")
        ui.label(f"referenceid: {ntp.referenceid}")
        ui.label(f"smearingstatus: {ntp.smearingstatus}")
        ui.label(f"leap61inprogress: {ntp.leap61inprogress}")
        ui.label(f"leap59inprogress: {ntp.leap59inprogress}")
        ui.label(f"leap61status: {ntp.leap61status}")
        ui.label(f"leap59status: {ntp.leap59status}")
        ui.label(f"utcoffsetstatus: {ntp.utcoffsetstatus}")
        ui.label(f"utcoffsetvalue: {ntp.utcoffsetvalue}")
        with ui.card():
            ui.label(f"requestsvalue: {ntp.requestsvalue}")
            ui.label(f"responsesvalue: {ntp.responsesvalue}")
            ui.label(f"requestsdroppedvalue: {ntp.requestsdroppedvalue}")
            ui.label(f"broadcastsvalue: {ntp.broadcastsvalue}")
            ui.label(f"clearcountersstatus: {ntp.clearcountersstatus}")
            ui.link("Edit")
            


