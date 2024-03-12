import json
import requests

# Read config.json
with open('config.json') as config_file:
    config = json.load(config_file)

ogc_api_list = []
fetched_processes_dict = {}

# Iterate through config entries
for entry in config:
    ogc_api = entry['ogc_api']
    processes = entry['processes']
    
    # Add ogc_api to the list
    ogc_api_list.append(ogc_api)
    
    # Initialize dictionary for fetched processes for each OGC API
    fetched_processes_dict[ogc_api] = []
    
    # Make request to fetch processes
    if '*' in processes:
        # Fetch all processes
        response = requests.get(ogc_api + "processes")
        if response.status_code == 200:
            fetched_processes = response.json()['processes']
            for process in fetched_processes:
                fetched_processes_dict[ogc_api].append(process['title'])
        else:
            print(f"Failed to fetch processes for {ogc_api}")
    else:
        # Fetch specified processes
        for process in processes:
            response = requests.get(ogc_api + "processes/" + process)
            if response.status_code == 200:
                fetched_process = response.json()
                fetched_processes_dict[ogc_api].append(fetched_process['title'])
            else:
                print(f"Failed to fetch process for {ogc_api} - {process}")

# Print conditional block for OGC APIs and corresponding processes
print("<conditional name='ogc_api_selector'>")
print("<param name='selected_ogc_api' type='select' label='Select OGC API'>")
for ogc_api in ogc_api_list:
    print(f"<option value='{ogc_api}'>{ogc_api}</option>")
print("</param>")

# Generate when blocks for each OGC API
for ogc_api, processes in fetched_processes_dict.items():
    print(f"<when value='{ogc_api}'>")
    print("<param name='selected_process' type='select' label='Select Process'>")
    for process in processes:
        print(f"<option value='{process}'>{process}</option>")
    print("</param>")
    print("</when>")

print("</conditional>")
