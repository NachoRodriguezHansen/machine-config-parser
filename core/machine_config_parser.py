import argparse
from pathlib import Path
from utils.find_directories import find_directories
from utils.definitions import get_series_info, get_supported_series, DEFAULT_OUTFILES_PATH
from utils.machine_data import get_machine_data_from_directories
from utils.convert_xml import convert_xml_to_csv, convert_xml_to_json
from utils.logger import configure_logger, log_info, log_warning, log_error, log_exception

logger = configure_logger(__name__)


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
        log_warning(logger, "No export format selected. Only XML will be generated.")

    # Create output directory
    out_dir = Path(__file__).parent.parent / DEFAULT_OUTFILES_PATH
    out_dir.mkdir(parents=True, exist_ok=True)

    for series in args.series:

        log_info(logger, f"Processing series '{series}'")

        # Load config for this series
        series_info = get_series_info(series)
        if series_info is None:
            log_error(logger, f"Invalid series '{series}'.")
            log_warning(logger, f"Supported: {', '.join(get_supported_series())}.")
            continue

        # Validate repository path
        repo_path = Path(series_info.repository_path)
        log_info(logger, f"Checking repository path '{repo_path}'")

        if not repo_path.exists():
            log_error(logger, "Repository path not found.")
            continue

        log_info(logger, "Repository path exists.")

        # Scan directories
        found_dirs = find_directories(str(repo_path), series_info.regex_pattern)
        if not found_dirs:
            log_error(logger, f"No directories found matching pattern for '{series}'")
            continue

        log_info(logger, f"Found {len(found_dirs)} matching directories.")

        # Generate XML
        xml_output_name = series_info.out_file_name
        xml_path = out_dir / xml_output_name

        log_info(logger, f"Generating '{xml_output_name}'...")
        try:
            get_machine_data_from_directories(found_dirs, out_dir, series_info)
        except Exception as ex:
            log_exception(logger, "Error generating XML", ex)
            continue

        log_info(logger, f"Generated XML: {xml_path}")

        # CSV Export
        if args.csv:
            csv_path = xml_path.with_suffix(".csv")
            try:
                convert_xml_to_csv(xml_path, csv_path)
                log_info(logger, f"Generated CSV: {csv_path}")
            except Exception as ex:
                log_exception(logger, "Error generating CSV", ex)

        # JSON Export
        if args.json:
            json_path = xml_path.with_suffix(".json")
            try:
                convert_xml_to_json(xml_path, json_path)
                log_info(logger, f"Generated JSON: {json_path}")
            except Exception as ex:
                log_exception(logger, "Error generating JSON", ex)

if __name__ == "__main__":
    main()
