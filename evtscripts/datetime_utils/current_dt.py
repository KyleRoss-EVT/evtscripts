from datetime import datetime
from typing import Final

def current_datetime_str() -> str:
    FORMAT: Final[str] = "%Y-%m-%d %H-%M-%S"
    return datetime.now().strftime(FORMAT)
