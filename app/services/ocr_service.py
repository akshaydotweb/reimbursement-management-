import re
import pytesseract
from PIL import Image

def extract_receipt(path):
    text=pytesseract.image_to_string(Image.open(path))

    amount_match=re.search(r"(?:INR|USD|EUR|₹|\\$|€)\\s?([0-9]+(?:\\.[0-9]{1,2})?)", text)
    date_match=re.search(r"\\b(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})\\b", text)

    parsed_amount=float(amount_match.group(1)) if amount_match else None
    parsed_date=date_match.group(1) if date_match else None

    return {
        "raw_text":text,
        "parsed": {
            "amount": parsed_amount,
            "date": parsed_date
        }
    }
