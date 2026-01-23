from pathlib import Path

from ydata_profiling import ProfileReport  # type: ignore

from evtscripts.query_utils.query_snowflake import (
    query_result_via_snowflake_connection,
)
from evtscripts.query_utils.build_output_paths import PathContext


def minimal_profile(path_context: PathContext, query: str) -> None:
    connection_name = "mm31132.ap-southeast-2"

    # Get data
    df = query_result_via_snowflake_connection(connection_name, query)

    # Generate profile
    profile = ProfileReport(df, title=path_context.file_name, minimal=True)
    profile.to_file(path_context.output_file_path)


if __name__ == "__main__":
    path_context = PathContext(
        Path("evtscripts/query_utils/example"),
        "minimal_data_profile_main DIM_VH_SITE",
        "html",
        dt_in_name=False,
    )
    minimal_profile(path_context, "SELECT * FROM EDW_ENT_PRD.CURATED.DIM_VH_SITE")
