import snowflake

help(snowflake)



# # read creds from environment or replace with literals (not recommended)
# conn = snowflake.connector.connect(
#     user=os.getenv("SNOW_USER"),
#     password=os.getenv("SNOW_PWD"),
#     account=os.getenv("SNOW_ACCOUNT"),
#     warehouse=os.getenv("SNOW_WH"),
#     database="EDW_TRB_PRD",
#     schema="SEMANTIC",
#     role=os.getenv("SNOW_ROLE")
# )

# try:
#     sql = "SELECT * FROM EDW_TRB_PRD.SEMANTIC.TRB_TEMP_DAILY;"
#     df = conn.cursor().execute(sql).fetch_pandas_all()
# finally:
#     conn.close()

# # `df` is a pandas DataFramepoetry 