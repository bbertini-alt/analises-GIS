# ============================================================
# dashboard/app.py
# ============================================================
# Aplicação Dash do dashboard.
#
# Responsabilidade:
#     1 — Carregar dados via analytics.dashboard_data
#     2 — Montar o layout usando components + charts
#     3 — Criar a instância dash.Dash
#     4 — Rodar o servidor quando executado diretamente
# ============================================================

import sys
from pathlib import Path

import dash
from dash import html


# ============================================================
# 1 — GARANTIR IMPORT DO PACOTE analytics
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


# ============================================================
# 2 — IMPORTS INTERNOS
# ============================================================

from analytics.dashboard_data import carregar_dados_dashboard

from .theme import (
    CORES_BASE,
    TIPOGRAFIA,
    LAYOUT,
    TITULO_APP,
    SUBTITULO_APP,
    TITULOS_SECOES,
)

from .components import (
    criar_titulo_secao,
    criar_secao,
    criar_linha_cards,
    criar_duas_colunas,
    criar_card_indicador,
    criar_card_anomalia,
    criar_card_hotspot,
    criar_tabela_estatisticas_espaciais,
    obter_indicador,
)

from .charts import (
    criar_grafico_serie,
    criar_grafico_anual,
    criar_grafico_sazonalidade,
    criar_grafico_anomalia,
    criar_grafico_zscore,
    criar_grafico_classificacao,
    criar_grafico_hotspots,
    criar_grafico_diferenca_historica,
)


# ============================================================
# 3 — DADOS
# ============================================================

dados = carregar_dados_dashboard()

indicadores = dados["indicadores_atuais"]
eventos = dados["eventos_anomalos"]
serie_anual = dados["serie_anual"]
serie = dados["serie_intraanual"]
anomalias = dados["anomalias"]
sazonalidade = dados["sazonalidade"]
hotspots = dados["hotspots"]
resumo_hotspots = dados["resumo_hotspots"]
estatisticas = dados["estatisticas_espaciais"]
diferenca_historica = dados["diferenca_historica"]


# ============================================================
# 4 — MONTAGEM DO LAYOUT
# ============================================================

def montar_layout():

    ndvi = obter_indicador(indicadores, "NDVI")
    evi = obter_indicador(indicadores, "EVI")
    ndmi = obter_indicador(indicadores, "NDMI")

    return html.Div(
        [

            # --------------------------------------------------
            # Cabeçalho
            # --------------------------------------------------

            html.Div(
                [
                    html.H1(TITULO_APP, style={
                        "margin": "0",
                        "fontSize": TIPOGRAFIA["titulo_principal"],
                        "color": CORES_BASE["texto"],
                    }),
                    html.P(SUBTITULO_APP, style={
                        "margin": "5px 0 0 0",
                        "fontSize": TIPOGRAFIA["texto"],
                        "color": CORES_BASE["texto_leve"],
                    }),
                ],
                style={"marginBottom": LAYOUT["margin_secao"]},
            ),

            # --------------------------------------------------
            # Visão geral
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["visao_geral"],
                    "Situação mais recente dos indicadores de vegetação.",
                ),
                criar_linha_cards([
                    criar_card_indicador(indicadores, "NDVI", ndvi),
                    criar_card_indicador(indicadores, "EVI", evi),
                    criar_card_indicador(indicadores, "NDMI", ndmi),
                ]),
            ]),

            # --------------------------------------------------
            # Eventos anômalos
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    "Eventos anômalos",
                    "Percentual de períodos classificados como anômalos.",
                ),
                criar_linha_cards([
                    criar_card_anomalia(eventos, "NDVI"),
                    criar_card_anomalia(eventos, "EVI"),
                    criar_card_anomalia(eventos, "NDMI"),
                ]),
            ]),

            # --------------------------------------------------
            # Evolução temporal
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["evolucao"],
                    "Série temporal das médias dos índices.",
                ),
                criar_grafico_serie(serie),
                html.Div(style={"height": "20px"}),
                criar_grafico_anual(serie_anual),
            ]),

            # --------------------------------------------------
            # Sazonalidade
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["sazonalidade"],
                    "Comportamento médio dos índices ao longo dos meses.",
                ),
                criar_grafico_sazonalidade(sazonalidade),
            ]),

            # --------------------------------------------------
            # Anomalias
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["anomalias"],
                    "Desvios em relação ao comportamento sazonal.",
                ),
                criar_grafico_anomalia(anomalias),
                html.Div(style={"height": "20px"}),
                criar_duas_colunas(
                    criar_grafico_zscore(anomalias),
                    criar_grafico_classificacao(anomalias),
                ),
            ]),

            # --------------------------------------------------
            # Hotspots
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["hotspots"],
                    "Área identificada como hotspot positivo ou negativo.",
                ),
                criar_linha_cards([
                    criar_card_hotspot(resumo_hotspots, "NDVI"),
                    criar_card_hotspot(resumo_hotspots, "EVI"),
                    criar_card_hotspot(resumo_hotspots, "NDMI"),
                ]),
                html.Div(style={"height": "20px"}),
                criar_grafico_hotspots(hotspots),
            ]),

            # --------------------------------------------------
            # Comparação histórica
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["historico"],
                    "Diferença das médias anuais em relação à média histórica.",
                ),
                criar_grafico_diferenca_historica(diferenca_historica),
            ]),

            # --------------------------------------------------
            # Análise espacial
            # --------------------------------------------------

            criar_secao([
                criar_titulo_secao(
                    TITULOS_SECOES["espacial"],
                    "Estatísticas descritivas da distribuição espacial.",
                ),
                criar_tabela_estatisticas_espaciais(estatisticas),
            ]),

        ],

        style={
            "maxWidth": LAYOUT["largura_max"],
            "margin": "0 auto",
            "padding": LAYOUT["padding_app"],
            "fontFamily": TIPOGRAFIA["familia"],
            "backgroundColor": CORES_BASE["fundo"],
            "minHeight": "100vh",
            "boxSizing": "border-box",
        },
    )


# ============================================================
# 5 — INSTÂNCIA DASH
# ============================================================

app = dash.Dash(__name__, title=TITULO_APP)

app.layout = montar_layout()


# ============================================================
# 6 — EXECUÇÃO DIRETA
# ============================================================

if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=8050,
        debug=False,
    )