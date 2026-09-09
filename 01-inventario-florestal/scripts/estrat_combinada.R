# ============================================================
# 🔹 INVENTÁRIO FLORESTAL – ESTIMATIVA ESTRATIFICADA (matgen + espaçamento + plantio)
# ============================================================

# Leitura dos dados
dados <- read.csv2('fustes_final.csv')
View(dados)
names(dados)

# Variável de interesse
dados$vary <- dados$vprod_5
# Substituir 'x' por ' x ' e ajustar formato
dados$espacamento_legivel <- gsub("x", " x ", dados$espacamento)

# Trocar ponto por vírgula se quiser estilo brasileiro
dados$espacamento_legivel <- gsub("\\.", ",", dados$espacamento_legivel)

# Exemplo: 300x300 -> 300 x 300
# ou 3x2.5 -> 3 x 2,5

# ============================================================
# 🔹 Definir estratificação combinada
# ============================================================
# Criar coluna combinando matgen, espacamento_legivel e plantio
dados$estrato <- with(dados, paste(matgen, espacamento_legivel, plantio, sep = "_"))

# Conferir combinações únicas
unique(dados$estrato)

# ============================================================
# 🔹 Calcular área total por plantio (sem repetição)
# ============================================================
calc <- subset(dados, !duplicated(plantio), c("plantio", "area", "matgen", "espacamento_legivel"))
View(calc)

# ============================================================
# 🔹 Calcular área total por estrato (combinação)
# ============================================================
area_por_estrato <- aggregate(
  list(areaest = calc$area),
  list(estrato = with(calc, paste(matgen, espacamento_legivel, plantio, sep = "_"))),
  sum
)
View(area_por_estrato)

# Atribuir área de cada estrato ao conjunto de dados principal
dados <- merge(dados, area_por_estrato, by = "estrato", all.x = TRUE)
View(dados)

# ============================================================
# 🔹 Parâmetros e agregações iniciais
# ============================================================
sig <- 0.01 # alfa = 1%

# Volume somado por parcela
dados2 <- with(dados, aggregate(
  list(vary = vary),
  list(areaest = areaest, areaparc = areaparc, estrato = estrato, parcela = parcela),
  sum,
  na.rm = TRUE
))
View(dados2)

# ============================================================
# 🔹 Estatísticas por estrato
# ============================================================

# Média por estrato
estrato <- with(dados2, aggregate(
  list(areaest = areaest, areaparc = areaparc, ym = vary),
  list(estrato = estrato),
  mean
))

# Número de parcelas por estrato
calc <- with(dados2, aggregate(
  list(anj = parcela),
  list(estrato = estrato),
  function(x) length(unique(x))
))
estrato <- merge(estrato, calc)

# Variância e desvio padrão por estrato
calc <- with(dados2, aggregate(
  list(s2y = vary),
  list(estrato = estrato),
  var
))
calc$sy <- sqrt(calc$s2y)
estrato <- merge(estrato, calc)

# Converter área de parcela para ha e calcular número cabível
estrato$areaparc <- estrato$areaparc / 10000
estrato$pnj <- estrato$areaest / estrato$areaparc

# Nome da população
estrato$populacao <- 'Fazenda da Bruna'

# ============================================================
# 🔹 Cálculos populacionais
# ============================================================

# Área total, número de parcelas lançadas e cabíveis
populacao <- with(estrato, aggregate(
  list(area = areaest, an = anj, pn = pnj),
  list(populacao = populacao),
  sum
))

# Peso de cada estrato
estrato <- merge(estrato, populacao)
estrato$pwj <- estrato$pnj / estrato$pn

# Média estratificada
calc <- with(estrato, aggregate(
  list(ymstr = pwj * ym),
  list(populacao = populacao),
  sum
))
populacao <- merge(populacao, calc)

# Variância da média estratificada
calc <- with(estrato, aggregate(
  list(calc1 = pwj^2 * (s2y / anj)),
  list(populacao = populacao),
  sum
))
populacao <- merge(populacao, calc)

calc <- with(estrato, aggregate(
  list(calc2 = (pwj * s2y) / pn),
  list(populacao = populacao),
  sum
))
populacao <- merge(populacao, calc)

populacao$s2ystr <- with(populacao, calc1 - calc2)
populacao$calc1 <- NULL
populacao$calc2 <- NULL

# ============================================================
# 🔹 Grau de liberdade efetivo
# ============================================================
estrato$calcgl <- with(estrato, pnj * (pnj - anj) / anj)
calc <- with(estrato, aggregate(
  list(calc1 = calcgl * s2y,
       calc2 = (calcgl * s2y)^2 / (anj - 1)),
  list(populacao = populacao),
  sum
))
calc$gle <- calc$calc1^2 / calc$calc2
calc$calc1 <- NULL
calc$calc2 <- NULL
populacao <- merge(populacao, calc)

# ============================================================
# 🔹 Erros e Intervalos de Confiança
# ============================================================
populacao$errounid <- with(populacao, qt(1 - sig / 2, gle) * sqrt(s2ystr))
populacao$erroperc <- with(populacao, errounid / ymstr * 100)
populacao$ytstr <- with(populacao, ymstr * pn)
populacao$errototal <- with(populacao, errounid * pn)

total <- with(populacao, ymstr * pn)
etotal <- with(populacao, errounid * pn)
litot <- total - etotal
lstot <- total + etotal

print(paste('IC:', round(litot, 2), '<= T <=', round(lstot, 2), 'm³', sep = ''))

# Totais e erros por hectare
populacao$ymha <- with(populacao, ytstr / area)
populacao$erroha <- with(populacao, errototal / area)

View(populacao)
write.csv2(populacao, 'ACE_calculada_combinada.csv', row.names = FALSE)

# ============================================================
# 🔹 Validação com cmrinvflor
# ============================================================
library(cmrinvflor)

estrato_aux <- subset(dados2, !duplicated(estrato), select = c('estrato', 'areaest'))
amostra_aux <- dados2[, c('estrato', 'parcela', 'areaparc', 'vary')]

ace <- estats_ace(estrato_aux, amostra_aux, sig = sig * 100, fc_dim = 1 / 10000)
View(ace)

