from pathlib import Path
import duckdb


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PARQUET_DIR = PROJECT_ROOT / "data" / "processed" / "parquet"


def get_connection():
    """
    Cria uma conexão DuckDB para o projeto.
    """
    return duckdb.connect()


def parquet_path(filename):
    """
    Retorna o caminho de um arquivo Parquet.
    """
    path = PARQUET_DIR / filename

    if not path.exists():
        raise FileNotFoundError(
            f"Arquivo Parquet não encontrado: {path}"
        )

    return path


def read_parquet(filename):
    """
    Carrega um arquivo Parquet como DataFrame.
    """
    con = get_connection()
    path = parquet_path(filename)

    try:
        return con.execute(
            "SELECT * FROM read_parquet(?)",
            [str(path)]
        ).fetchdf()
    finally:
        con.close()
