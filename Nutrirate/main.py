from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import numpy as np
import os
import ast

app = FastAPI(title="NutriRate API", version="1.0")

# --- CONFIGURATION ---
# UPDATE THIS PATH to match your actual file location
CSV_PATH = r"C:\Users\arjun\Downloads\Nutri Rate\master_food_database.csv"

# Global variable to hold our database
food_db = None

# --- UTILITY: CLEAN NAMES ON THE FLY ---
def clean_name_display(val, brand=""):
    """
    Smart Display: 
    1. Fixes list formats like "['soup']"
    2. If name is 'Unknown' or missing, uses Brand name instead.
    """
    # 1. Handle non-strings or empty strings
    if not isinstance(val, str) or val.strip() == "" or val.lower() == "nan":
        return f"{brand} Product" if brand and str(brand).lower() != "nan" else "Unknown Product"
    
    # 2. Clean List Format "['...']"
    if val.startswith("['") and val.endswith("']"):
        try:
            val = val[2:-2]
        except:
            pass
            
    # 3. Clean specific bad words
    # Remove 'unknown' if it's part of the string
    val_clean = val.replace("unknown", "").replace("Unknown", "").strip()
    
    # 4. Final Fallback
    # If the cleaning left us with an empty string, fallback to brand
    if len(val_clean) < 2:
        return f"{brand} Product" if brand and str(brand).lower() != "nan" else "Unknown Product"
        
    return val_clean.replace("-", " ").title()

def calculate_missing_grade(item):
    """
    If the grade is 'unknown', calculate it based on Sugar and Fat.
    Simple Logic:
    - High Sugar (>22g) OR High Fat (>17g) -> E (Unhealthy)
    - Moderate Sugar (>10g) OR Moderate Fat (>10g) -> C/D
    - Low Sugar & Fat -> A/B (Healthy)
    """
    # If we already have a valid grade (A-E), keep it
    current_grade = str(item.get('grade', '')).lower()
    if current_grade in ['a', 'b', 'c', 'd', 'e']:
        return current_grade
    
    # Otherwise, calculate it!
    try:
        sugar = float(item.get('sugar', 0))
        fat = float(item.get('fat', 0))
        
        # Simple "Traffic Light" Logic
        if sugar > 22.5 or fat > 17.5:
            return 'e' # Red
        elif sugar > 10 or fat > 10:
            return 'c' # Yellow
        elif sugar > 5 or fat > 3:
            return 'b' # Green-ish
        else:
            return 'a' # Green
            
    except:
        return 'unknown'

# --- STARTUP EVENT ---
@app.on_event("startup")
def load_database():
    global food_db
    if os.path.exists(CSV_PATH):
        print("⏳ Loading Database into Memory...")
        
        # 1. Load CSV (Treat barcode as Object/String initially)
        df = pd.read_csv(CSV_PATH, dtype={'barcode': object})
        
        # 2. Clean NaNs
        df = df.fillna("")
        
        # 3. THE NUCLEAR FIX: Handle Scientific Notation & Decimals
        def fix_barcode(val):
            try:
                # Convert to string first to check content
                s_val = str(val).strip()
                
                # If it looks like scientific notation (e.g. "9.78E+14") or float ("123.0")
                # We convert to float -> int (removes decimals) -> str
                return str(int(float(s_val)))
            except:
                # If it's already a text string (e.g. "abc"), keep it
                return s_val

        # Apply the fix to every single barcode
        df['barcode'] = df['barcode'].apply(fix_barcode)
        
        food_db = df
        print(f"✅ API Ready! Loaded {len(food_db)} items.")
        
        # DEBUG PRINT: Check the specific problematic barcode
        check = df[df['barcode'] == '978542272905355']
        if not check.empty:
            print(f"🎯 FOUND THE BARCODE: 978542272905355 is loaded correctly!")
        else:
            print(f"⚠️ Note: 978542272905355 not in DB (This is expected if the CSV didn't contain it).")

    else:
        print("❌ CRITICAL ERROR: Database file not found at path!")

# --- ENDPOINT 1: BARCODE SCANNER ---
@app.get("/scan/{barcode}")
def scan_product(barcode: str):
    if food_db is None:
        raise HTTPException(status_code=503, detail="Database not loaded")

    clean_input = barcode.strip()
    result = food_db[food_db['barcode'] == clean_input]
    
    if result.empty:
        raise HTTPException(status_code=404, detail="Product not found")
    
    item = result.iloc[0].to_dict()
    
    # 1. Clean Name
    item['name'] = clean_name_display(item['name'], str(item.get('brand', '')))
    
    # 2. CALCULATE GRADE IF MISSING (The Fix)
    item['grade'] = calculate_missing_grade(item)
    
    return {
        "status": "success",
        "data": item
    }
# --- ENDPOINT 2: TEXT SEARCH (For "Samosa") ---
@app.get("/search")
def search_food(query: str):
    if food_db is None:
        raise HTTPException(status_code=503, detail="Database not loaded")
    
    mask = (
        food_db['name'].str.contains(query, case=False, na=False) | 
        food_db['brand'].str.contains(query, case=False, na=False)
    )
    
    results = food_db[mask].head(10)
    
    if results.empty:
        return {"status": "success", "count": 0, "results": []}
    
    output = []
    for _, row in results.iterrows():
        row_dict = row.to_dict()
        
        # 1. Clean Name
        row_dict['name'] = clean_name_display(row_dict['name'], str(row_dict.get('brand', '')))
        
        # 2. CALCULATE GRADE IF MISSING (The Fix)
        row_dict['grade'] = calculate_missing_grade(row_dict)
        
        output.append(row_dict)
        
    return {
        "status": "success",
        "count": len(output),
        "results": output
    }

# --- ENDPOINT 3: DEBUG (To check data) ---
@app.get("/debug/barcodes")
def see_barcodes():
    if food_db is None:
        return {"error": "DB not loaded"}
    return {
        "sample_barcodes": food_db['barcode'].head(10).tolist(),
        "total_items": len(food_db)
    }

# --- ROOT CHECK ---
@app.get("/")
def home():
    return {"message": "NutriRate API is Running", "items_loaded": len(food_db) if food_db is not None else 0}