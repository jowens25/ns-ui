
import requests
from bs4 import BeautifulSoup as bs
from datetime import datetime, timezone

def file_name_to_time(name):
    timestamp_seconds = name.split("_")[0]
    return  datetime.fromtimestamp(timestamp_seconds, timezone.utc)

def get_latest_data(references :list[str]):

    ts = {}

    for r in references:

        ts[r["href"]] = r["href"].split("_")[0]

    return max(ts, key=ts.get)

def get_network_delay_data_locally():

    host = "http://10.1.10.96:8000"

    rsp = requests.get(host)
    soup = bs(rsp.content, "html.parser")

    references = soup.find_all("a", href=True) #["href"]
    file_name = get_latest_data(references)
    rsp = requests.get(host+"/"+file_name)

    lines = rsp.content.decode('utf-8').splitlines()

    ts = []
    delays = []
    for i, line in enumerate(lines):
        if i != 0:
            values = line.split(",")
            ts.append(float(values[0]))
            delays.append(float(values[1]))

    return file_name_to_time(file_name), ts, delays

