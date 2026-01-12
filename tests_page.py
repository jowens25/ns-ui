import asyncio
from mysocket.mysocket import socket_received, write_socket, socket_reader, socket_writer, socket_setup
from rest_api import APIClient
from nicegui import ui, app, background_tasks, events

import pandas as pd


import plotly.graph_objects as go
import plotly.express as px

import plotly.io as pio
pio.templates.default = "plotly_dark"

from network_delay import get_network_delay_data_locally, calculate_last_50_jitter

async def tests_page():


    with ui.column():
        with ui.row() as pageContainer:
            ui.label("Network Delay Test Data").classes("text-h5")

            @ui.refreshable
            def build_plot():

                start, ts, delays = get_network_delay_data_locally()

                f1 = go.Figure(go.Scatter(x=list(range(len(delays))),y=delays))
                f2 = go.Figure(px.histogram(x=delays))
                jitter = calculate_last_50_jitter(delays)
                f1.update_xaxes(title_text=f"Samples - Jitter on last 50: {jitter}")
                f1.update_yaxes(title_text="RTT (Delay) (ms)")

                f1.update_layout(title_text=f"Ping Over VPN Test Started: {start}")

                #fig.update_layout(title_text="Pinging home server from novus",margin=dict(l=0, r=0, t=0, b=0))

                p1 = ui.plotly(f1).classes("w-full")
                p2 = ui.plotly(f2).classes("w-full")

                return f1, p1, f2 , p2
            f1, p1, f2, p2 = build_plot()

            def update_plots():

                _, ts, delays = get_network_delay_data_locally()
                jitter = calculate_last_50_jitter(delays)
                f1.update_xaxes(title_text=f"Samples - Jitter on last 50: {jitter}")
                f1.data[0].x = list(range(len(delays)))
                f1.data[0].y = delays

                f2.data[0].x = delays

                p1.update()
                p2.update()


            ui.timer(5, callback=update_plots)



            def get_down_latest():

                _, ts, delays = get_network_delay_data_locally()

                data = {"ts": ts, "rtt": delays}

                df = pd.DataFrame(data)

                df.to_excel("temp.xlsx", index=False, header=True)

                ui.download.file('temp.xlsx')

        ui.button("Download latest", on_click=get_down_latest ).classes("bg-accent")


            

