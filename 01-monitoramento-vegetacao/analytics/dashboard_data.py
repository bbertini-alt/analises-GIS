from .metrics import (
    obter_indicadores_atuais,
    calcular_diferenca_historica,
    obter_eventos_anomalos,
    obter_area_hotspots,
    obter_resumo_hotspots,
)

from .queries import (
    obter_serie_anual,
    obter_serie_intraanual,
    obter_anomalias,
    obter_sazonalidade,
    obter_estatisticas_espaciais,
)


def carregar_dados_dashboard():
    """
    Carrega os principais conjuntos de dados utilizados pelo dashboard.
    """

    return {
        "indicadores_atuais": obter_indicadores_atuais(),
        "serie_anual": obter_serie_anual(),
        "serie_intraanual": obter_serie_intraanual(),
        "anomalias": obter_anomalias(),
        "sazonalidade": obter_sazonalidade(),
        "hotspots": obter_area_hotspots(),
        "resumo_hotspots": obter_resumo_hotspots(),
        "eventos_anomalos": obter_eventos_anomalos(),
        "estatisticas_espaciais": obter_estatisticas_espaciais(),
        "diferenca_historica": calcular_diferenca_historica(),
    }
