from pathlib import Path
import pandas as pd


def convert_xml_to_csv(xml_path: Path, csv_path: Path):
    xml_path = Path(xml_path)
    csv_path = Path(csv_path)

    if not xml_path.exists():
        raise FileNotFoundError(f"XML file not found: {xml_path}")

    try:
        df = pd.read_xml(xml_path)
    except Exception as exc:
        raise RuntimeError(f"Failed to parse XML '{xml_path}': {exc}") from exc

    try:
        df.to_csv(csv_path, index=False)
    except Exception as exc:
        raise RuntimeError(f"Failed to write CSV '{csv_path}': {exc}") from exc


def convert_xml_to_json(xml_path: Path, json_path: Path):
    xml_path = Path(xml_path)
    json_path = Path(json_path)

    if not xml_path.exists():
        raise FileNotFoundError(f"XML file not found: {xml_path}")

    try:
        df = pd.read_xml(xml_path)
    except Exception as exc:
        raise RuntimeError(f"Failed to parse XML '{xml_path}': {exc}") from exc

    try:
        df.to_json(json_path, orient="records", indent=2)
    except Exception as exc:
        raise RuntimeError(f"Failed to write JSON '{json_path}': {exc}") from exc