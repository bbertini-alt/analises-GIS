# ============================================================
# dashboard/charts.py
# ============================================================
# Visualizações Plotly do dashboard.
#
#     1 — Funções base (layout e conversão)
#     2 — Evolução temporal
#     3 — Evolução anual
#     4 — Sazonalidade
#     5 — Anomalia
#     6 — Z-score
#     7 — Classificação das anomalias
#     8 — Hotspots
#     9 — Diferença histórica
# ============================================================

from dash import html, dcc
import plotly.express as px

from .theme import (
    CORES_INDICE,
    CORES_HOTSPOT,
    CORES_CLASSIFICACAO,
    CORES_BASE,
    CORES_ESTADO,
    LAYOUT,
    LAYOUT_GRAFICO,
    CONFIG_GRAFICO,
    MESES_ABREVIADOS,
)


# ============================================================
# 1 — FUNÇÕES BASE
# ============================================================

def aplicar_layout_grafico(fig, hovermode="x unified"):
    fig.update_layout(
        template=LAYOUT_GRAFICO["template"],
        margin=LAYOUT_GRAFICO["margin"],
        paper_bgcolor=LAYOUT_GRAFICO["paper_bgcolor"],
        plot_bgcolor=LAYOUT_GRAFICO["plot_bgcolor"],
        font=LAYOUT_GRAFICO["font"],
        hovermode=hovermode,
    )
    return fig


def criar_graph(fig):
    return dcc.Graph(
        figure=fig,
        config=CONFIG_GRAFICO,
        style={"height": f"{LAYOUT['altura_grafico']}px"},
    )


def _vazio(msg):
    return html.Div(msg, style={
        "padding": "30px",
        "textAlign": "center",
        "color": CORES_BASE["texto_leve"],
    })


# ============================================================
# 2 — EVOLUÇÃO TEMPORAL
# ============================================================

def criar_grafico_serie(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados disponíveis para os filtros selecionados.")

    fig = px.line(
        dados, x="data", y="media",
        color="indice",
        color_discrete_map=CORES_INDICE,
        markers=True,
        title="Evolução temporal dos indicadores",
        labels={"data": "Data", "media": "Média", "indice": "Índice"},
    )

    fig.update_traces(line={"width": 2}, marker={"size": 5})
    fig.update_xaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig)
    return criar_graph(fig)


# ============================================================
# 3 — EVOLUÇÃO ANUAL
# ============================================================

