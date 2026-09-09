# ============================================================
# 🔹 INVENTÁRIO FLORESTAL - AMOSTRAGEM ESTRATIFICADA POR MATERIAL GENÉTICO
# ============================================================

# 1️⃣ Ler dados
dados <- read.csv2("fustes_final.csv")
View(dados)
names(dados)

# Variável de interesse (volume por parcela)
dados$vary <- dados$vprod_5

# ============================================================
# 🔹 Verificando possíveis fatores de estratificação
# ============================================================
# parcela    -> muitas
# fazenda    -> uma só
# plantio    -> vários (mas há talhões com só uma parcela)
# matgen     -> possível estratificação
# espacamento -> único
# idade      -> vários

calc <- subset(dados, !duplicated(plantio), c("plantio", "area", "matgen"))
View(calc)

# ============================================================
# 🔹 Cálculo da área total por material genético
# ============================================================
mat1 <- subset(calc, matgen == 1); areamat1 <- sum(mat1$area)
mat2 <- subset(calc, matgen == 2); areamat2 <- sum(mat2$area)
mat3 <- subset(calc, matgen == 3); areamat3 <- sum(mat3$area)
mat4 <- subset(calc, matgen == 4); areamat4 <- sum(mat4$area)
mat5 <- subset(calc, matgen == 5); areamat5 <- sum(mat5$area)

areamattot <- c(areamat1, areamat2, areamat3, areamat4, areamat5)
areatot <- sum(areamattot)

# Atribuir a área estimada de cada estrato ao conjunto principal
dados$areaest <- NA
dados$areaest[dados$matgen == 1] <- areamat1
dados$areaest[dados$matgen == 2] <- areamat2
dados$areaest[dados$matgen == 3] <- areamat3
dados$areaest[dados$matgen == 4] <- areamat4
dados$areaest[dados$matgen == 5] <- areamat5
View(dados)

# ============================================================
# 🔹 Escolhendo o fator de estratificação
# ============================================================
dados$estrato <- dados$matgen

# Nível de significância
sig <- 0.01  # alfa = 1%

# ============================================================
# 🔹 Volume total por parcela (agregação por unidade amostral)
# ============================================================
dados2 <- with(dados, aggregate(
  list(vary = vary),
  list(areaest = areaest, areaparc = areaparc, estrato = estrato, parcela = parcela),
  sum, na.rm = TRUE
))
View(dados2)

# ============================================================
# 🔹 Estatísticas básicas por estrato
# ============================================================
estrato <- with(dados2, aggregate(
  list(areaest = areaest, areaparc = areaparc, ym = vary),
  list(estrato = estrato),
  mean
)); estrato

# Número de parcelas lançadas por estrato
calc <- with(dados2, aggregate(list(anj = parcela), list(estrato = estrato), length))
estrato <- merge(estrato, calc)

# Variância e desvio padrão por estrato
calc <- with(dados2, aggregate(list(s2y = vary), list(estrato = estrato), var))
calc$sy <- sqrt(calc$s2y)
estrato <- merge(estrato, calc)

# Converter área da parcela para hectares
estrato$areaparc <- estrato$areaparc / 10000
estrato$pnj <- estrato$areaest / estrato$areaparc  # parcelas cabíveis por estrato

# Nomear a população
estrato$populacao <- "Fazenda da Bruna"

# ============================================================
# 🔹 Estatísticas da população
# ============================================================
populacao <- with(estrato, aggregate(
  list(area = areaest, an = anj, pn = pnj),
  list(populacao = populacao),
  sum
)); populacao

estrato <- merge(estrato, populacao)

# Peso de cada estrato na população
estrato$pwj <- estrato$pnj / estrato$pn

# Média estratificada ponderada
calc <- with(estrato, aggregate(list(ymstr = pwj * ym), list(populacao = populacao), sum))
populacao <- merge(populacao, calc)

# Variância da média estratificada
calc1 <- with(estrato, aggregate(list(calc1 = pwj^2 * (s2y / anj)), list(populacao = populacao), sum))
calc2 <- with(estrato, aggregate(list(calc2 = (pwj * s2y) / pn), list(populacao = populacao), sum))
populacao <- merge(populacao, calc1)
populacao <- merge(populacao, calc2)

populacao$s2ystr <- with(populacao, calc1 - calc2)
populacao$calc1 <- populacao$calc2 <- NULL

# ============================================================
# 🔹 Grau de liberdade efetivo
# ============================================================
estrato$calcgl <- with(estrato, pnj * (pnj - anj) / anj)

calc <- with(estrato, aggregate(
  list(calc1 = calcgl * s2y, calc2 = (calcgl * s2y)^2 / (anj - 1)),
  list(populacao = populacao),
  sum
))
calc$gle <- calc$calc1^2 / calc$calc2
calc$calc1 <- calc$calc2 <- NULL
populacao <- merge(populacao, calc)

# ============================================================
# 🔹 Erros amostrais e totais
# ============================================================
populacao$errounid <- with(populacao, qt(1 - sig / 2, gle) * sqrt(s2ystr))
populacao$erroperc <- with(populacao, errounid / ymstr * 100)

# Total e erro populacional
populacao$ytstr <- with(populacao, ymstr * pn)
populacao$errototal <- with(populacao, errounid * pn)
total <- with(populacao, ymstr * pn)
etotal <- with(populacao, errounid * pn)

# Intervalo de confiança da população
litot <- total - etotal
lstot <- total + etotal
print(paste("IC:", round(litot, 2), "<= T <=", round(lstot, 2), "m³", sep = ""))

# ============================================================
# 🔹 Volume total e erro por hectare
# ============================================================
populacao$ymha <- with(populacao, ytstr / area)
populacao$erroha <- with(populacao, errototal / area)

View(populacao)
write.csv2(populacao, "ACE_matgen.csv", row.names = FALSE)

# ============================================================
# 🔹 Conferência via pacote 'cmrinvflor'
# ============================================================
library(cmrinvflor)

View(dados2)
estrato <- subset(dados2, !duplicated(estrato), select = c("estrato", "areaest"))
amostra <- dados2[, c("estrato", "parcela", "areaparc", "vary")]

ace <- estats_ace(estrato, amostra, sig = sig * 100, fc_dim = 1 / 10000)
View(ace)
