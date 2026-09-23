# 🌱 Monitoramento de Vegetação

> **Sensoriamento Remoto · GIS · Data Analytics**

Fluxo analítico para monitoramento da condição e dinâmica da vegetação utilizando dados Sentinel-2, índices espectrais, análise temporal e espacial.

---

## 🎯 Objetivo

> Transformar dados de Sensoriamento Remoto em **indicadores, análises e visualizações** para acompanhamento da vegetação ao longo do tempo.

---

## 📊 Análises

| Indicadores   | Análises         |
| ------------- | ---------------- |
| **NDVI**      | Séries temporais |
| **NDMI**      | Sazonalidade     |
| **EVI**       | Correlação       |
| **Anomalias** | Análise espacial |
| **Hotspots**  | Estatísticas     |

---

## 🛠️ Tecnologias

`Python` · `Sentinel-2` · `GeoPandas` · `Rasterio` · `Pandas`
`DuckDB` · `Parquet` · `QGIS` · `PostGIS` · `GeoServer`
`Plotly` · `Dash` · `WebGIS`

---

## 🔄 Fluxo

```text
Sentinel-2
    ↓
Processamento
    ↓
Índices de vegetação
    ↓
Análise temporal + espacial
    ↓
Anomalias
    ↓
DuckDB + Parquet
    ↓
Dashboard + WebGIS
```

---

## 📁 Estrutura

```text
data/          Dados e resultados processados
notebooks/     Análises e processamento
analytics/     Consultas e métricas
dashboard/     Visualização interativa
gis/           QGIS · PostGIS · GeoServer
results/       Figures · Maps · Tables
```

---

## 📌 Status

**Em desenvolvimento**

**✓** Processamento
**✓** Índices de vegetação
**✓** Análises temporal e espacial
**✓** Anomalias
**✓** Estruturação em Parquet + DuckDB
**→** Dashboard
**→** WebGIS
