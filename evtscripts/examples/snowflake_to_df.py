from typing import Optional

import pandas as pd
from snowflake.connector import connect, SnowflakeConnection  # type: ignore
from snowflake.connector.cursor import SnowflakeCursor

# Gets connection from the one defined by the extension
# Will make browser window pop up to validate
conn: SnowflakeConnection = connect(
    connection_name = "mm31132.ap-southeast-2"
)

# Initialise empty dataframe
df: Optional[pd.DataFrame] = None

# Define the query to be run
sql = "SELECT * FROM EDW_ENT_PRD.CURATED.DIM_VH_CIN"

try:
    cursor: SnowflakeCursor = conn.cursor()
    cursor.execute(sql)

    # Snowflake returns a pandas DataFrame here
    df = cursor.fetch_pandas_all()
finally:
    conn.close()

print(df)
