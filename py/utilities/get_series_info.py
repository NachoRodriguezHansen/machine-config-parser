from types import SimpleNamespace
from pathlib import Path

def get_series_info(series_prefix: str) -> SimpleNamespace:
    """
    Returns repository path, regex pattern, CSP files, MU config file, and output filename
    for the given machine series prefix.
    """
    if series_prefix == "Wxxx":
        repository_path = Path(r"\\muwo-file1\ST-Data2\masch.abl\W5xx_03")
        regex_pattern = r"^W5\d{2}_\d{6}$"
        csp_files = [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
            "ControlUnit\\2_StationSelection.csp",
            "ControlUnit\\3_StationConfiguration.csp",
            "ControlUnit\\6_SafetyConfiguration.csp",
        ]
        mu_config_file = "ControlUnit\\MU_Config.TcGVL"
        out_file_name = "wxxx_machines.xml"

    elif series_prefix == "T300":
        repository_path = Path(r"\\muwo-file1\ST-Data2\masch.abl\T30x_03")
        regex_pattern = r"^T300_\d{6}$"
        csp_files = [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
        ]
        mu_config_file = "ControlUnit\\MU_CONFIG.EXP"
        out_file_name = "T300_machines.xml"

    elif series_prefix == "T305":
        repository_path = Path(r"\\muwo-file1\ST-Data2\masch.abl\T30x_03")
        regex_pattern = r"^T305_\d{6}$"
        csp_files = [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
        ]
        mu_config_file = "ControlUnit\\MU_CONFIG.EXP"
        out_file_name = "T300_machines.xml"

    elif series_prefix == "TX6xx":
        repository_path = Path(r"\\muwo-file1\ST-Data2\masch.abl\TX6xx_03")
        regex_pattern = r"^TX6\d{2}_\d{6}$"
        csp_files = ["ControlUnit\\1_MachineConfiguration.csp"]
        mu_config_file = "ControlUnit\\MU_Config.TcGVL"
        out_file_name = "TX6xx_machines_v00.xml"

    else:
        raise ValueError(
            f"Invalid series prefix '{series_prefix}'. Supported: Wxxx, T300, T305, TX6xx."
        )

    return SimpleNamespace(
        SeriesPrefix=series_prefix,
        RepositoryPath=repository_path,
        RegexPattern=regex_pattern,
        CspFiles=csp_files,
        MuConfigFile=mu_config_file,
        OutFileName=out_file_name,
    )
