## CRDB → ZOHO Books Converter

Converts CRDB bank statements (XLS) into the CSV format that can be imported into Zoho Books.

### Contents
- `convert_crdb_to_zoho.py`: CLI script for conversion
- `_inspect_xls.py`: small helper script to analyze new/changed XLS layouts
- `files/`: workspace for input/output files (ignored via `.gitignore`)

### Requirements
- Python 3.11 (or compatible)
- Windows PowerShell (examples below use PowerShell paths)

### Setup (recommended with virtual environment)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install pandas==2.2.2 xlrd==2.0.1
```

### Usage
1) Place the CRDB source file (e.g., `crdb_input.xls`) into `files/`.
2) Run the conversion:
```powershell
.\.venv\Scripts\python.exe convert_crdb_to_zoho.py -i files\crdb_input.xls -o files\zoho_converted.csv
```
3) Import `files/zoho_converted.csv` into Zoho Books.

### Target format (CSV)
Semicolon-separated (;) with this header:
```
Date;Withdrawals;Deposits;Payee;Description;Reference Number
```

Notes:
- Dates are output as `YYYY-MM-DD`.
- Amounts are decimals with a dot (e.g., `212.40`).
- `Payee` remains empty, `Description` defaults to `Transfer`, `Reference Number` contains the CRDB details/narration.

### Helper script (optional)
Shows header candidate(s) and sample rows from the XLS file – useful if the CRDB layout changes:
```powershell
.\.venv\Scripts\python.exe _inspect_xls.py
```

### Versioning
- The `files/` directory is added to `.gitignore` and not versioned.

### License
See `LICENSE`.
