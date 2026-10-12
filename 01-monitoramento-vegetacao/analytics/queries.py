from .connection import get_connection, parquet_path


def obter_serie_anual():
    """
    Retorna a série anual dos índices de vegetação.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY ano, indice
        """, [str(parquet_path("serie_anual.parquet"))]).fetchdf()
    finally:
        con.close()


def obter_serie_intraanual():
    """
    Retorna a série temporal intraanual dos índices.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY data, indice
        """, [str(parquet_path("serie_intraanual.parquet"))]).fetchdf()
    finally:
        con.close()


def obter_anomalias():
    """
    Retorna as anomalias temporais dos índices.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY data, indice
        """, [str(parquet_path("anomalias.parquet"))]).fetchdf()
    finally:
        con.close()


def obter_hotspots():
    """
    Retorna os hotspots de anomalia.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY indice, tipo, id_cluster
        """, [str(parquet_path("hotspots.parquet"))]).fetchdf()
    finally:
        con.close()


def obter_sazonalidade():
    """
    Retorna os valores sazonais históricos dos índices.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY mes, indice
        """, [str(parquet_path("sazonalidade.parquet"))]).fetchdf()
    finally:
        con.close()


def obter_estatisticas_espaciais():
    """
    Retorna as estatísticas espaciais dos índices.
    """
    con = get_connection()

    try:
        return con.execute("""
            SELECT *
            FROM read_parquet(?)
            ORDER BY indice
        """, [str(parquet_path("estatisticas_espaciais.parquet"))]).fetchdf()
    finally:
        con.close()
