import asyncio
from mysocket.mysocket import socket_received, write_socket, socket_reader, socket_writer, socket_setup
from rest_api import APIClient
from nicegui import ui, app, background_tasks, events
        
import plotly.graph_objects as go
from network_delay import get_network_delay_data_locally

async def tests_page():
    with ui.column() as pageContainer:
        ui.label("Network Delay Test Data").classes("text-h5")



        def build_plot():

            start, ts, delays = get_network_delay_data_locally()

        

            fig = go.Figure(go.Scatter(x=list(range(len(delays))),y=delays))

            fig.update_xaxes(title_text="Samples")
            fig.update_yaxes(title_text="Delay (ms)")

            fig.update_layout(title_text=f"Ping Test: {start}")

            #fig.update_layout(title_text="Pinging home server from novus",margin=dict(l=0, r=0, t=0, b=0))

            plot = ui.plotly(fig).classes("h-full")
            return plot, fig

        plot, fig = build_plot()

        def refresh_plot():
            # re-read file and update trace data

            start, ts, delays = get_network_delay_data_locally()


            # update the existing figure instead of creating a new one
            fig.data[0].y = delays
            plot.update()

        ui.timer(10, callback=refresh_plot)


            

