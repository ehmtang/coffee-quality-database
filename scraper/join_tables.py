import pandas as pd

df1 = pd.read_csv("C:/Users/erwin/OneDrive/Desktop/coffee/arabica_coffee_sample_infomation.csv")
df2 = pd.read_csv("C:/Users/erwin/OneDrive/Desktop/coffee/arabica_coffee_cupping_scores.csv")
df3 = pd.read_csv("C:/Users/erwin/OneDrive/Desktop/coffee/arabica_coffee_green_analysis.csv")
df4 = pd.read_csv("C:/Users/erwin/OneDrive/Desktop/coffee/arabica_coffee_certification_information.csv")

result = pd.merge(df1, df2, on='coffee_id').merge(df3, on='coffee_id').merge(df4, on='coffee_id')
result = result.drop_duplicates()
#result.to_csv("arabica_coffee_full_dataset.csv", index=False)
print(f"Number of duplicated rows: {result.duplicated().sum()}")
