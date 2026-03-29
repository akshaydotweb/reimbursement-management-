import requests

def get_country_currency(country):

    data=requests.get(
        "https://restcountries.com/v3.1/all?fields=name,currencies"
    ).json()

    for c in data:
        if c["name"]["common"]==country:
            return list(c["currencies"].keys())[0]

    return "USD"