from typing import Optional

import pandas as pd
from pandas import DataFrame
from snowflake.connector import connect, SnowflakeConnection  # type: ignore
from snowflake.connector.cursor import SnowflakeCursor


def query_result_via_snowflake_connection(connection_name: str, query: str) -> DataFrame:
    # Gets connection via connection name
    conn: SnowflakeConnection = connect(connection_name = connection_name)

    # Initialise empty dataframe
    df: Optional[pd.DataFrame] = None

    # Define the query to be run
    query = "SELECT * FROM EDW_ENT_PRD.CURATED.DIM_VH_CIN"

    # Temporarily init the cursor and execute the sql
    try:
        cursor: SnowflakeCursor = conn.cursor()
        cursor.execute(query)

        # Snowflake returns a pandas DataFrame here
        df = cursor.fetch_pandas_all()
    finally:
        conn.close()

    # Return the result
    return df
