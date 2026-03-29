import pytesseract
from PIL import Image

def extract_receipt(path):
    text=pytesseract.image_to_string(Image.open(path))
    return {"raw_text":text}