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
output_folder = r"evtscripts/2026-01-23 - DBT Profilling/output"
schema_prefix = "DBT.DBT_silver.silver_"
target_tables: List[List[str]] = [
    ["orders", " ORDER BY sale_date LIMIT 100000"],
    ["order_items", " ORDER BY sale_date LIMIT 100000"],
    ["order_sub_items", " LIMIT 100000"],
    ["sessions", " ORDER BY session_date DESC LIMIT 100000"],
    ["screens", ""],
    ["sites", ""],
    ["customers", " ORDER BY created_at DESC LIMIT 100000"],
    # ["sentiment",""], -- doesn't exist yet
    ["movies", ""],
    ["visits", " ORDER BY first_order_ts DESC LIMIT 100000"],
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

    try:
        minimal_profile(path, df)
        print_in_brackets(f"Finished {msg_suffix}")
    except ValueError:
        print_in_brackets(f"Skipping {msg_suffix}, output exists")

# End and print
print_in_brackets("Script end")
