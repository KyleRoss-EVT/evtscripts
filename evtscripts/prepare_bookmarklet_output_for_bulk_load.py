"""Script that takes a folder and transforms the files. Files are expected to match schema output from a javascript bookmarklet run on a Power BI report permissions page"""

import os

import pandas as pd

# Config values
target_folder = "C:/Users/rossk/OneDrive - EVT/Documents - Group BI & Analytics/BI-TEAM/02. Projects/User Group Deployment/ENT APP Bulk Load - 2025-07-16/Raw"
output_folder = "C:/Users/rossk/OneDrive - EVT/Documents - Group BI & Analytics/BI-TEAM/02. Projects/User Group Deployment/ENT APP Bulk Load - 2025-07-16/Prepared"
first_row_text = "version:v1.0"
second_row_text = "Member object ID or user principal name [memberObjectIdOrUpn] Required"
email_col_name = "Email"
permissions_col_name = "Permissions"
permissions_contains = [ "Workspace Viewer", "Read" ]

# Gather paths of all files
file_paths = [os.path.join(dirpath,f) for (dirpath, dirnames, filenames) in os.walk(target_folder) for f in filenames]

# Function to filter df on contained permission strings
def permissions_filter(row) -> bool:
    """Return true if any of the permissions are in the permissions column string"""
    value = row.get(permissions_col_name, "")
    return any(p in str(value) for p in permissions_contains)

# Adjusts the dataframe to meet the IT bulk upload spec
def make_adjustment(path: str) -> pd.DataFrame:
        df = pd.read_csv(path, encoding='utf-8-sig')
        mask = df.apply(permissions_filter, axis=1)
        df = df[mask]
        emails = df[email_col_name].unique()
        value_list = [first_row_text, second_row_text] + emails.tolist()
        new_df = pd.DataFrame(value_list)
        return new_df

# Loop over the file paths, adjust them, and save the new df in the output location
# Checks that output is not overwriting any input file before saving
for path in file_paths:
      file_name = os.path.basename(path)
      output_file_path = f"{output_folder}/{file_name}"
      df = make_adjustment(path)
      assert output_file_path not in file_paths, f"{output_file_path} already exists! Did not save file."
      df.to_csv(output_file_path, index=False, header=False)
