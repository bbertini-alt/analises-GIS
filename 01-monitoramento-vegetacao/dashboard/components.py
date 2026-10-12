# ============================================================
# dashboard/components.py
# ============================================================
# Componentes reutilizáveis da interface:
#
#     1 — Funções de acesso aos dados
#     2 — Funções auxiliares de layout
#     3 — Cards (indicador, anomalia, hotspot)
#     4 — Tabela de estatísticas espaciais
# ============================================================

from dash import html, dash_table

from .theme import (
    CORES_INDICE,
    CORES_CLASSIFICACAO,
    CORES_HOTSPOT,
    CORES_BASE,
    TIPOGRAFIA,
    LAYOUT,
    ESTILO_CARD,
)


# ============================================================
# 1 — FUNÇÕES DE ACESSO AOS DADOS
# ============================================================

def obter_indicador(indicadores, indice):
    resultado = indicadores.loc[indicadores["indice"] == indice]
    return None if resultado.empty else resultado.iloc[0]


def obter_eventos(eventos, indice):
    resultado = eventos.loc[eventos["indice"] == indice]
    return None if resultado.empty else resultado.iloc[0]


def obter_hotspot(resumo_hotspots, indice):
    resultado = resumo_hotspots.loc[resumo_hotspots["indice"] == indice]
    return None if resultado.empty else resultado.iloc[0]


# ============================================================
# 2 — FUNÇÕES AUXILIARES DE LAYOUT
# ============================================================

def criar_titulo_secao(titulo, subtitulo=None):
    elementos = [
        html.H2(titulo, style={
            "margin": "0 0 5px 0",
            "fontSize": TIPOGRAFIA["titulo_secao"],
            "color": CORES_BASE["texto"],
        })
    ]

    if subtitulo:
        elementos.append(html.P(subtitulo, style={
            "margin": "0",
            "fontSize": TIPOGRAFIA["texto_pequeno"],
            "color": CORES_BASE["texto_leve"],
        }))

    return html.Div(elementos, style={
        "marginBottom": LAYOUT["margin_subsecao"],
    })


def criar_secao(conteudo):
    return html.Div(conteudo, style={
        "marginBottom": LAYOUT["margin_secao"],
    })


def criar_linha_cards(cards):
    return html.Div(cards, style={
        "display": "flex",
        "gap": LAYOUT["gap_cards"],
        "flexWrap": "wrap",
        "width": "100%",
    })


def criar_duas_colunas(esquerda, direita):
    estilo_coluna = {"flex": "1", "minWidth": "450px"}
    return html.Div(
        [
            html.Div(esquerda, style=estilo_coluna),
            html.Div(direita, style=estilo_coluna),
        ],
        style={
            "display": "flex",
            "gap": LAYOUT["gap_cards"],
            "flexWrap": "wrap",
            "width": "100%",
        },
    )


# ============================================================
# 3 — CARDS
# ============================================================

def criar_card_indicador(indicadores, indice, indicador=None):
    if indicador is None:
        indicador = obter_indicador(indicadores, indice)

    if indicador is None:
        return html.Div(
            [html.H3(indice), html.H2("Sem dados")],
            style={**ESTILO_CARD, "textAlign": "center",
                   "flex": "1", "minWidth": "220px"},
        )

    classificacao = str(indicador["classificacao"])

    cor_classificacao = CORES_CLASSIFICACAO.get(
        classificacao, CORES_BASE["texto_leve"]
    )

    cor_indice = CORES_INDICE.get(indice, CORES_BASE["texto"])

    media = float(indicador["media"])
    anomalia = float(indicador["anomalia"])
    z_score = float(indicador["z_score"])
    data = indicador["data"]

    return html.Div(
        [
            html.Div([
                html.H3(indice, style={
                    "margin": "0", "fontSize": "18px",
                    "fontWeight": "bold", "color": cor_indice,
                }),
                html.P("Indicador atual", style={
                    "margin": "3px 0 0 0",
                    "fontSize": TIPOGRAFIA["texto_pequeno"],
                    "color": CORES_BASE["texto_leve"],
                }),
            ], style={"marginBottom": "12px"}),

            html.H1(f"{media:.3f}", style={
                "margin": "5px 0",
                "fontSize": TIPOGRAFIA["kpi"],
                "color": CORES_BASE["texto"],
            }),

            html.P(classificacao, style={
                "margin": "5px 0 15px 0",
                "fontSize": TIPOGRAFIA["texto"],
                "fontWeight": "bold",
                "color": cor_classificacao,
            }),

            html.Hr(style={
                "border": "0",
                "borderTop": f"1px solid {CORES_BASE['linha']}",
                "margin": "10px 0",
            }),

            html.Div([
                html.Div([
                    html.Small("Anomalia", style={
                        "color": CORES_BASE["texto_leve"],
                        "display": "block",
                    }),
                    html.Strong(f"{anomalia:.3f}"),
                ], style={"flex": "1"}),

                html.Div([
                    html.Small("Z-score", style={
                        "color": CORES_BASE["texto_leve"],
                        "display": "block",
                    }),
                    html.Strong(f"{z_score:.3f}"),
                ], style={"flex": "1"}),
            ], style={
                "display": "flex",
                "gap": "15px",
                "textAlign": "center",
            }),

            html.Small(
                f"Data: {data.strftime('%d/%m/%Y')}",
                style={
                    "display": "block",
                    "marginTop": "15px",
                    "color": CORES_BASE["texto_leve"],
                },
            ),
        ],
        style={
            **ESTILO_CARD,
            "border": f"2px solid {cor_classificacao}",
            "textAlign": "center",
            "flex": "1",
            "minWidth": "220px",
        },
    )