def criar_grafico_anual(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados anuais disponíveis.")

    fig = px.line(
        dados, x="ano", y="media",
        color="indice",
        color_discrete_map=CORES_INDICE,
        markers=True,
        title="Evolução anual dos indicadores",
        labels={"ano": "Ano", "media": "Média anual", "indice": "Índice"},
    )

    fig.update_traces(line={"width": 2.5}, marker={"size": 7})
    fig.update_xaxes(dtick=1, showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig)
    return criar_graph(fig)


# ============================================================
# 4 — SAZONALIDADE
# ============================================================

def criar_grafico_sazonalidade(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados de sazonalidade disponíveis.")

    fig = px.bar(
        dados, x="mes", y="media",
        color="indice",
        color_discrete_map=CORES_INDICE,
        barmode="group",
        title="Sazonalidade dos indicadores",
        labels={"mes": "Mês", "media": "Média", "indice": "Índice"},
    )

    fig.update_xaxes(
        tickmode="array",
        tickvals=list(MESES_ABREVIADOS.keys()),
        ticktext=list(MESES_ABREVIADOS.values()),
        showgrid=False,
    )
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig, hovermode="closest")
    return criar_graph(fig)


# ============================================================
# 5 — ANOMALIA
# ============================================================

def criar_grafico_anomalia(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados de anomalia disponíveis.")

    fig = px.line(
        dados, x="data", y="anomalia",
        color="indice",
        color_discrete_map=CORES_INDICE,
        markers=True,
        title="Anomalia em relação ao comportamento sazonal",
        labels={"data": "Data", "anomalia": "Anomalia", "indice": "Índice"},
    )

    fig.update_traces(line={"width": 2}, marker={"size": 5})

    fig.add_hline(
        y=0, line_dash="dash", line_color=CORES_BASE["texto_leve"],
        annotation_text="Referência sazonal",
        annotation_position="top left",
    )

    fig.update_xaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig)
    return criar_graph(fig)


# ============================================================
# 6 — Z-SCORE
# ============================================================

def criar_grafico_zscore(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados de z-score disponíveis.")

    fig = px.line(
        dados, x="data", y="z_score",
        color="indice",
        color_discrete_map=CORES_INDICE,
        markers=True,
        title="Z-score das anomalias",
        labels={"data": "Data", "z_score": "Z-score", "indice": "Índice"},
    )

    fig.update_traces(line={"width": 2}, marker={"size": 5})

    fig.add_hline(y=0, line_dash="dash", line_color=CORES_BASE["texto_leve"])

    fig.add_hline(
        y=1.5, line_dash="dot",
        line_color=CORES_ESTADO["informacao"],
        annotation_text="+1,5", annotation_position="top left",
    )

    fig.add_hline(
        y=-1.5, line_dash="dot",
        line_color=CORES_ESTADO["atencao"],
        annotation_text="-1,5", annotation_position="bottom left",
    )

    fig.update_xaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig)
    return criar_graph(fig)


# ============================================================
# 7 — CLASSIFICAÇÃO DAS ANOMALIAS
# ============================================================

def criar_grafico_classificacao(dados):
    if dados is None or dados.empty:
        return _vazio("Não há classificações disponíveis.")

    contagem = (
        dados.groupby(["indice", "classificacao"], as_index=False)
        .size()
        .rename(columns={"size": "periodos"})
    )

    fig = px.bar(
        contagem, x="indice", y="periodos",
        color="classificacao",
        color_discrete_map=CORES_CLASSIFICACAO,
        barmode="stack",
        title="Classificação dos períodos",
        labels={
            "indice": "Índice",
            "periodos": "Número de períodos",
            "classificacao": "Classificação",
        },
        text="periodos",
    )

    fig.update_traces(textposition="inside", texttemplate="%{text}")
    fig.update_xaxes(showgrid=False)
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Classificação")

    aplicar_layout_grafico(fig, hovermode="closest")
    return criar_graph(fig)


# ============================================================
# 8 — HOTSPOTS
# ============================================================

def criar_grafico_hotspots(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados de hotspots disponíveis.")

    fig = px.bar(
        dados, x="indice", y="area_ha",
        color="tipo",
        color_discrete_map=CORES_HOTSPOT,
        barmode="stack",
        title="Área de hotspots",
        labels={"indice": "Índice", "area_ha": "Área (ha)", "tipo": "Tipo"},
        text="area_ha",
    )

    fig.update_traces(texttemplate="%{text:.2f} ha", textposition="inside")
    fig.update_xaxes(showgrid=False)
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"],
                     title="Área (ha)")
    fig.update_layout(legend_title_text="Tipo")

    aplicar_layout_grafico(fig, hovermode="closest")
    return criar_graph(fig)


# ============================================================
# 9 — DIFERENÇA HISTÓRICA
# ============================================================

def criar_grafico_diferenca_historica(dados):
    if dados is None or dados.empty:
        return _vazio("Não há dados de comparação histórica disponíveis.")

    fig = px.bar(
        dados, x="ano", y="diferenca_historica",
        color="indice",
        color_discrete_map=CORES_INDICE,
        barmode="group",
        title="Diferença em relação à média histórica",
        labels={
            "ano": "Ano",
            "diferenca_historica": "Diferença",
            "indice": "Índice",
        },
    )

    fig.add_hline(
        y=0, line_dash="dash", line_color=CORES_BASE["texto_leve"],
        annotation_text="Média histórica",
        annotation_position="top left",
    )

    fig.update_xaxes(dtick=1, showgrid=False)
    fig.update_yaxes(showgrid=True, gridcolor=CORES_BASE["linha"])
    fig.update_layout(legend_title_text="Índice")

    aplicar_layout_grafico(fig, hovermode="closest")
    return criar_graph(fig)