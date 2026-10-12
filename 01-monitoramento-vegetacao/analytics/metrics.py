import pandas as pd

from .queries import (
    obter_serie_anual,
    obter_anomalias,
    obter_hotspots,
)


def obter_indicadores_atuais():
    """
    Retorna os principais indicadores do último período disponível
    para cada índice.
    """
    df = obter_anomalias()

    df["data"] = pd.to_datetime(df["data"])

    ultima_data = df["data"].max()

    atual = (
        df[df["data"] == ultima_data]
        .copy()
        .sort_values("indice")
    )

    return atual[
        [
            "indice",
            "data",
            "media",
            "media_sazonal",
            "anomalia",
            "z_score",
            "classificacao",
        ]
    ].reset_index(drop=True)


def calcular_diferenca_historica():
    """
    Calcula a diferença entre a média anual e a média histórica
    de cada índice.

    A média histórica é calculada sobre os anos disponíveis.
    """
    df = obter_serie_anual()

    historico = (
        df.groupby("indice", as_index=False)["media"]
        .mean()
        .rename(columns={"media": "media_historica"})
    )

    resultado = df.merge(
        historico,
        on="indice",
        how="left"
    )

    resultado["diferenca_historica"] = (
        resultado["media"] - resultado["media_historica"]
    )

    resultado["variacao_percentual"] = (
        resultado["diferenca_historica"]
        / resultado["media_historica"]
        * 100
    )

    return resultado


def obter_eventos_anomalos():
    """
    Conta os eventos classificados como diferentes do comportamento normal
    para cada índice.
    """
    df = obter_anomalias()

    eventos = (
        df.assign(
            evento_anomalo=~df["classificacao"].eq("Normal")
        )
        .groupby("indice", as_index=False)
        .agg(
            total_periodos=("data", "count"),
            eventos_anomalos=("evento_anomalo", "sum"),
        )
    )

    eventos["percentual_eventos_anomalos"] = (
        eventos["eventos_anomalos"]
        / eventos["total_periodos"]
        * 100
    )

    return eventos


def obter_area_hotspots():
    """
    Resume a área dos hotspots por índice e tipo de anomalia.
    """
    df = obter_hotspots()

    resultado = (
        df.groupby(
            ["indice", "tipo"],
            as_index=False
        )["area_ha"]
        .sum()
    )

    return resultado


def obter_resumo_hotspots():
    """
    Retorna a área positiva, negativa e total de hotspots
    para cada índice.
    """
    df = obter_hotspots()

    resumo = (
        df.pivot_table(
            index="indice",
            columns="tipo",
            values="area_ha",
            aggfunc="sum",
            fill_value=0,
        )
        .reset_index()
    )

    resumo.columns.name = None

    if "negativa" not in resumo.columns:
        resumo["negativa"] = 0

    if "positiva" not in resumo.columns:
        resumo["positiva"] = 0

    resumo["area_total_hotspots"] = (
        resumo["negativa"] + resumo["positiva"]
    )

    return resumo
