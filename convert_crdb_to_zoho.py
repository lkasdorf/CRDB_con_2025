import argparse
from pathlib import Path
import pandas as pd
from typing import List


def find_transaction_header_index(raw_df: pd.DataFrame) -> int | None:
    max_scan_rows = min(500, len(raw_df))
    for i in range(max_scan_rows):
        row_values = raw_df.iloc[i].fillna("").astype(str).str.strip()
        lowered = [v.lower() for v in row_values]

        def contains(token: str) -> bool:
            return any(token in cell for cell in lowered)

        if contains("posting") and contains("date") and contains("details") and contains("value") and contains("debit") and contains("credit"):
            return i
        if contains("posting date") and contains("details") and contains("value date") and contains("debit") and contains("credit"):
            return i
    return None


def normalize_header(cells: List[str]) -> List[str]:
    normalized = []
    for c in cells:
        name = (c or "").strip()
        name = " ".join(name.split())
        normalized.append(name)
    return normalized


def parse_number(value: str) -> float:
    if value is None:
        return 0.0
    s = str(value).strip()
    if not s:
        return 0.0
    s = s.replace("\xa0", " ").replace(" ", "")
    s = s.replace(",", "")
    s = s.replace("USD", "")
    try:
        return float(s)
    except ValueError:
        return 0.0


def parse_date_str(date_str: str) -> str:
    if not isinstance(date_str, str):
        date_str = str(date_str)
    date_str = date_str.strip()
    if not date_str:
        return ""
    dt = pd.to_datetime(date_str, dayfirst=True, errors="coerce")
    if pd.isna(dt):
        return ""
    return dt.strftime("%Y-%m-%d")


def convert(input_path: Path, output_path: Path) -> None:
    raw = pd.read_excel(input_path, engine="xlrd", header=None, dtype=str)

    header_idx = find_transaction_header_index(raw)
    if header_idx is None:
        raise RuntimeError("Konnte die Header-Zeile der Transaktionen nicht finden.")

    headers = normalize_header(raw.iloc[header_idx].tolist())
    data = raw.iloc[header_idx + 1 :].copy()
    if len(data.columns) > len(headers):
        headers = headers + [f"extra_{j}" for j in range(len(data.columns) - len(headers))]
    data.columns = headers

    def pick(col_name: str) -> str:
        for c in data.columns:
            lc = c.lower()
            if col_name == "posting_date" and "posting" in lc and "date" in lc:
                return c
            if col_name == "details" and "details" in lc:
                return c
            if col_name == "value_date" and "value" in lc and "date" in lc:
                return c
            if col_name == "debit" and "debit" in lc:
                return c
            if col_name == "credit" and "credit" in lc:
                return c
            if col_name == "book_balance" and "book" in lc and "balance" in lc:
                return c
        return ""

    col_posting = pick("posting_date")
    col_details = pick("details")
    col_debit = pick("debit")
    col_credit = pick("credit")

    if not all([col_posting, col_details, col_debit, col_credit]):
        raise RuntimeError(
            f"Fehlende Pflichtspalten: posting={col_posting!r} details={col_details!r} debit={col_debit!r} credit={col_credit!r}"
        )

    df = pd.DataFrame({
        "Date": [parse_date_str(x) for x in data[col_posting].fillna("").tolist()],
        "Withdrawals": [parse_number(x) for x in data[col_debit].fillna("").tolist()],
        "Deposits": [parse_number(x) for x in data[col_credit].fillna("").tolist()],
        "Payee": ["" for _ in range(len(data))],
        "Description": ["Transfer" for _ in range(len(data))],
        "Reference Number": data[col_details].fillna("").astype(str).tolist(),
    })

    df = df[(df["Date"] != "") & ((df["Withdrawals"] > 0) | (df["Deposits"] > 0) | (df["Reference Number"] != ""))]
    df.to_csv(output_path, sep=";", index=False)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert CRDB XLS statement to Zoho Books CSV format")
    parser.add_argument("-i", "--input", type=Path, default=Path("files/crdb_input.xls"))
    parser.add_argument("-o", "--output", type=Path, default=Path("files/zoho_converted.csv"))
    args = parser.parse_args()

    convert(args.input, args.output)
    print(f"Wrote: {args.output}")


if __name__ == "__main__":
    main()


