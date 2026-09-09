# =========================================================
#  INVENTÁRIO FLORESTAL – AMOSTRAGEM ESTRATIFICADA POR ESPAÇAMENTO
# =========================================================

# 🔹 1. Ler dados
dados <- read.csv2("fustes_final.csv", stringsAsFactors = FALSE)
# Substituir 'x' por ' x ' e ajustar formato
dados$espacamento_legivel <- gsub("x", " x ", dados$espacamento)

# Trocar ponto por vírgula se quiser estilo brasileiro
dados$espacamento_legivel <- gsub("\\.", ",", dados$espacamento_legivel)

# Exemplo: 300x300 -> 300 x 300
# ou 3x2.5 -> 3 x 2,5


# 🔹 2. Variável de interesse
dados$vary <- as.numeric(dados$vprod_5)

# 🔹 3. Garantir espaçamentos legíveis
dados$espacamento_legivel <- trimws(as.character(dados$espacamento_legivel))

# 🔹 4. Calcular área total por espaçamento (estrato)
area_esp <- aggregate(area ~ espacamento_legivel, data = dados, sum, na.rm = TRUE)
names(area_esp)[2] <- "areaest"

# 🔹 5. Juntar as áreas de cada espaçamento com o dataset original
dados <- merge(dados, area_esp, by = "espacamento_legivel", all.x = TRUE)

# 🔹 6. Definir estrato como o espaçamento
dados$estrato <- dados$espacamento_legivel

# =========================================================
#  PROCESSAMENTO
# =========================================================

sig <- 0.01  # nível de significância (1%)

# 🔹 7. Somar volumes por parcela
dados2 <- with(dados, aggregate(
  list(vary = vary),
  list(areaest = areaest, areaparc = areaparc, estrato = estrato, parcela = parcela),
  sum, na.rm = TRUE
))

# 🔹 8. Médias por estrato
estrato <- with(dados2, aggregate(
  list(areaest = areaest, areaparc = areaparc, ym = vary),
  list(estrato = estrato),
  mean
))

# 🔹 9. Número de parcelas por estrato
calc <- with(dados2, aggregate(
  list(anj = parcela),
  list(estrato = estrato),
  length
))
estrato <- merge(estrato, calc)

# 🔹 10. Variância e desvio padrão por estrato
calc <- with(dados2, aggregate(
  list(s2y = vary),
  list(estrato = estrato),
  var
))
calc$sy <- sqrt(calc$s2y)
estrato <- merge(estrato, calc)

# 🔹 11. Ajustes de área e tamanho da população
estrato$areaparc <- estrato$areaparc / 10000  # m² → ha
estrato$pnj <- estrato$areaest / estrato$areaparc  # nº de parcelas cabíveis por estrato
estrato$populacao <- "Fazenda da Bruna"

# 🔹 12. Agregar dados populacionais
populacao <- with(estrato, aggregate(
  list(area = areaest, an = anj, pn = pnj),
  list(populacao = populacao),
  sum
))
estrato <- merge(estrato, populacao)

# 🔹 13. Peso de cada estrato na população
estrato$pwj <- estrato$pnj / estrato$pn

# 🔹 14. Média estratificada
calc <- with(estrato, aggregate(
  list(ymstr = pwj * ym),
  list(populacao = populacao),
  sum
))
populacao <- merge(populacao, calc)

# 🔹 15. Variância da média estratificada
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

# 🔹 16. Graus de liberdade efetivos
estrato$calcgl <- with(estrato, pnj * (pnj - anj) / anj)
calc <- with(estrato, aggregate(
  list(calc1 = calcgl * s2y, calc2 = (calcgl * s2y)^2 / (anj - 1)),
  list(populacao = populacao),
  sum
))
calc$gle <- calc$calc1^2 / calc$calc2
calc$calc1 <- NULL
calc$calc2 <- NULL
populacao <- merge(populacao, calc)

# 🔹 17. Erro amostral
populacao$errounid <- with(populacao, qt(1 - sig / 2, gle) * sqrt(s2ystr))
populacao$erroperc <- with(populacao, errounid / ymstr * 100)

# 🔹 18. Total e erro da população
populacao$ytstr <- with(populacao, ymstr * pn)
populacao$errototal <- with(populacao, errounid * pn)

# 🔹 19. Intervalo de confiança (IC total)
total <- populacao$ytstr
etotal <- populacao$errototal
litot <- total - etotal
lstot <- total + etotal
print(paste("IC:", round(litot, 2), "<= T <=", round(lstot, 2), "m³", sep = ""))

# 🔹 20. Resultados por hectare
populacao$ymha <- with(populacao, ytstr / area)
populacao$erroha <- with(populacao, errototal / area)

# 🔹 21. Exportar resultados
write.csv2(populacao, "ACE_es_
