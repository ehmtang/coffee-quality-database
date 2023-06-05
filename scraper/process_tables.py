import pandas as pd
import numpy as np
import glob
import csv


# Get a list of CSV files with "table_1" in their names
file_list = glob.glob("*table_1*.csv")

df_list  = []
for file_name in file_list:

    with open(file_name, 'r', encoding='utf-8') as csv_file:
        
        # Find the indices of the 3rd and 4th underscores
        third_underscore_index = file_name.find('_', file_name.find('_', file_name.find('_') + 1) + 1)
        fourth_underscore_index = file_name.find('_', third_underscore_index + 1)

        # Extract the substring between the 3rd and 4th underscores
        coffee_id = file_name[third_underscore_index + 1:fourth_underscore_index]
        
        reader = csv.reader(csv_file)
        try:
            # Read all rows from the csv file
            rows = [row for row in reader]

            # Extract columns from rows and restructure the data
            df_temp = [[row[1], row[2]] for row in rows] + [[row[3], row[4]] for row in rows]
            df_temp = pd.DataFrame(df_temp, columns=[0, 1])
            df_temp = df_temp.transpose()
            header_row = df_temp.iloc[0]
            df_temp = pd.DataFrame(df_temp.values[1:], columns=header_row)
            df_temp['coffee_id'] = coffee_id
            df_list.append(df_temp)

        except:
            pass

# Concatenate all DataFrames into one DataFrame
arabica_coffee_sample_infomation = pd.concat(df_list, ignore_index=True)

# Export the combined DataFrame
arabica_coffee_sample_infomation.to_csv("arabica_coffee_sample_infomation.csv", index=False)

# Get a list of CSV files with "table_2" in their names
file_list = glob.glob("*table_2*.csv")

df_list  = []
for file_name in file_list:

    with open(file_name, 'r', encoding='utf-8') as csv_file:
        
        # Find the indices of the 3rd and 4th underscores
        third_underscore_index = file_name.find('_', file_name.find('_', file_name.find('_') + 1) + 1)
        fourth_underscore_index = file_name.find('_', third_underscore_index + 1)

        # Extract the substring between the 3rd and 4th underscores
        coffee_id = file_name[third_underscore_index + 1:fourth_underscore_index]
        
        reader = csv.reader(csv_file)
        try:
            # Read all rows from the csv file
            rows = [row for row in reader]

            # Extract columns from rows and restructure the data
            df_temp = [[row[1], row[2]] for row in rows] + [[row[3], row[4]] for row in rows]
            df_temp = pd.DataFrame(df_temp, columns=[0, 1])
            df_temp = df_temp.transpose()
            header_row = df_temp.iloc[0]
            df_temp = pd.DataFrame(df_temp.values[1:], columns=header_row)
            df_temp['coffee_id'] = coffee_id
            df_list.append(df_temp)

        except:
            pass

# Concatenate all DataFrames into one DataFrame
arabica_coffee_cupping_scores = pd.concat(df_list, ignore_index=True)

# Export the combined DataFrame
arabica_coffee_cupping_scores.to_csv("arabica_coffee_cupping_scores.csv", index=False)


# Get a list of CSV files with "table_3" in their names
file_list = glob.glob("*table_3*.csv")

df_list = []
for file_name in file_list:

    with open(file_name, 'r', encoding='utf-8') as csv_file:
        
        # Find the indices of the 3rd and 4th underscores
        third_underscore_index = file_name.find('_', file_name.find('_', file_name.find('_') + 1) + 1)
        fourth_underscore_index = file_name.find('_', third_underscore_index + 1)

        # Extract the substring between the 3rd and 4th underscores
        coffee_id = file_name[third_underscore_index + 1:fourth_underscore_index]
        
        reader = csv.reader(csv_file)
        try:
            # Skip the header row
            next(reader)

            # Extract the desired values
            output = []
            for row in reader:
                key_value_pairs = [row[i:i+2] for i in range(1, len(row), 2) if row[i]]
                output.extend(key_value_pairs)

            # Append the transformed data to the df_list
            df_temp = pd.DataFrame(output)            
            df_temp = df_temp.transpose()
            df_temp['coffee_id'] = coffee_id
            df_list.append(df_temp)

        except:
            pass

# Concatenate all DataFrames into one DataFrame
arabica_coffee_green_analysis = pd.concat(df_list, ignore_index=True)

# Export the combined DataFrame
arabica_coffee_green_analysis.to_csv("arabica_coffee_green_analysis.csv", index=False)


# Get a list of CSV files with "table_4" in their names
file_list = glob.glob("*table_4*.csv")

df_list  = []
for file_name in file_list:

    with open(file_name, 'r', encoding='utf-8') as csv_file:
        
        # Find the indices of the 3rd and 4th underscores
        third_underscore_index = file_name.find('_', file_name.find('_', file_name.find('_') + 1) + 1)
        fourth_underscore_index = file_name.find('_', third_underscore_index + 1)

        # Extract the substring between the 3rd and 4th underscores
        coffee_id = file_name[third_underscore_index + 1:fourth_underscore_index]
        
        reader = csv.reader(csv_file)
        try:
            # Read all rows from the csv file
            rows = [row for row in reader]
            
            # Extract columns from rows and restructure the data
            df_temp = [[row[1], row[2:]] for row in rows]
            df_temp = pd.DataFrame(df_temp, columns=[0, 1])
            df_temp = df_temp.transpose()
            header_row = df_temp.iloc[0]
            df_temp = pd.DataFrame(df_temp.values[1:], columns=header_row)
            df_temp['coffee_id'] = coffee_id
            df_list.append(df_temp)
            
        except:
            pass

# Concatenate all DataFrames into one DataFrame
arabica_coffee_certification_information = pd.concat(df_list, ignore_index=True)

# Export the combined DataFrame
arabica_coffee_certification_information.to_csv("arabica_coffee_certification_information.csv", index=False)