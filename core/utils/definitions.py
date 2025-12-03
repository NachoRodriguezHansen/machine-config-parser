from pathlib import Path
from typing import List

class SeriesConfigBase:
    def __init__(
        self,
        series: str,
        repository_path: str,
        regex_pattern: str,
        csp_files: List[str],
        mu_config_file: str,
        out_file_name: str
    ):
        self.series = series
        self.repository_path = Path(repository_path)
        self.regex_pattern = regex_pattern
        self.csp_files = csp_files
        self.mu_config_file = mu_config_file
        self.out_file_name = out_file_name

    def __repr__(self):
        return f"<{self.series} Config @ {self.repository_path}>"

DEFAULT_OUTFILES_PATH: Path = Path("output")

ALL_SERIES_CONFIGS: List[SeriesConfigBase] = [
    SeriesConfigBase(
        "Wxxx",
        r"\\muwo-file1\ST-Data2\masch.abl\W5xx_03",
        r"^W5\d{2}_\d{6}$",
        [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
            "ControlUnit\\2_StationSelection.csp",
            "ControlUnit\\3_StationConfiguration.csp",
            "ControlUnit\\6_SafetyConfiguration.csp",
        ],
        "ControlUnit\\MU_Config.TcGVL",
        r"Wxxx\Wxxx_machines.xml",
    ),
    SeriesConfigBase(
        "T300",
        r"\\muwo-file1\ST-Data2\masch.abl\T30x_03",
        r"^T300_\d{6}$",
        [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
        ],
        "ControlUnit\\MU_CONFIG.EXP",
        r"T300\T300_machines.xml",
    ),
    SeriesConfigBase(
        "T305",
        r"\\muwo-file1\ST-Data2\masch.abl\T30x_03",
        r"^T305_\d{6}$",
        [
            "ControlUnit\\0_MetaDataProject.csp",
            "ControlUnit\\1_MachineConfiguration.csp",
        ],
        "ControlUnit\\MU_CONFIG.EXP",
        r"T305\T305_machines.xml",
    ),
    SeriesConfigBase(
        "TX6xx",
        r"\\muwo-file1\ST-Data2\masch.abl\TX6xx_03",
        r"^TX6\d{2}_\d{6}$",
        ["ControlUnit\\1_MachineConfiguration.csp"],
        "ControlUnit\\MU_Config.TcGVL",
        r"TX6xx\TX6xx_machines.xml",
    ),
]

def get_supported_series() -> List[str]:
    return [cfg.series for cfg in ALL_SERIES_CONFIGS]

def get_series_info(series: str) -> SeriesConfigBase:
    for cfg in ALL_SERIES_CONFIGS:
        if cfg.series == series:
            return cfg
