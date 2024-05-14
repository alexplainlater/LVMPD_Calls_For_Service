

I'd like to do some exploratory data analysis in Python using the data I stored in SQL.  The first step is to set up a connection with my SQL server:
```python
from sqlalchemy import create_engine

server = '***'
database = 'LVMPD_Crime'
username = '******'
password = '******'

engine = create_engine( 'mssql+pyodbc://' + username + ':' + password + '@' + server + '/' + database + '?driver=ODBC+Driver+17+for+SQL+Server' )
```
The next thing I'd like to do is run a query that pulls together all the Calls to Service classifications and see which types of calls to service are most prevalent.
```python
query = '''
    SELECT
        Classification
        , QTY = COUNT(*)
    FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL
    GROUP BY
        Classification
    ORDER BY 1
'''

import pandas as pd
dfClassification = pd.read_sql( query, engine, index_col='Classification' )
dfClassification.head()
```

By plotting the data, I can see there are some categories that have a large number of Calls For Service, while there are some categories with very few.
```python
dfClassification.plot(kind="barh", figsize=(10,10))
```
![Horizontal bar chart of category frequencies.](/assets/LVMPD_Classification_BarH.png)

Which categories have the largest frequencies?
```python
dfClassification['QTY'].nlargest(10)
```

| Classification | QTY |
| ---------------------- | ------: |
| Fight                  | 238,329 |
| Family Disturbance     | 155,735 |
| Traffic Accident       | 146,377 |
| Stolen Vehicle         |  91,082 |
| Suspicious Activity    |  78,209 |
| Assault/Battery        |  71,448 |
| Larceny                |  64,126 |
| Assist Citizen         |  61,120 |
| Burglary               |  49,487 |
| Missing Person         |  39,547 |

