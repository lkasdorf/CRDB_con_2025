import pandas as pd
from pathlib import Path
from pprint import pprint


def main() -> None:
    source_path = Path("files/crdb_input.xls")
    print(f"Exists: {source_path.exists()}  Size: {source_path.stat().st_size if source_path.exists() else 'n/a'}")

    # Read without header to scan for the real header row inside the sheet
    xl = pd.read_excel(source_path, engine="xlrd", header=None, dtype=str)
    print("Shape:", xl.shape)

    # Heuristics: look for typical header combinations
    candidate_indices: list[int] = []
    header_rows: list[list[str]] = []
    keywords_sets = [
        {"date", "withdrawals", "deposits"},
        {"date", "debit", "credit"},
        {"transaction date", "debit", "credit"},
    ]

    max_scan_rows = min(500, len(xl))
    for i in range(max_scan_rows):
        row = xl.iloc[i].fillna("").astype(str).str.strip()
        lowered = {cell.lower() for cell in row if cell}
        if any(ks.issubset(lowered) for ks in keywords_sets) or (
            ("date" in lowered) and ("details" in lowered or "description" in lowered or "narration" in lowered)
        ):
            candidate_indices.append(i)
            header_rows.append(list(row))

    print("Candidate header rows:", candidate_indices)
    if candidate_indices:
        idx = candidate_indices[0]
        header = header_rows[0]
        print("Chosen header idx:", idx)
        pprint(header)

        df = xl.iloc[idx + 1 :].copy()
        # Pad extra columns to avoid length mismatch
        if len(df.columns) > len(header):
            header = header + [f"extra_{j}" for j in range(len(df.columns) - len(header))]
        df.columns = header

        # Show a small sample under the header
        with pd.option_context("display.max_colwidth", 200):
            print("First 15 rows under header:")
            print(df.head(15).to_string(index=False))
    else:
        print("No header candidates found; showing rows 0..60:")
        with pd.option_context("display.max_colwidth", 200):
            print(xl.iloc[:60].to_string(index=False, header=False))


if __name__ == "__main__":
    main()


