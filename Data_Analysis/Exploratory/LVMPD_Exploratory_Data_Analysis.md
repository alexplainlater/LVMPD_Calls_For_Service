# LVMPD Exploratory Data Analysis

## (in-progress)

I'd like to do some exploratory data analysis in Python using the data I stored in SQL.  The first step is to set up a connection with my SQL server:

```python
from sqlalchemy import create_engine

server = '***'
database = 'LVMPD_Crime'
username = '******'
password = '******'

engine = create_engine( 'mssql+pyodbc://' + username + ':' + password + '@' + server + '/' + database + '?driver=ODBC+Driver+17+for+SQL+Server' )
```

The next thing I'd like to do is run a query that pulls together all the Calls For Service classifications and see which types of calls for service are most prevalent.

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

![Horizontal bar chart of category frequencies.](https://github.com/alexplainlater/LVMPD_Calls_For_Service/blob/main/Data_Analysis/Exploratory/assets/LVMPD_Classification_BarH.png)

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

I wonder how these look by year.  There are years 2019 - 2023 of data included, so let's break that out.

```python
query = '''
    SELECT
        Classification
        , QTY = COUNT(*)
        , QTY_2019 = SUM( CASE WHEN Year = '2019' THEN 1 ELSE 0 END )
        , QTY_2020 = SUM( CASE WHEN Year = '2020' THEN 1 ELSE 0 END )
        , QTY_2021 = SUM( CASE WHEN Year = '2021' THEN 1 ELSE 0 END )
        , QTY_2022 = SUM( CASE WHEN Year = '2022' THEN 1 ELSE 0 END )
        , QTY_2023 = SUM( CASE WHEN Year = '2023' THEN 1 ELSE 0 END )
    FROM LVMPD_Crime.dbo.LVMPD_Calls_For_Service_ALL
    GROUP BY
        Classification
    ORDER BY 1
'''

dfClassificationByYear = pd.read_sql( query, engine, index_col='Classification' )
dfClassificationByYear.head()
```

And again, we can plot this, but this time stacking the years so they each show up as a different color

```python
dfClassificationByYear.drop('QTY', axis = 1).plot.barh(stacked=True, figsize=(10,10))
```

![Horizontal bar chart of category frequencies by year - stacked.](https://github.com/alexplainlater/LVMPD_Calls_For_Service/blob/main/Data_Analysis/Exploratory/assets/LVMPD_Classification_ByYear_BarH.png)

I wonder how they change by year over year

```python
dfClassificationByYear['Increase_2020'] = dfClassificationByYear['QTY_2020'] - dfClassificationByYear['QTY_2019']
dfClassificationByYear['Increase_2021'] = dfClassificationByYear['QTY_2021'] - dfClassificationByYear['QTY_2020']
dfClassificationByYear['Increase_2022'] = dfClassificationByYear['QTY_2022'] - dfClassificationByYear['QTY_2021']
dfClassificationByYear['Increase_2023'] = dfClassificationByYear['QTY_2023'] - dfClassificationByYear['QTY_2022']
dfClassificationByYear
```

|                                | QTY    | QTY_2019 | QTY_2020 | QTY_2021 | QTY_2022 | QTY_2023 | Increase_2020 | Increase_2021 | Increase_2022 | Increase_2023 |
|--------------------------------|--------|----------|----------|----------|----------|----------|---------------|---------------|---------------|---------------|
| Classification                 |        |          |          |          |          |          |               |               |               |               |
| Airplane Emergency             | 49     | 9        | 2        | 7        | 17       | 14       | -7            | 5             | 10            | -3            |
| Animal Complaint               | 2067   | 443      | 363      | 436      | 439      | 386      | -80           | 73            | 3             | -53           |
| Assault/Battery                | 71448  | 13212    | 14579    | 15100    | 14936    | 13621    | 1367          | 521           | -164          | -1315         |
| Assist An Officer              | 7760   | 1408     | 1620     | 1617     | 1556     | 1559     | 212           | -3            | -61           | 3             |
| Assist Citizen                 | 61120  | 15392    | 11258    | 10959    | 12063    | 11448    | -4134         | -299          | 1104          | -615          |
| Auto Burglary                  | 30716  | 6853     | 5458     | 5775     | 6476     | 6154     | -1395         | 317           | 701           | -322          |
| Burglary                       | 49487  | 11849    | 8774     | 9050     | 10417    | 9397     | -3075         | 276           | 1367          | -1020         |
| Civil Matter                   | 12264  | 1931     | 2082     | 2686     | 2606     | 2959     | 151           | 604           | -80           | 353           |
| Dead Body                      | 12622  | 1793     | 2437     | 2793     | 2899     | 2700     | 644           | 356           | 106           | -199          |
| DUI                            | 12619  | 2343     | 2916     | 2876     | 2446     | 2038     | 573           | -40           | -430          | -408          |
| Explosive Device               | 307    | 52       | 50       | 93       | 58       | 54       | -2            | 43            | -35           | -4            |
| Family Disturbance             | 155735 | 30969    | 31292    | 32121    | 32060    | 29293    | 323           | 829           | -61           | -2767         |
| Fight                          | 238329 | 48465    | 50268    | 46533    | 44794    | 48269    | 1803          | -3735         | -1739         | 3475          |
| Fire                           | 1806   | 249      | 360      | 408      | 375      | 414      | 111           | 48            | -33           | 39            |
| Fraud                          | 30699  | 7523     | 6745     | 6460     | 5403     | 4568     | -778          | -285          | -1057         | -835          |
| Homicide                       | 452    | 55       | 78       | 111      | 102      | 106      | 23            | 33            | -9            | 4             |
| Illegal Shooting               | 8740   | 916      | 2025     | 1929     | 1941     | 1929     | 1109          | -96           | 12            | -12           |
| Indecent Exposure              | 3691   | 707      | 698      | 746      | 779      | 761      | -9            | 48            | 33            | -18           |
| Injured Officer                | 2191   | 356      | 455      | 475      | 453      | 452      | 99            | 20            | -22           | -1            |
| Intoxicated Person             | 206    | 55       | 40       | 43       | 42       | 26       | -15           | 3             | -1            | -16           |
| Keeping the Peace              | 21178  | 4795     | 4640     | 4555     | 3939     | 3249     | -155          | -85           | -616          | -690          |
| Kidnap                         | 630    | 154      | 129      | 128      | 129      | 90       | -25           | -1            | 1             | -39           |
| Larceny                        | 64126  | 13942    | 10703    | 12034    | 14460    | 12987    | -3239         | 1331          | 2426          | -1473         |
| Malicious Destruct of Property | 33517  | 5703     | 6611     | 7121     | 7306     | 6776     | 908           | 510           | 185           | -530          |
| Missing Person                 | 39547  | 9754     | 7126     | 7322     | 7831     | 7514     | -2628         | 196           | 509           | -317          |
| Missing/Found Property         | 32341  | 8475     | 5631     | 6191     | 5977     | 6067     | -2844         | 560           | -214          | 90            |
| Narcotics                      | 7554   | 2335     | 1696     | 1421     | 1084     | 1018     | -639          | -275          | -337          | -66           |
| Person with Weapon             | 8401   | 1302     | 1550     | 1718     | 1904     | 1927     | 248           | 168           | 186           | 23            |
| Prowler                        | 1342   | 288      | 280      | 233      | 263      | 278      | -8            | -47           | 30            | 15            |
| Reckless Driver                | 3914   | 703      | 834      | 880      | 763      | 734      | 131           | 46            | -117          | -29           |
| Robbery                        | 9211   | 2181     | 1847     | 1638     | 1981     | 1564     | -334          | -209          | 343           | -417          |
| Stolen Property                | 9380   | 2725     | 2261     | 1511     | 1541     | 1342     | -464          | -750          | 30            | -199          |
| Stolen Vehicle                 | 91082  | 15126    | 14056    | 16255    | 20244    | 25401    | -1070         | 2199          | 3989          | 5157          |
| Suspicious Activity            | 78209  | 16452    | 15740    | 14822    | 15563    | 15632    | -712          | -918          | 741           | 69            |
| Traffic Accident               | 146377 | 31268    | 23082    | 29209    | 31185    | 31633    | -8186         | 6127          | 1976          | 448           |
| Traffic Problem                | 24405  | 6177     | 4413     | 4928     | 4439     | 4448     | -1764         | 515           | -489          | 9             |
| Unknown Trouble                | 6833   | 1408     | 1515     | 1329     | 1315     | 1266     | 107           | -186          | -14           | -49           |
| Wanted Subject                 | 20642  | 6709     | 3763     | 3692     | 3400     | 3078     | -2946         | -71           | -292          | -322          |

That's not terribly helpful, let's look at the percentage change year over year

```python
dfClassificationByYear['Increase_perc_2020'] = ( dfClassificationByYear['QTY_2020'] - dfClassificationByYear['QTY_2019'] ) / dfClassificationByYear['QTY_2019']
dfClassificationByYear['Increase_perc_2021'] = ( dfClassificationByYear['QTY_2021'] - dfClassificationByYear['QTY_2020'] ) / dfClassificationByYear['QTY_2020']
dfClassificationByYear['Increase_perc_2022'] = ( dfClassificationByYear['QTY_2022'] - dfClassificationByYear['QTY_2021'] ) / dfClassificationByYear['QTY_2021']
dfClassificationByYear['Increase_perc_2023'] = ( dfClassificationByYear['QTY_2023'] - dfClassificationByYear['QTY_2022'] ) / dfClassificationByYear['QTY_2022']
dfClassificationByYear
```

|                                | QTY    | QTY_2019 | QTY_2020 | QTY_2021 | QTY_2022 | QTY_2023 | Increase_2020 | Increase_2021 | Increase_2022 | Increase_2023 | Increase_perc_2020 | Increase_perc_2021 | Increase_perc_2022 | Increase_perc_2023 |
|--------------------------------|--------|----------|----------|----------|----------|----------|---------------|---------------|---------------|---------------|--------------------|--------------------|--------------------|--------------------|
| Classification                 |        |          |          |          |          |          |               |               |               |               |                    |                    |                    |                    |
| Airplane Emergency             | 49     | 9        | 2        | 7        | 17       | 14       | -7            | 5             | 10            | -3            | -0.777778          | 2.500000           | 1.428571           | -0.176471          |
| Animal Complaint               | 2067   | 443      | 363      | 436      | 439      | 386      | -80           | 73            | 3             | -53           | -0.180587          | 0.201102           | 0.006881           | -0.120729          |
| Assault/Battery                | 71448  | 13212    | 14579    | 15100    | 14936    | 13621    | 1367          | 521           | -164          | -1315         | 0.103467           | 0.035736           | -0.010861          | -0.088042          |
| Assist An Officer              | 7760   | 1408     | 1620     | 1617     | 1556     | 1559     | 212           | -3            | -61           | 3             | 0.150568           | -0.001852          | -0.037724          | 0.001928           |
| Assist Citizen                 | 61120  | 15392    | 11258    | 10959    | 12063    | 11448    | -4134         | -299          | 1104          | -615          | -0.268581          | -0.026559          | 0.100739           | -0.050982          |
| Auto Burglary                  | 30716  | 6853     | 5458     | 5775     | 6476     | 6154     | -1395         | 317           | 701           | -322          | -0.203560          | 0.058080           | 0.121385           | -0.049722          |
| Burglary                       | 49487  | 11849    | 8774     | 9050     | 10417    | 9397     | -3075         | 276           | 1367          | -1020         | -0.259516          | 0.031457           | 0.151050           | -0.097917          |
| Civil Matter                   | 12264  | 1931     | 2082     | 2686     | 2606     | 2959     | 151           | 604           | -80           | 353           | 0.078198           | 0.290106           | -0.029784          | 0.135457           |
| Dead Body                      | 12622  | 1793     | 2437     | 2793     | 2899     | 2700     | 644           | 356           | 106           | -199          | 0.359175           | 0.146081           | 0.037952           | -0.068644          |
| DUI                            | 12619  | 2343     | 2916     | 2876     | 2446     | 2038     | 573           | -40           | -430          | -408          | 0.244558           | -0.013717          | -0.149513          | -0.166803          |
| Explosive Device               | 307    | 52       | 50       | 93       | 58       | 54       | -2            | 43            | -35           | -4            | -0.038462          | 0.860000           | -0.376344          | -0.068966          |
| Family Disturbance             | 155735 | 30969    | 31292    | 32121    | 32060    | 29293    | 323           | 829           | -61           | -2767         | 0.010430           | 0.026492           | -0.001899          | -0.086307          |
| Fight                          | 238329 | 48465    | 50268    | 46533    | 44794    | 48269    | 1803          | -3735         | -1739         | 3475          | 0.037202           | -0.074302          | -0.037371          | 0.077577           |
| Fire                           | 1806   | 249      | 360      | 408      | 375      | 414      | 111           | 48            | -33           | 39            | 0.445783           | 0.133333           | -0.080882          | 0.104000           |
| Fraud                          | 30699  | 7523     | 6745     | 6460     | 5403     | 4568     | -778          | -285          | -1057         | -835          | -0.103416          | -0.042254          | -0.163622          | -0.154544          |
| Homicide                       | 452    | 55       | 78       | 111      | 102      | 106      | 23            | 33            | -9            | 4             | 0.418182           | 0.423077           | -0.081081          | 0.039216           |
| Illegal Shooting               | 8740   | 916      | 2025     | 1929     | 1941     | 1929     | 1109          | -96           | 12            | -12           | 1.210699           | -0.047407          | 0.006221           | -0.006182          |
| Indecent Exposure              | 3691   | 707      | 698      | 746      | 779      | 761      | -9            | 48            | 33            | -18           | -0.012730          | 0.068768           | 0.044236           | -0.023107          |
| Injured Officer                | 2191   | 356      | 455      | 475      | 453      | 452      | 99            | 20            | -22           | -1            | 0.278090           | 0.043956           | -0.046316          | -0.002208          |
| Intoxicated Person             | 206    | 55       | 40       | 43       | 42       | 26       | -15           | 3             | -1            | -16           | -0.272727          | 0.075000           | -0.023256          | -0.380952          |
| Keeping the Peace              | 21178  | 4795     | 4640     | 4555     | 3939     | 3249     | -155          | -85           | -616          | -690          | -0.032325          | -0.018319          | -0.135236          | -0.175171          |
| Kidnap                         | 630    | 154      | 129      | 128      | 129      | 90       | -25           | -1            | 1             | -39           | -0.162338          | -0.007752          | 0.007812           | -0.302326          |
| Larceny                        | 64126  | 13942    | 10703    | 12034    | 14460    | 12987    | -3239         | 1331          | 2426          | -1473         | -0.232320          | 0.124358           | 0.201595           | -0.101867          |
| Malicious Destruct of Property | 33517  | 5703     | 6611     | 7121     | 7306     | 6776     | 908           | 510           | 185           | -530          | 0.159214           | 0.077144           | 0.025979           | -0.072543          |
| Missing Person                 | 39547  | 9754     | 7126     | 7322     | 7831     | 7514     | -2628         | 196           | 509           | -317          | -0.269428          | 0.027505           | 0.069517           | -0.040480          |
| Missing/Found Property         | 32341  | 8475     | 5631     | 6191     | 5977     | 6067     | -2844         | 560           | -214          | 90            | -0.335575          | 0.099449           | -0.034566          | 0.015058           |
| Narcotics                      | 7554   | 2335     | 1696     | 1421     | 1084     | 1018     | -639          | -275          | -337          | -66           | -0.273662          | -0.162146          | -0.237157          | -0.060886          |
| Person with Weapon             | 8401   | 1302     | 1550     | 1718     | 1904     | 1927     | 248           | 168           | 186           | 23            | 0.190476           | 0.108387           | 0.108265           | 0.012080           |
| Prowler                        | 1342   | 288      | 280      | 233      | 263      | 278      | -8            | -47           | 30            | 15            | -0.027778          | -0.167857          | 0.128755           | 0.057034           |
| Reckless Driver                | 3914   | 703      | 834      | 880      | 763      | 734      | 131           | 46            | -117          | -29           | 0.186344           | 0.055156           | -0.132955          | -0.038008          |
| Robbery                        | 9211   | 2181     | 1847     | 1638     | 1981     | 1564     | -334          | -209          | 343           | -417          | -0.153141          | -0.113156          | 0.209402           | -0.210500          |
| Stolen Property                | 9380   | 2725     | 2261     | 1511     | 1541     | 1342     | -464          | -750          | 30            | -199          | -0.170275          | -0.331712          | 0.019854           | -0.129137          |
| Stolen Vehicle                 | 91082  | 15126    | 14056    | 16255    | 20244    | 25401    | -1070         | 2199          | 3989          | 5157          | -0.070739          | 0.156446           | 0.245401           | 0.254742           |
| Suspicious Activity            | 78209  | 16452    | 15740    | 14822    | 15563    | 15632    | -712          | -918          | 741           | 69            | -0.043277          | -0.058323          | 0.049993           | 0.004434           |
| Traffic Accident               | 146377 | 31268    | 23082    | 29209    | 31185    | 31633    | -8186         | 6127          | 1976          | 448           | -0.261801          | 0.265445           | 0.067650           | 0.014366           |
| Traffic Problem                | 24405  | 6177     | 4413     | 4928     | 4439     | 4448     | -1764         | 515           | -489          | 9             | -0.285576          | 0.116701           | -0.099229          | 0.002027           |
| Unknown Trouble                | 6833   | 1408     | 1515     | 1329     | 1315     | 1266     | 107           | -186          | -14           | -49           | 0.075994           | -0.122772          | -0.010534          | -0.037262          |
| Wanted Subject                 | 20642  | 6709     | 3763     | 3692     | 3400     | 3078     | -2946         | -71           | -292          | -322          | -0.439112          | -0.018868          | -0.079090          | -0.094706          |

Ok, which categories have the largest increase in 2023 from 2022?

```python
dfClassificationByYear['Increase_perc_2023'].nlargest(10)
```

| Classification            | Increase_perc_2023 |
| ------------------------- | --------: |
| Stolen Vehicle            | 0.254742 |
| Civil Matter              | 0.135457 |
| Fire                      | 0.104000 |
| Fight                     | 0.077577 |
| Prowler                   | 0.057034 |
| Homicide                  | 0.039216 |
| Missing/Found Property    | 0.015058 |
| Traffic Accident          | 0.014366 |
| Person with Weapon        | 0.012080 |
| Suspicious Activity       | 0.004434 |

So stolen vehicles was the category with the largest increase of Calls for Service with a 25% increase in 2023 versus 2022.
