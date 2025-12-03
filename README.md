# 🧩 Machine Config Parser

**Machine Config Parser** is a lightweight tool that parses and analyzes machine configuration XML files to extract relevant attributes and version information from archived machines.

---

## 🚀 Features

- Parses machine configuration XML files.  
- Extracts key attributes and version details.  
- Generates structured output files for further analysis.  
- Supports batch processing of multiple configurations.  

---

## 📦 Installation
Optional:
```bash
C:\el\tools\Python\Python313\python.exe -m pip install --upgrade pip
```
Clone the repository and install dependencies:

```bash
git clone https://github.com/your-repo/machine-config-parser.git
cd machine-config-parser
C:\el\tools\Python\Python313\python.exe -m pip install -r requirements.txt
```

---

## ⚙️ Parser usage
```bash
&C:\el\tools\Python\Python313\python.exe .\core\machine_config_parser.py --series Wxxx T300 T305 --csv
```

## ⚙️ App usage
```bash
&C:\el\tools\Python\Python313\python.exe -m streamlit run .\app\app.py 
```