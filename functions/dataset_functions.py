import mltable
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

def load_dataset(name, version=None):
    ml_client = MLClient.from_config(credential=DefaultAzureCredential())

    if version == None:
        print("No version specified. Selecting latest version")
        data_asset = ml_client.data.get(f"{name}", label="latest")
    else:
        print(f"version specified. Selecting version: ")
        #data_asset = ml_client.data.get(f"{name}", version=version)

    tbl = mltable.load(f'azureml:/{data_asset.id}')

    df = tbl.to_pandas_dataframe()
    return df