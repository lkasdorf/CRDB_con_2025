## CRDB → ZOHO Books Converter

Converts CRDB bank statements (XLS/XLSX) into the CSV format that can be imported into Zoho Books.

### Contents
- `convert_crdb_to_zoho.py`: CLI script for conversion
- `_inspect_xls.py`: small helper script to analyze new/changed XLS layouts
- `files/`: workspace for input/output files (ignored via `.gitignore`)

### Requirements
- Python 3.11 (or compatible)
- Windows PowerShell (examples below use PowerShell paths)
- Linux/macOS shells are supported (examples provided)
 - Dependencies: see `requirements.txt` (includes `pandas`, `xlrd`, `openpyxl`)

### Setup (recommended with virtual environment)
Windows (PowerShell):
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Linux/macOS (bash/zsh):
```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
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

### Installation (lokal/standalone)

Variante A: Installation in eine virtuelle Umgebung (empfohlen)
- Windows (PowerShell): siehe Abschnitt "Setup". Danach:
```powershell
pip install -e .
```
- Linux/macOS:
```bash
pip install -e .
```
Danach stehen die Befehle `crdb-convert` und `crdb-inspect` direkt im PATH zur Verfügung.

Variante B: Installation systemweit via pipx (sauber, isoliert)
- Voraussetzung: `pipx` installieren (`pip install pipx` und `pipx ensurepath`).
```bash
pipx install .
```
Nun können Sie die Tools global nutzen: `crdb-convert --help`.

Variante C: Ohne Build, direkt per Python ausführen (ohne Installation)
```bash
python3 convert_crdb_to_zoho.py --source source --dest converted
```

Optional: Standalone-Binary bauen (ohne Python auf Zielsystem)
- PyInstaller installieren und Binary erstellen:
```bash
pip install pyinstaller
pyinstaller --onefile --name crdb-convert convert_crdb_to_zoho.py
pyinstaller --onefile --name crdb-inspect _inspect_xls.py
```
Die erzeugten Binärdateien finden Sie unter `dist/` (`crdb-convert`, `crdb-inspect`). Diese sind pro OS/Arch spezifisch.

Nach Installation/Build:
- Hilfe anzeigen: `crdb-convert --help`
- Beispiele siehe "Usage" und "CLI options".

### PATH einrichten (damit `crdb-convert` überall läuft)

- Virtuelle Umgebung (empfohlen): Durch Aktivieren der venv wird deren `Scripts` (Windows) bzw. `bin` (Linux/macOS) automatisch dem PATH hinzugefügt.
  - Windows (PowerShell): `\.venv\Scripts\Activate.ps1`
  - Linux/macOS (bash/zsh): `source .venv/bin/activate`

- pipx (global, isoliert): Führen Sie einmal `pipx ensurepath` aus und starten Sie Ihr Terminal neu.
  - Prüfen: `which crdb-convert` (Linux/macOS) bzw. `where crdb-convert` (Windows)

- pip --user (falls verwendet): Stellen Sie sicher, dass das Benutzer-Bin-Verzeichnis im PATH ist.
  - Linux/macOS: `~/.local/bin` (ggf. in `~/.bashrc`/`~/.zshrc` ergänzen)
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```
  - Windows: Ermitteln Sie die User-Base: `py -m site --user-base` bzw. `python -m site --user-base`.
    Fügen Sie den `Scripts`-Unterordner dieser Base dem PATH hinzu (z. B. `%USERPROFILE%\AppData\Roaming\Python\Python311\Scripts`).

- PyInstaller-Binaries: Legen Sie die erzeugten Dateien aus `dist/` in ein Verzeichnis, das bereits im PATH liegt, oder ergänzen Sie PATH entsprechend.
  - Linux/macOS (temporär für aktuelle Session):
    ```bash
    export PATH="$(pwd)/dist:$PATH"
    ```
  - Linux/macOS (dauerhaft): in `~/.bashrc`/`~/.zshrc` analog ergänzen.
  - Windows (PowerShell, dauerhaft): Systemsteuerung → Umgebungsvariablen → PATH → `...\dist` hinzufügen. Alternativ (mit Vorsicht):
    ```powershell
    setx PATH "$env:PATH;$(Get-Location)\dist"
    ```

