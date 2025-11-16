# %%
from pathlib import Path
from sqlalchemy import create_engine
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

database_path = Path(__file__).resolve().parents[2]/'data'/'loyalty-system'/'database.db'
query_path = Path(__file__).resolve().parents[2]/'src'/'analytcs'/'frequencia_valor.sql'
engine = create_engine(f'sqlite:///{database_path}')

def import_query(query_path):
    with open(query_path) as open_file:
        return open_file.read()

query = import_query(query_path)
df = pd.read_sql(query, engine)
df = df[df['qtdePontosPos'] < 4000]

# %%
# plt.scatter(df['qtdeFrequencia'], df['qtdePontosPos'])
# plt.grid(True)
# plt.xlabel('frequencia')
# plt.ylabel('valor')
# plt.show()

from sklearn import cluster
from sklearn import preprocessing

# %%
minmax = preprocessing.MinMaxScaler() 
X = minmax.fit_transform(df[['qtdeFrequencia', 'qtdePontosPos']])
# X = df[['qtdeFrequencia', 'qtdePontosPos']]

kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(X)
df['cluster_calc'] = kmean.labels_
df.groupby(by='cluster_calc')['IdCliente'].count()

# %%
sns.scatterplot(
    data=df,
    x="qtdeFrequencia",
    y="qtdePontosPos",
    hue="cluster_calc",
    palette="deep")

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.legend().remove()
plt.grid(True)

# %%
sns.scatterplot(
    data=df,
    x="qtdeFrequencia",
    y="qtdePontosPos",
    hue="cluster",
    palette="deep")

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.legend().remove()
plt.grid(True)

# %%
kmean = cluster.KMeans(n_clusters=7, random_state=42, max_iter=1000)
kmean.fit(X)
df['cluster_calc'] = kmean.labels_
df.groupby(by='cluster_calc')['IdCliente'].count()

sns.scatterplot(
    data=df,
    x="qtdeFrequencia",
    y="qtdePontosPos",
    hue="cluster_calc",
    palette="deep")

plt.hlines(y=1500, xmin=0, xmax=25, colors='black')
plt.hlines(y=750, xmin=0, xmax=25, colors='black')

plt.vlines(x=4, ymin=0, ymax=750, colors='black')
plt.vlines(x=10, ymin=0, ymax=3000, colors='black')

plt.legend().remove()
plt.grid(True)
# %%
