from ydata_profiling import ProfileReport  # type: ignore

from evtscripts.query_utils.query_snowflake import query_result_via_snowflake_connection
from evtscripts.datetime_utils.current_dt import current_datetime_str

# Define constants
connection_name = "mm31132.ap-southeast-2"
query = """
    SELECT * 
    FROM EDW_ENT_PRD.CURATED.DIM_VH_CIN
"""
output_name = "thredbo_emplive_profile_report"
relative_output_path = "evtscripts/2025-12-18 - TRB EmpLive Dev/output/"

# Get data
df = query_result_via_snowflake_connection(connection_name, query)

# Generate profile
profile = ProfileReport(df, title=output_name)
profile.to_file(f"{relative_output_path}{output_name} {current_datetime_str()}.html")
