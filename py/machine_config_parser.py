import sys
import argparse
from pathlib import Path
from colorama import init, Fore, Style
from utilities.get_timestamp import get_timestamp
from utilities.find_directories import find_directories
from utilities.get_series_info import get_series_info
from utilities.get_machine_data import get_machine_data
from utilities.convert_xml import convert_xml_to_csv, convert_xml_to_json
init(autoreset=True)

def main():
    parser = argparse.ArgumentParser(description="Parses and analyzes machine configuration XML files")
    parser.add_argument("-SeriesPrefixes", nargs="+", default=["Wxxx"], help="Series prefixes to process")
    parser.add_argument("-CSV", action="store_true", help="Export to CSV")
    parser.add_argument("-JSON", action="store_true", help="Export to JSON")
    args = parser.parse_args()

    out_dir = Path(__file__).parent / "outfiles"
    out_dir.mkdir(exist_ok=True)

    for series_prefix in args.SeriesPrefixes:
        # Get series info
        print(f"{Fore.CYAN}{get_timestamp()} Processing series '{series_prefix}'")
        series_info = get_series_info.get_series_info(series_prefix)

        # Check path
        print(f"{get_timestamp()} Checking repository path '{series_info.RepositoryPath}'")
        if not Path.exists(series_info.RepositoryPath):
            print(f"{Fore.RED}{get_timestamp()} Repository path not found.")
            continue
        print(f"{Fore.GREEN}{get_timestamp()} Repository path exists.")

        # Find directories
        found_dirs = find_directories(str(series_info.RepositoryPath), series_info.RegexPattern)
        if not found_dirs:
            print(f"{Fore.RED}{get_timestamp()} No directories found for {series_prefix}")
            continue
        print(f"{Fore.GREEN}{get_timestamp()} Found {len(found_dirs)} directories matching pattern.")

        # Get machine data and generate XML
        print(f"{get_timestamp()} Generating '{series_info.OutFileName}'...")
        get_machine_data.get_machine_data_from_directories(found_dirs, out_dir, series_info)

        # 
        xml_path = out_dir / series_info.OutFileName
        print(f"{Fore.GREEN}{get_timestamp()} Generated XML: {xml_path}")
        
        # Convert to CSV
        if args.CSV:
            csv_path = xml_path.with_suffix(".csv")
            convert_xml_to_csv(xml_path, csv_path)
            print(f"{get_timestamp()} Generated CSV: {csv_path}")

        # Convert to JSON
        if args.JSON:
            json_path = xml_path.with_suffix(".json")
            convert_xml_to_json(xml_path, json_path)
            print(f"{get_timestamp()} Generated JSON: {json_path}")

if __name__ == "__main__":
    main()
