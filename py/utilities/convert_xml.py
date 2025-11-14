from pathlib import Path
import pandas as pd

def convert_xml_to_csv(xml_path: Path, csv_path: Path):
    df = pd.read_xml(xml_path)
    df.to_csv(csv_path, index=False)

def convert_xml_to_json(xml_path: Path, json_path: Path):
    df = pd.read_xml(xml_path)
    df.to_json(json_path, orient="records", indent=2)