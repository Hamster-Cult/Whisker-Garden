import pandas
import matplotlib.pyplot as plt
#import requests
"""
response = requests.get("http://127.0.0.1:8000")

if response.status_code == 200:
    data = response.json()  # or response.text for plain text
    print(data)
else:
    print(f"Request failed with status: {response.status_code}")
"""

df = pandas.read_json('data.json')
df.plot(kind = 'line', x = 'day', y = 'mood')

plt.savefig('may', transparent=True) #change to month var