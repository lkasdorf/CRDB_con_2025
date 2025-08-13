## CRDB → ZOHO Books Converter

Converts CRDB bank statements (XLS) into the CSV format that can be imported into Zoho Books.

### Contents
- `convert_crdb_to_zoho.py`: CLI script for conversion
- `_inspect_xls.py`: small helper script to analyze new/changed XLS layouts
- `files/`: workspace for input/output files (ignored via `.gitignore`)

### Requirements
- Python 3.11 (or compatible)
- Windows PowerShell (examples below use PowerShell paths)
- Linux/macOS shells are supported (examples provided)

### Setup (recommended with virtual environment)
Windows (PowerShell):
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install pandas==2.2.2 xlrd==2.0.1
```

Linux/macOS (bash/zsh):
```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install pandas==2.2.2 xlrd==2.0.1
```

### Usage
Windows (PowerShell):
1) Place the CRDB source file (e.g., `crdb_input.xls`) into `source/` for batch mode, or `files/` for single-file mode.
2) Batch conversion (recommended):
```powershell
.\.venv\Scripts\python.exe convert_crdb_to_zoho.py --source source --dest converted
```
3) Force re-run even if targets exist:
```powershell
.\.venv\Scripts\python.exe convert_crdb_to_zoho.py --source source --dest converted --force
```
4) Single-file conversion (optional):
```powershell
.\.venv\Scripts\python.exe convert_crdb_to_zoho.py -i files\crdb_input.xls -o converted\crdb_input.csv
```

Linux/macOS (bash/zsh):
1) Place the CRDB source file (e.g., `crdb_input.xls`) into `source/` for batch mode, or `files/` for single-file mode.
2) Batch conversion (recommended):
```bash
python3 convert_crdb_to_zoho.py --source source --dest converted
```
3) Force re-run even if targets exist:
```bash
python3 convert_crdb_to_zoho.py --source source --dest converted --force
```
4) Single-file conversion (optional):
```bash
python3 convert_crdb_to_zoho.py -i files/crdb_input.xls -o converted/crdb_input.csv
```
5) Import the generated CSV(s) from `converted/` into Zoho Books.

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
```bash
python3 _inspect_xls.py
```

### Versioning
- The `files/` directory is added to `.gitignore` and not versioned.
- The `source/` and `converted/` directories are versioned but kept empty in a fresh clone via `.gitkeep` files. Output CSVs and logs will appear in `converted/` after running the converter.

### License
See `LICENSE`.
