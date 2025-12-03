import argparse
from pathlib import Path
from colorama import init, Fore
from core.utils.timestamp import get_timestamp
from utils.find_directories import find_directories
from core.utils.definitions import get_series_info, get_supported_series, DEFAULT_OUTFILES_PATH
from core.utils.machine_data import get_machine_data_from_directories
from utils.convert_xml import convert_xml_to_csv, convert_xml_to_json

init(autoreset=True)


def main():
    parser = argparse.ArgumentParser(
        formatter_class=lambda prog: argparse.RawDescriptionHelpFormatter(
            prog, width=200, max_help_position=50
        )
    )

    parser.add_argument(
        "--series",
        nargs="+",
        required=True,
        help="List of machine series to process"
    )
    parser.add_argument(
        "--csv",
        action="store_true",
        help="Export results as CSV"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Export results as JSON"
    )

    args = parser.parse_args()

    # Ensure at least one output format if XML is not the final target
    if not (args.csv or args.json):
        print(f"{Fore.YELLOW}{get_timestamp()} No export format selected. Only XML will be generated.")

    # Create output directory
    out_dir = Path(__file__).parent / DEFAULT_OUTFILES_PATH
    out_dir.mkdir(parents=True, exist_ok=True)

    for series in args.series:

        print(f"{Fore.CYAN}{get_timestamp()} Processing series '{series}'")

        # Load config for this series
        series_info = get_series_info(series)
        if series_info is None:
            print(f"{Fore.RED}{get_timestamp()} Invalid series '{series}'.")
            print(f"{Fore.YELLOW}{get_timestamp()} Supported: {', '.join(get_supported_series())}.")
            continue

        # Validate repository path
        repo_path = Path(series_info.repository_path)
        print(f"{get_timestamp()} Checking repository path '{repo_path}'")

        if not repo_path.exists():
            print(f"{Fore.RED}{get_timestamp()} Repository path not found.")
            continue

        print(f"{Fore.GREEN}{get_timestamp()} Repository path exists.")

        # Scan directories
        found_dirs = find_directories(str(repo_path), series_info.regex_pattern)
        if not found_dirs:
            print(f"{Fore.RED}{get_timestamp()} No directories found matching pattern for '{series}'")
            continue

        print(f"{Fore.GREEN}{get_timestamp()} Found {len(found_dirs)} matching directories.")

        # Generate XML
        xml_output_name = series_info.out_file_name
        xml_path = out_dir / xml_output_name

        print(f"{get_timestamp()} Generating '{xml_output_name}'...")
        try:
            get_machine_data_from_directories(found_dirs, out_dir, series_info)
        except Exception as ex:
            print(f"{Fore.RED}{get_timestamp()} Error generating XML: {ex}")
            continue

        print(f"{Fore.GREEN}{get_timestamp()} Generated XML: {xml_path}")

        # CSV Export
        if args.csv:
            csv_path = xml_path.with_suffix(".csv")
            try:
                convert_xml_to_csv(xml_path, csv_path)
                print(f"{Fore.GREEN}{get_timestamp()} Generated CSV: {csv_path}")
            except Exception as ex:
                print(f"{Fore.RED}{get_timestamp()} Error generating CSV: {ex}")

        # JSON Export
        if args.json:
            json_path = xml_path.with_suffix(".json")
            try:
                convert_xml_to_json(xml_path, json_path)
                print(f"{Fore.GREEN}{get_timestamp()} Generated JSON: {json_path}")
            except Exception as ex:
                print(f"{Fore.RED}{get_timestamp()} Error generating JSON: {ex}")

if __name__ == "__main__":
    main()
