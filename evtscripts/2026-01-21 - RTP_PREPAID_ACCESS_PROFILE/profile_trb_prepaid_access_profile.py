from ydata_profiling import ProfileReport  # type: ignore

from evtscripts.query_utils.query_snowflake import query_result_via_snowflake_connection
from evtscripts.datetime_utils.current_dt import current_datetime_str

# Define constants
connection_name = "mm31132.ap-southeast-2"
query = """
    SELECT * 
    FROM EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE
"""
output_name = "RTP_PREPAID_ACCESS_PROFILE ydata"
relative_output_path = "evtscripts/2026-01-21 - RTP_PREPAID_ACCESS_PROFILE/output/"

# Get data
print("Querying snowflake")
df = query_result_via_snowflake_connection(connection_name, query)
print("Received data, beginning profiling")

# Generate profile
profile = ProfileReport(df, title=output_name)
profile.to_file(f"{relative_output_path}{output_name} {current_datetime_str()}.html")
print("Complete")