def criar_card_anomalia(eventos, indice):
    evento = obter_eventos(eventos, indice)

    if evento is None:
        return html.Div(
            [html.H3(indice), html.H2("Sem dados")],
            style={**ESTILO_CARD, "textAlign": "center",
                   "flex": "1", "minWidth": "220px"},
        )

    percentual = float(evento["percentual_eventos_anomalos"])
    n_eventos = int(evento["eventos_anomalos"])
    n_total = int(evento["total_periodos"])

    return html.Div(
        [
            html.H3(indice, style={
                "margin": "0",
                "fontSize": "18px",
                "color": CORES_INDICE.get(indice, CORES_BASE["texto"]),
            }),

            html.H2(f"{percentual:.1f}%", style={
                "fontSize": TIPOGRAFIA["kpi_secundario"],
                "margin": "12px 0 5px 0",
                "color": CORES_BASE["texto"],
            }),

            html.P("Períodos anômalos", style={
                "margin": "0 0 15px 0",
                "fontWeight": "bold",
            }),

            html.Hr(style={
                "border": "0",
                "borderTop": f"1px solid {CORES_BASE['linha']}",
            }),

            html.P([
                html.Strong(str(n_eventos)),
                f" de {n_total} períodos",
            ], style={
                "margin": "12px 0 0 0",
                "color": CORES_BASE["texto_leve"],
            }),
        ],
        style={
            **ESTILO_CARD,
            "textAlign": "center",
            "flex": "1",
            "minWidth": "220px",
        },
    )


def criar_card_hotspot(resumo_hotspots, indice):
    hotspot = obter_hotspot(resumo_hotspots, indice)

    if hotspot is None:
        return html.Div(
            [html.H3(indice), html.H2("Sem dados")],
            style={**ESTILO_CARD, "textAlign": "center",
                   "flex": "1", "minWidth": "220px"},
        )

    negativa = float(hotspot.get("negativa", 0))
    positiva = float(hotspot.get("positiva", 0))
    total = float(hotspot.get("area_total_hotspots", 0))

    return html.Div(
        [
            html.H3(indice, style={
                "margin": "0",
                "fontSize": "18px",
                "color": CORES_INDICE.get(indice, CORES_BASE["texto"]),
            }),

            html.H2(f"{total:.2f} ha", style={
                "fontSize": TIPOGRAFIA["kpi_secundario"],
                "margin": "12px 0 5px 0",
            }),

            html.P("Área total de hotspots", style={
                "margin": "0 0 15px 0",
                "fontWeight": "bold",
            }),

            html.Hr(style={
                "border": "0",
                "borderTop": f"1px solid {CORES_BASE['linha']}",
            }),

            html.Div([
                html.Div([
                    html.Small("Negativos", style={
                        "display": "block",
                        "color": CORES_BASE["texto_leve"],
                    }),
                    html.Strong(f"{negativa:.2f} ha", style={
                        "color": CORES_HOTSPOT["Negativo"],
                    }),
                ], style={"flex": "1"}),

                html.Div([
                    html.Small("Positivos", style={
                        "display": "block",
                        "color": CORES_BASE["texto_leve"],
                    }),
                    html.Strong(f"{positiva:.2f} ha", style={
                        "color": CORES_HOTSPOT["Positivo"],
                    }),
                ], style={"flex": "1"}),
            ], style={
                "display": "flex",
                "gap": "15px",
                "textAlign": "center",
            }),
        ],
        style={
            **ESTILO_CARD,
            "textAlign": "center",
            "flex": "1",
            "minWidth": "220px",
        },
    )


# ============================================================
# 4 — TABELA DE ESTATÍSTICAS ESPACIAIS
# ============================================================

def criar_tabela_estatisticas_espaciais(dados):
    if dados is None or dados.empty:
        return html.Div("Não há estatísticas espaciais disponíveis.")

    colunas = [
        "indice", "n_validos", "n_nan",
        "minimo", "p25", "mediana", "media",
        "p75", "maximo", "desvio_padrao",
    ]

    dados_tabela = dados[
        [c for c in colunas if c in dados.columns]
    ].copy()

    dados_tabela = dados_tabela.rename(columns={
        "indice": "Índice",
        "n_validos": "Pixels válidos",
        "n_nan": "Pixels NoData",
        "minimo": "Mínimo",
        "p25": "P25",
        "mediana": "Mediana",
        "media": "Média",
        "p75": "P75",
        "maximo": "Máximo",
        "desvio_padrao": "Desvio padrão",
    })

    return dash_table.DataTable(
        data=dados_tabela.to_dict("records"),
        columns=[{"name": c, "id": c} for c in dados_tabela.columns],
        style_table={"overflowX": "auto", "width": "100%"},
        style_header={
            "backgroundColor": CORES_BASE["fundo_secundario"],
            "color": CORES_BASE["texto"],
            "fontWeight": "bold",
            "textAlign": "center",
            "border": f"1px solid {CORES_BASE['borda']}",
        },
        style_cell={
            "padding": "10px",
            "textAlign": "center",
            "fontFamily": TIPOGRAFIA["familia"],
            "fontSize": TIPOGRAFIA["texto_pequeno"],
            "border": f"1px solid {CORES_BASE['borda']}",
        },
        style_data={
            "backgroundColor": CORES_BASE["card"],
            "color": CORES_BASE["texto"],
        },
        page_size=10,
    )