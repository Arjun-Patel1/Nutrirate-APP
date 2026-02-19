import streamlit as st
import requests
import pandas as pd

# CONFIG
API_URL = "http://127.0.0.1:8000"

st.set_page_config(page_title="NutriRate Scanner", page_icon="🥗")

# --- HEADER ---
st.title("🥗 NutriRate AI Scanner")
st.write("Scan a barcode or search for a dish to get an instant A-E health rating.")

# --- SIDEBAR: MODE SELECTION ---
mode = st.sidebar.radio("Select Mode", ["🔍 Search Food", "📷 Barcode Scanner"])

# --- MODE 1: SEARCH ---
if mode == "🔍 Search Food":
    st.header("Search Database")
    query = st.text_input("Enter food name (e.g. Samosa, Maggi):")
    
    if st.button("Search"):
        if query:
            try:
                response = requests.get(f"{API_URL}/search", params={"query": query})
                data = response.json()
                
                if data['count'] > 0:
                    st.success(f"Found {data['count']} items!")
                    
                    for item in data['results']:
                        with st.expander(f"{item['name']} ({item['brand']}) - Grade {item['grade']}"):
                            col1, col2, col3 = st.columns(3)
                            col1.metric("Sugar", f"{item['sugar']}g")
                            col2.metric("Fat", f"{item['fat']}g")
                            col3.metric("Protein", f"{item['protein']}g")
                            st.caption(f"Source: {item['source']}")
                else:
                    st.warning("No results found.")
            except:
                st.error("Error connecting to API. Is it running?")

# --- MODE 2: BARCODE SIMULATOR ---
elif mode == "📷 Barcode Scanner":
    st.header("Barcode Scanner Simulator")
    
    # In a real phone app, this would be a camera feed.
    # Here, we simulate scanning by typing the code.
    barcode_input = st.text_input("Simulate Scan (Enter Barcode):", value="11433110587")
    
    if st.button("Scan Product"):
        try:
            response = requests.get(f"{API_URL}/scan/{barcode_input}")
            
            if response.status_code == 200:
                item = response.json()['data']
                
                # --- DISPLAY RESULT ---
                st.balloons() # Fun effect
                
                # Color code the grade
                grade_color = "green" if item['grade'] in ['A', 'B'] else "orange" if item['grade'] == 'C' else "red"
                
                st.markdown(f"### Grade: :{grade_color}[{item['grade']}]")
                st.markdown(f"**{item['brand']}**")
                st.markdown(f"*{item['name']}*")
                
                # Nutrition Table
                st.table(pd.DataFrame({
                    "Nutrient": ["Calories", "Sugar", "Fat", "Protein"],
                    "Amount": [item['calories'], f"{item['sugar']}g", f"{item['fat']}g", f"{item['protein']}g"]
                }))
                
            else:
                st.error("Product not found in database.")
                
        except requests.exceptions.ConnectionError:
            st.error("❌ API is offline. Run 'uvicorn main:app --reload' first!")