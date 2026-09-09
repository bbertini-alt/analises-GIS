#  Inventário Florestal — Análise Dendrométrica e Volumétrica

Projeto de **Inventário Florestal** desenvolvido para organizar, processar e analisar dados dendrométricos, com aplicação de métodos estatísticos e modelos de estimativa de volume.

O projeto integra conceitos de **Engenharia Florestal, Estatística, Modelagem e Geoprocessamento**, utilizando **R** para automatização das análises e organização de um fluxo reprodutível.

> 📌 Este projeto faz parte do portfólio de análises GIS e florestais desenvolvido por **Bruna Bertini**.

---

##  Objetivo

Desenvolver um fluxo de análise para dados de inventário florestal, contemplando:

* organização e tratamento dos dados;
* análise dendrométrica;
* cubagem rigorosa;
* estimativa de volume;
* ajuste e comparação de modelos volumétricos;
* avaliação estatística dos modelos;
* organização de dados geoespaciais;
* geração e armazenamento de resultados de forma reprodutível.

O objetivo é demonstrar a aplicação prática de ferramentas computacionais na análise de dados florestais.

---

##  Fluxo da análise

```text
Dados de campo
      │
      ▼
┌─────────────────────┐
│ Tratamento dos dados│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Análise dendrométrica│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Cubagem rigorosa    │
│ Método de Smalian   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Modelagem volumétrica│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Avaliação estatística│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Resultados e mapas  │
└─────────────────────┘
```

---

##  Principais análises

### 1. Análise dendrométrica

São analisadas variáveis utilizadas no inventário florestal, incluindo:

* DAP — diâmetro à altura do peito;
* altura total;
* volume com casca;
* volume sem casca;
* parâmetros derivados do inventário.

Essas informações são utilizadas como base para as etapas posteriores de cubagem e modelagem.

---

### 2. Cubagem rigorosa

A determinação do volume dos fustes é realizada pelo **método de Smalian**, utilizando medições dos diâmetros ao longo do fuste.

O procedimento permite obter estimativas de volume por seção e do fuste completo, servindo como referência para o ajuste dos modelos volumétricos.

---

### 3. Modelagem volumétrica

São ajustados e comparados diferentes modelos de volume em função das variáveis dendrométricas.

Entre os modelos avaliados estão:

* **Berkhout**
* **Spurr**
* **Spurr logarítmico**
* **Schumacher & Hall**

A comparação considera medidas de qualidade do ajuste e dos resíduos, permitindo selecionar modelos com melhor desempenho para a estimativa volumétrica.

---

## 📐 Modelo de Schumacher & Hall

Um dos modelos utilizados é a forma logarítmica do modelo de **Schumacher & Hall**:

$$
\ln(V) = \beta_0 + \beta_1\ln(DAP) + \beta_2\ln(H)
$$

onde:

* \(V\) = volume;
* \(DAP\) = diâmetro à altura do peito;
* \(H\) = altura total;
* \(\beta_0, \beta_1, \beta_2\) = parâmetros estimados.

O modelo apresentou elevado poder explicativo para os dados analisados.

---

##  Avaliação dos modelos

Os modelos são comparados considerando critérios como:

* coeficiente de determinação ajustado;
* erro residual;
* análise dos resíduos;
* significância dos parâmetros;
* comportamento das estimativas;
* desempenho geral na estimativa do volume.

Essa etapa permite avaliar não apenas o ajuste estatístico, mas também a adequação do modelo ao contexto do inventário florestal.

---

## 🗺️ Dados geoespaciais

O projeto também possui uma estrutura destinada à organização de dados espaciais:

```text
geodata/
```

Esses dados podem ser utilizados para relacionar as informações do inventário com a localização das parcelas e árvores, permitindo posteriormente integrar:

* inventário florestal;
* coordenadas;
* parcelas;
* mapas temáticos;
* análise espacial;
* ferramentas GIS.

---

##  Estrutura do projeto

```text
01-inventario-florestal/
│
├── data/
│   ├── raw/              # Dados brutos
│   └── processed/        # Dados tratados
│
├── geodata/              # Dados geoespaciais
│
├── results/              # Resultados das análises
│   ├── figures/          # Gráficos e figuras
│   └── tables/           # Tabelas e resultados
│
├── scripts/              # Scripts em R
│
└── README.md             # Documentação do projeto
```

---

##  Tecnologias utilizadas

### Linguagem

* **R**

### Principais pacotes

* `dplyr`
* `ggplot2`
* `readr`
* `readxl`
* `sf`
* `terra`

### Conceitos aplicados

* Inventário Florestal
* Dendrometria
* Cubagem rigorosa
* Método de Smalian
* Modelagem volumétrica
* Regressão
* Análise de resíduos
* Estatística aplicada
* Geoprocessamento
* Análise espacial
* Reprodutibilidade científica

---

##  Reprodutibilidade

A organização do projeto segue uma estrutura de separação entre:

**dados → scripts → resultados**

Isso permite que os procedimentos sejam executados novamente a partir dos dados de entrada, reduzindo a necessidade de processamento manual e facilitando a reprodução das análises.

Os scripts utilizados no projeto estão disponíveis em:

```text
scripts/
```

Os resultados gerados são armazenados em:

```text
results/
```

---

## 📌 Principais competências demonstradas

Este projeto demonstra experiência prática em:

* 🌲 **Inventário Florestal**
* 📏 **Dendrometria**
* 📊 **Estatística aplicada**
* 📐 **Modelagem florestal**
* 🗺️ **Geoprocessamento**
* 💻 **Programação em R**
* 🔄 **Automação de análises**
* 📁 **Organização de dados**
* 📈 **Análise e visualização de resultados**
* ♻️ **Reprodutibilidade de workflows**

---

## 🚀 Possíveis extensões

O projeto pode ser ampliado para incorporar novas etapas de análise espacial, incluindo:

* mapas das parcelas do inventário;
* distribuição espacial das árvores;
* análise de estrutura horizontal e vertical;
* interpolação espacial;
* geoestatística;
* mapas de volume;
* integração com imagens de satélite;
* análise de índices de vegetação;
* integração com QGIS;
* automação de relatórios.

---

##  Autora

**Bruna Bertini**

Graduanda em Engenharia Florestal | Geoprocessamento | GIS | Sensoriamento Remoto | Análise de Dados

GitHub: [bbertini-alt](https://github.com/bbertini-alt)

---

##  Contexto

Este projeto integra o portfólio **analises-GIS**, desenvolvido para demonstrar a aplicação de ferramentas computacionais, estatísticas e geoespaciais em problemas relacionados às Ciências Florestais.

**Status:** 🚧 Em desenvolvimento
