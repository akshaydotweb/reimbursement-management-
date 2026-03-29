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


def get_rate(base_currency):
    try:
        data = requests.get(
            f"https://api.exchangerate-api.com/v4/latest/{base_currency}",
            timeout=5
        ).json()
        return data.get("rates", {})
    except Exception as e:
        print("Exchange rate API failed:", e)
        return {}


def convert_amount(amount, from_currency, to_currency):
    if not amount or not from_currency or not to_currency:
        return amount
    if from_currency == to_currency:
        return amount
    rates=get_rate(from_currency)
    rate=rates.get(to_currency)
    if not rate:
        return amount
    return round(amount * rate, 2)
