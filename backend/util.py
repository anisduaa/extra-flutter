from ultralytics import YOLO
from PIL import Image
from io import BytesIO

def load_model(model_path):
    model = YOLO(model_path)  # Use the YOLO class from ultralytics
    return model

model = load_model('license_plate_detector.pt')

def detect_license_plate(img_bytes):
    image = Image.open(BytesIO(img_bytes))
    results = model(image)
    # Assuming the result has a method to extract the best guess for the plate
    plate_number = results.pandas().xyxy[0]['name'].iloc[0]  # Modify according to your model's output
    return plate_number
