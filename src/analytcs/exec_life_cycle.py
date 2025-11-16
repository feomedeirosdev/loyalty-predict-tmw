# %%
import pandas as pd
import sqlalchemy

def import_query(path):
    with open(path) as file:
        query = file.read()
    return query

query_path = "/home/medeiros/TrilhaML/18_loyalty-predict-main/src/analytcs/life_cycle.sql"
query = import_query(query_path)

dataset_app_path = "/home/medeiros/TrilhaML/18_loyalty-predict-main/data/loyalty-system/database.db"
dataset_analytical_path = "/home/medeiros/TrilhaML/18_loyalty-predict-main/data/analytics/database.db"
engine_app = sqlalchemy.create_engine(f'sqlite:///{dataset_app_path}')
engine_analytical = sqlalchemy.create_engine(f'sqlite:///{dataset_analytical_path}')

df = pd.read_sql_query(query, engine_app)
dates = [
    "2024-03-01",
    "2024-04-01",
    "2024-05-01",
    "2024-06-01",
    "2024-07-01",
    "2024-08-01",
    "2024-09-01",
    "2024-10-01",
    "2024-11-01",
    "2024-12-01",
    "2025-01-01",
    "2025-02-01",
    "2025-03-01",
    "2025-04-01",
    "2025-05-01",
    "2025-06-01",
    "2025-07-01",
    "2025-08-01",
    "2025-09-01",
]

# %%
for i in dates:

    with engine_analytical.connect() as con:
        try:
            query_delete = f"DELETE FROM life_cycle WHERE dtRef = date('{i}', '-1 day')"
            con.execute(sqlalchemy.text(query_delete))
            con.commit()
        except Exception as err:
            print(err)

    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists="append")

