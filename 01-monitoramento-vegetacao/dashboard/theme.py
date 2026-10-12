# ============================================================
# dashboard/theme.py
# ============================================================
# Sistema visual central do dashboard.
#
# Responsabilidade única: definir cores, tipografia, tokens
# de layout e constantes visuais. Nenhum cálculo, nenhum
# componente, nenhum gráfico.
# ============================================================


# ============================================================
# 1 — PALETA DOS ÍNDICES
# ============================================================

CORES_INDICE = {
    "NDVI": "#2E7D32",
    "EVI":  "#F9A825",
    "NDMI": "#1565C0",
}


# ============================================================
# 2 — PALETA DE HOTSPOTS
# ============================================================

CORES_HOTSPOT = {
    "Negativo": "#C62828",
    "Positivo": "#2E7D32",
    "negativa": "#C62828",
    "positiva": "#2E7D32",
}


# ============================================================
# 3 — CLASSIFICAÇÃO DAS ANOMALIAS
# ============================================================

CORES_CLASSIFICACAO = {
    "Muito abaixo": "#B71C1C",
    "Abaixo":       "#EF6C00",
    "Normal":       "#2E7D32",
    "Acima":        "#1565C0",
    "Muito acima":  "#6A1B9A",
}


# ============================================================
# 4 — CORES NEUTRAS
# ============================================================

CORES_BASE = {
    "fundo": "#F5F5F5",
    "card": "#FFFFFF",
    "borda": "#DDDDDD",

    "texto": "#212121",
    "texto_secundario": "#424242",
    "texto_leve": "#666666",
    "texto_muito_leve": "#888888",

    "fundo_secundario": "#EEEEEE",
    "fundo_hover": "#F0F0F0",

    "linha": "#E0E0E0",
    "branco": "#FFFFFF",
    "preto": "#000000",
}


# ============================================================
# 5 — CORES DE ESTADO
# ============================================================

CORES_ESTADO = {
    "sucesso": "#2E7D32",
    "atencao": "#EF6C00",
    "erro": "#C62828",
    "informacao": "#1565C0",
}


# ============================================================
# 6 — TIPOGRAFIA
# ============================================================

TIPOGRAFIA = {
    "familia": "Arial, sans-serif",

    "titulo_principal": "28px",
    "titulo_secao": "22px",
    "titulo_subsecao": "18px",

    "kpi": "32px",
    "kpi_secundario": "28px",

    "texto": "14px",
    "texto_pequeno": "12px",
    "legenda": "11px",
}


# ============================================================
# 7 — TOKENS DE LAYOUT
# ============================================================

LAYOUT = {
    "largura_max": "1200px",
    "padding_app": "30px",

    "gap_cards": "20px",
    "gap_elementos": "15px",
    "gap_pequeno": "8px",

    "padding_card": "20px",
    "radius_card": "10px",
    "borda_card": "1px",

    "margin_secao": "35px",
    "margin_subsecao": "25px",

    "altura_grafico": 450,
}


# ============================================================
# 8 — ESTILO DOS CARDS
# ============================================================

ESTILO_CARD = {
    "padding": LAYOUT["padding_card"],
    "border": f"{LAYOUT['borda_card']} solid {CORES_BASE['borda']}",
    "borderRadius": LAYOUT["radius_card"],
    "backgroundColor": CORES_BASE["card"],
    "boxSizing": "border-box",
}


# ============================================================
# 9 — PADRÃO VISUAL DOS GRÁFICOS
# ============================================================

TEMPLATE_PLOTLY = "plotly_white"

CONFIG_GRAFICO = {
    "displayModeBar": False,
    "responsive": True,
}

LAYOUT_GRAFICO = {
    "template": TEMPLATE_PLOTLY,
    "margin": {"l": 50, "r": 30, "t": 70, "b": 50},
    "paper_bgcolor": CORES_BASE["card"],
    "plot_bgcolor": CORES_BASE["card"],
    "font": {
        "family": TIPOGRAFIA["familia"],
        "size": 12,
        "color": CORES_BASE["texto"],
    },
    "legend": {"title": {"text": ""}},
}


# ============================================================
# 10 — MESES
# ============================================================

MESES_ABREVIADOS = {
    1: "Jan", 2: "Fev", 3: "Mar",
    4: "Abr", 5: "Mai", 6: "Jun",
    7: "Jul", 8: "Ago", 9: "Set",
    10: "Out", 11: "Nov", 12: "Dez",
}


# ============================================================
# 11 — TÍTULOS
# ============================================================

TITULO_APP = "Monitoramento de Vegetação"

SUBTITULO_APP = "Dashboard analítico de monitoramento da vegetação"

TITULOS_SECOES = {
    "visao_geral": "Visão geral",
    "evolucao": "Evolução temporal",
    "sazonalidade": "Sazonalidade",
    "anomalias": "Anomalias",
    "hotspots": "Hotspots",
    "historico": "Comparação histórica",
    "espacial": "Análise espacial",
}