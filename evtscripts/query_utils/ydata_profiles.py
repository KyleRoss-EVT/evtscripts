from pathlib import Path

from ydata_profiling import ProfileReport  # type: ignore

from evtscripts.query_utils.query_snowflake import (
    query_result_via_snowflake_connection,
)
from evtscripts.datetime_utils.current_dt import current_datetime_str


def minimal_profile(
    output_folder: str, file_name: str, query: str, dt_in_name: bool = True
) -> None:
    connection_name = "mm31132.ap-southeast-2"

    # Build path with checks
    folder_path = Path(output_folder)
    if not folder_path.exists():
        raise TypeError(f"output_folder path: '{output_folder}' does not exist")
    if not folder_path.is_dir():
        raise TypeError(f"output_folder path: '{output_folder}' is not a directory")
    output_file_path = (
        folder_path
        / f"{file_name} {' ' + current_datetime_str() if dt_in_name else ''}.html"
    )

    # Get data
    df = query_result_via_snowflake_connection(connection_name, query)

    # Generate profile
    profile = ProfileReport(df, title=file_name, minimal=True)
    profile.to_file(output_file_path)


if __name__ == "__main__":
    minimal_profile(
        "evtscripts/query_utils/example",
        "minimal_data_profile_main",
        "SELECT * FROM EDW_ENT_PRD.CURATED.DIM_VH_SITE",
    )
