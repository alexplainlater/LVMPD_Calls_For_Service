

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

dfClassification = pd.read_sql( query, engine, index_col='Classification' )
dfClassification.head()
```