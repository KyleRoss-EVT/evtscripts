from typing import List
from pathlib import Path

from evtscripts.datetime_utils.current_dt import current_datetime_str
from evtscripts.query_utils.build_output_paths import PathContext

from evtscripts.query_utils.ydata_profiles import minimal_profile
from evtscripts.query_utils.query_snowflake import query_result_via_snowflake_connection


def print_in_brackets(text: str):
    """Print stuff with some brackets around it, and datetime"""
    message_bracket_lh = "→→→"
    message_bracket_rh = "←←←"
    print(f"{message_bracket_lh}{current_datetime_str()}|{text}{message_bracket_rh}")


# Define inputs and outputs
output_folder = r"evtscripts/2026-01-30 - SVS Profilling/output"
schema_prefix = "EDW_PRD.CURATED."
target_tables: List[List[str]] = [
    ["SVS_MEMBER", " ORDER BY UPDATE_DATE DESC LIMIT 100000"],
    ["SVS_EVT_MEMBER_SUMMARY", " ORDER BY UPDATE_DATE DESC LIMIT 100000"],
    ["SVS_BRAZE_EVT_MEMBER_CHANGE_SNAPSHOT", " ORDER BY SNAPSHOT_DATE DESC DESC LIMIT 100000"],
    ["SVS_EVT_MEMBER", " ORDER BY UPDATE_DATE DESC LIMIT 100000"],
]

# Run script
print_in_brackets("Script start")

# Build path context
target_paths = [
    PathContext(
        Path(output_folder), name[0], "html", query_suffix=name[1], dt_in_name=False
    )
    for name in target_tables
]
print_in_brackets("Generated paths")

# Iterate over the paths
print_in_brackets("Starting iteration over paths")
for path in target_paths:
    table_name = f"{schema_prefix}{path.file_name}"

    query = f"SELECT * FROM {table_name}{path.query_suffix};"
    query_prefix = f"query of {table_name}"

    print_in_brackets(f"Starting {query_prefix}")
    df = query_result_via_snowflake_connection("mm31132.ap-southeast-2", query)
    print_in_brackets(f"Finished {query_prefix}")

    msg_suffix = f"profiling {table_name}"
    print_in_brackets(f"Starting {msg_suffix}")

    minimal_profile(path, df)

# End and print
print_in_brackets("Script end")
