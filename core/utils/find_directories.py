from pathlib import Path
import re
from typing import List
import os

def find_directories(path: str, regex_pattern: str) -> List[Path]:
    pattern = re.compile(regex_pattern)
    with os.scandir(path) as it:
        return [Path(entry.path) for entry in it if entry.is_dir() and pattern.match(entry.name)]
