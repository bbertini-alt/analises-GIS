#  Inventário Florestal 

Projeto de **Inventário Florestal** desenvolvido para organizar, processar e analisar dados dendrométricos, com aplicação de métodos estatísticos e modelos de estimativa de volume.

O projeto integra conceitos de **Engenharia Florestal, Estatística, Modelagem e Geoprocessamento**, utilizando **R** para automatização das análises e organização de um fluxo reprodutível.

> 📌 Este projeto faz parte do portfólio de análises GIS desenvolvido por **Bruna Bertini**.

---

##  Objetivo

Desenvolver um fluxo de análise para dados de inventário florestal.


---

##  Fluxo da análise

```text
Dados de campo
      │
      ▼
Tratamento dos dados
      │
      ▼
Análise dendrométrica
      │
      ▼
Cubagem rigorosa
Método de Smalian
      │
      ▼
Modelagem volumétrica
      │
      ▼
Avaliação estatística
      │
      ▼
Resultados e produtos espaciais
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

---

### 2. Cubagem rigorosa

A determinação do volume dos fustes é realizada pelo **método de Smalian**, utilizando medições dos diâmetros ao longo do fuste.

O procedimento permite obter estimativas de volume por seção e do fuste completo, servindo como referência para o ajuste dos modelos volumétricos.

---

### 3. Modelagem volumétrica

São ajustados e comparados diferentes modelos de volume em função das variáveis dendrométricas.

Modelos avaliados:

* **Berkhout**
* **Spurr**
* **Spurr logarítmico**
* **Schumacher & Hall**

A comparação considera medidas de qualidade do ajuste e análise dos resíduos.

---

##  Modelo de Schumacher & Hall

Um dos modelos utilizados é a forma logarítmica do modelo de **Schumacher & Hall**:

$$
\ln(V) = \beta_0 + \beta_1\ln(DAP) + \beta_2\ln(H)
$$

onde:

* \(V\) = volume;
* \(DAP\) = diâmetro à altura do peito;
* \(H\) = altura total;
* \(\beta_0, \beta_1, \beta_2\) = parâmetros estimados.

---

##  Integração geoespacial

Os dados do inventário podem ser relacionados à localização das parcelas e árvores, permitindo a integração entre **inventário florestal e informações espaciais**.

O projeto utiliza ferramentas do ecossistema GIS para organização e processamento dos dados geoespaciais, incluindo:

* **Google Earth Engine**
* R (`sf`, `terra`)
* dados vetoriais e raster
* análise espacial

Essa integração permite ampliar as análises para mapas temáticos, caracterização espacial da área e integração futura com dados de sensoriamento remoto.

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
├── scripts/              # Scripts de análise
│
└── README.md             # Documentação do projeto
```

---

## Tecnologias utilizadas

### Programação e análise

* **R**
* **Python**

### Geoprocessamento e GIS

* **QGIS**
* **Google Earth Engine**
* `sf`
* `terra`

### Análise de dados

* `dplyr`
* `ggplot2`
* `readr`
* `readxl`


---

## Reprodutibilidade

A organização do projeto segue uma estrutura de separação entre:

**dados → scripts → resultados**

Os scripts utilizados no projeto estão disponíveis em:

```text
scripts/
```

Os resultados gerados são armazenados em:

```text
results/
```

---


GitHub: [bbertini-alt](https://github.com/bbertini-alt)

