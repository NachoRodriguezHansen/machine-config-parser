from datetime import datetime

def get_timestamp() -> str:
    return datetime.now().strftime("%H:%M:%S.%f")[:-3] + " -"
