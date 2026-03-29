import requests

def get_country_currency(country):
    try:
        data = requests.get(
            "https://restcountries.com/v3.1/all?fields=name,currencies",
            timeout=5
        ).json()

        for c in data:
            if c["name"]["common"].lower() == country.lower():
                return list(c.get("currencies", {"USD": None}).keys())[0]

    except Exception as e:
        print("Currency API failed:", e)

    return "USD"