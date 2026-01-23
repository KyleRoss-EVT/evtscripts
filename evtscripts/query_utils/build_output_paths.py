from dataclasses import dataclass

from pathlib import Path

from evtscripts.datetime_utils.current_dt import current_datetime_str


@dataclass
class PathContext:
    output_folder_path: Path
    file_name: str
    file_type: str
    dt_in_name: bool = True
    raise_error_if_exists: bool = True

    @property
    def output_file_path(self) -> Path:
        folder_path = Path(self.output_folder_path)
        if not folder_path.exists():
            raise TypeError(
                f"output_folder_path: '{self.output_folder_path}' does not exist"
            )
        if not folder_path.is_dir():
            raise TypeError(
                f"output_folder_path: '{self.output_folder_path}' is not a directory"
            )
        output_file_path = (
            folder_path
            / f"{self.file_name} {' ' + current_datetime_str() if self.dt_in_name else ''}.html"
        )
        if self.raise_error_if_exists and output_file_path.exists():
            raise ValueError(
                f"Generated output path: {output_file_path.as_posix()} already exists, and 'raise_error_if_exists' = True"
            )
        return output_file_path
