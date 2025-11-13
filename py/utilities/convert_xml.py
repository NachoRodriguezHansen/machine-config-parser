import xml.etree.ElementTree as ET
import csv
import json
from pathlib import Path

def convert_xml_to_csv(xml_path: Path, csv_path: Path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    rows = []
    for machine in root.findall("machine"):
        rows.append(machine.attrib)
    
    if rows:
        with open(csv_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)

def convert_xml_to_json(xml_path: Path, json_path: Path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    data = [machine.attrib for machine in root.findall("machine")]
    
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)