### CLI options
All flags are optional; defaults are chosen to work out-of-the-box with typical CRDB exports.

- `-i, --input PATH`: Einzeldatei-Eingabe (XLS/XLSX).
- `-o, --output PATH`: Ausgabedatei (CSV) in Einzeldatei-Modus. Standard: `<dest>/<input_stem>.csv`.
- `--source PATH`: Quellverzeichnis für Batch-Modus. Standard: `source/`.
- `--dest PATH`: Ausgabeverzeichnis für Batch-Modus. Standard: `converted/`.
- `--log PATH`: Pfad zur Logdatei. Standard: `<dest>/conversion.log`.
- `--force`: Existierende Ziel-CSV überschreiben.

- `--strict`: Abbruch bei Parsing-/Validierungswarnungen.
- `--dry-run`: Nur validieren und berichten, keine CSV schreiben.
- `--delimiter ";"`: CSV-Separator (Standard `;`).
- `--max-scan-rows 500`: Max. Zeilen für Headersuche.
- `--engine auto|xlrd|openpyxl`: Excel-Engine. Standard: `auto`.
- `--trace`: Detailliertes DEBUG-Tracing in Logs aktivieren.
- `--trace-max-rows 20`: Anzahl getracter Zeilen.

Mapping (Spaltenzuordnung):
- `--map-file PATH`: JSON mit Mapping-Konfiguration (siehe unten).
- `--map-posting STR`: Override für Buchungsdatum-Spalte.
- `--map-details STR`: Override für Details/Narration-Spalte.
- `--map-debit STR`: Override für Debit-Spalte.
- `--map-credit STR`: Override für Credit-Spalte.

Diagnose-Reports:
- `--report PATH`: Per-Row-Diagnose-CSV im Einzeldatei-Modus.
- `--report-dir PATH`: Verzeichnis für Per-Row-Diagnose-CSV je Datei im Batch-Modus (Dateiname: `<stem>.report.csv`).

Hinweise:
- Unterstützt `.xls` und `.xlsx`. Für `.xlsx` wird `openpyxl` verwendet.
- Logdatei wird standardmäßig unter `<dest>/conversion.log` geschrieben.

### Target format (CSV)
Semicolon-separated (;) with this header:
```
Date;Withdrawals;Deposits;Payee;Description;Reference Number
```

Notes:
- Dates are output as `YYYY-MM-DD`.
- Amounts are decimals with a dot (e.g., `212.40`).
- `Payee` remains empty, `Description` defaults to `Transfer`, `Reference Number` contains the CRDB details/narration.

### Mapping configuration
Mapping kann die Auswahl der Eingabespalten steuern. Beispiel `mapping.json`:
```json
{
  "posting_date": ["Posting Date", "Transaction Date"],
  "details": ["Details", "Narration", "Description"],
  "debit": ["Debit", "Withdrawal"],
  "credit": ["Credit", "Deposit"]
}
```

Anmerkungen:
- Werte können String oder Liste sein. Die Suche vergleicht case-insensitive, zuerst exakt, dann als Teilstring. Fallback-Heuristik bleibt aktiv.
- CLI-Overrides (`--map-*`) haben Vorrang vor der Datei.

### Diagnostics und Validierung
Der Konverter sammelt Validierungs- und Parsing-Warnungen und protokolliert Beispiele. Bei `--strict` wird mit Fehler abgebrochen.

Mögliche Issues je Zeile (wichtig für den Report):
- `date_unparsed`: Datum konnte nicht geparst werden.
- `debit_unparsed`, `credit_unparsed`: Beträge nicht interpretierbar, obwohl Ziffern vorhanden.
- `both_amounts`: Debit und Credit gleichzeitig > 0.
- `negative_debit`, `negative_credit`: Negative Beträge erkannt.
- `date_missing_with_amount`: Betrag vorhanden, aber Datum leer.

Per-Row-Diagnose kann optional als CSV erzeugt werden (`--report`/`--report-dir`).

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
