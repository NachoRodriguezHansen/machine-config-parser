import re
import xml.etree.ElementTree as ET
from pathlib import Path
from colorama import init, Fore
from typing import List, Tuple
from core.utils.timestamp import get_timestamp
from core.utils.definitions import SeriesConfigBase

init(autoreset=True)

CS_NAMESPACE = {"cs": "http://www.codesmithtools.com/schema/csp.xsd"}

def get_codesmith_nodes(file_path: Path, node_name: str = "property") -> List[ET.Element]:
    if not file_path.is_file():
        print(f"{get_timestamp()} WARNING: File not found: {file_path}")
        return []

    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        nodes = root.findall(f".//cs:{node_name}", CS_NAMESPACE)
        return nodes
    except ET.ParseError as e:
        print(f"{get_timestamp()} ERROR: Failed to parse {file_path}: {e}")
        return []

def get_file_nodes(base_path: Path, files: List[str], node_name: str = "property") -> List[Tuple[str, str]]:
    node_list: List[Tuple[str, str]] = []
    for file in files:
        file_path = base_path / file
        nodes = get_codesmith_nodes(file_path, node_name=node_name)
        if nodes:
            for node in nodes:
                name = node.get("name")
                value = node.text or ""
                node_list.append((name, value))
        else:
            print(f"{Fore.YELLOW}{get_timestamp()} File '{file}' has no '{node_name}' nodes.")
    return node_list

def get_machine_data_from_directories(found_dirs: List[Path], output_directory: Path, series_info: SeriesConfigBase):
    output_directory.mkdir(parents=True, exist_ok=True)
    xml_path = output_directory / series_info.out_file_name
    xml_path.parent.mkdir(parents=True, exist_ok=True)

    root = ET.Element("repository")

    for idx, dir_path in enumerate(found_dirs, start=1):
        print(f"{get_timestamp()} Copying properties from {dir_path.name} [{idx}/{len(found_dirs)}]")

        type_, sn = dir_path.name.split("_")
        machine = ET.SubElement(root, "machine", TYPE=type_, SN=sn)

        # Read software version
        mu_file = dir_path / series_info.mu_config_file
        if mu_file.exists():
            for line in mu_file.read_text(encoding="utf-8").splitlines():
                if "HMICFGgszProgramVersion" in line:
                    match = re.search(r"'(.*?)'", line)
                    if match:
                        sw_version = match.group(1)
                        machine.set("SW_VERSION", sw_version)

        # Process CSP files
        nodes = get_file_nodes(dir_path, series_info.csp_files)
        for name, value in nodes:
            machine.set(name, value)

        # Indent XML and save after each machine
        ET.indent(root, space="  ")
        ET.ElementTree(root).write(xml_path, encoding="utf-8", xml_declaration=True)

        #if (idx > 10):
        #    break
