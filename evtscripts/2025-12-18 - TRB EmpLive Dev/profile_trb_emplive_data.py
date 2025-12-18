from evtscripts.query_utils.query_snowflake import query_result_via_snowflake_connection

connection_name = "mm31132.ap-southeast-2"
query = """
    SELECT * 
    FROM EDW_ENT_PRD.CURATED.DIM_VH_CIN
"""

df = query_result_via_snowflake_connection(connection_name, query)

print(df)