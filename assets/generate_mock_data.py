import pandas as pd
import random
import string

# -------------------------------
# 1. Define name pools (native to Mumbai / Maharashtra)
# -------------------------------
first_names = [
    "Aditya", "Siddharth", "Rohan", "Omkar", "Tejas", "Pratik", "Ashwin",
    "Kunal", "Nikhil", "Sameer", "Vivek", "Aniket", "Sagar", "Ganesh",
    "Shreya", "Anjali", "Priya", "Pooja", "Sneha", "Aarti", "Madhuri", "Swati",
    "Ketaki", "Rohini", "Mrunal", "Vaishali", "Chinmay", "Mithila", "Siddhant", "Shreyas", "Tanvi",
    "Asmita", "Vaibhavi", "Deven", "Harshal" , "Sachi", "Lavanya" , "Kunjan"

]

middle_names =[ "Vighnesh" , "Pravin", "Aayush" , "Karan" , "Laxman", "Shailesh", "Rajaram", "Pawan"
               , "Kishor" , "Reyansh" , "Rajendra", "Shivram", "Babaji" , "Tarak" , "Sunil" , "Anil",
               "Raghu" , "Surya"]

last_names = [
    "Patil", "Joshi", "Kulkarni", "Deshmukh", "Deshpande", "Shinde", "Pawar",
    "More", "Gaikwad", "Kadam", "Chavan", "Phadke", "Mhatre", "Salvi", "Rane",
    "Jadhav", "Bhosale", "Gore", "Mahajan", "Kale" , "Shigwan", "Ainkar", "Pagade"
]

# Ensure every first name has at least 5 letters (for password rule)
for name in first_names:
    assert len(name) >= 5, f"Name '{name}' is too short (need ≥5 letters)"

# -------------------------------
# 2. Generate 500 unique 12-digit user IDs
# -------------------------------
random.seed(42)  # for reproducible mock data
existing_ids = set()
user_ids = []

while len(user_ids) < 500:
    uid = random.randint(10**11, 10**12 - 1)  # exactly 12 digits
    if uid not in existing_ids:
        existing_ids.add(uid)
        user_ids.append(str(uid))  # store as string
# -------------------------------
# 3. Build each row: Name, Password
# -------------------------------
data = []
for uid in user_ids:
    first = random.choice(first_names)
    last = random.choice(last_names)
    middle = random.choice(middle_names)   # <- fixed
    full_name = f"{first} {middle} {last}"
    
    password_part1 = first[:5].lower()
    password_part2 = uid[-7:]
    password = password_part1 + password_part2

    data.append({
        "User ID": uid,
        "Name": full_name,
        "Password": password
    })
# -------------------------------
# 4. Create DataFrame and export to Excel
# -------------------------------
df = pd.DataFrame(data)
df.to_excel("mock_voting_data.xlsx", index=False)

print("✅ Excel file 'mock_voting_data.xlsx' created with 500 rows.")
print("\nFirst 5 rows preview:")
print(df.head())