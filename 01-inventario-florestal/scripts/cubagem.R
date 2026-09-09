
# ============================================================
# 🔹 CUBAGEM RIGOROSA – MÉTODO DE SMALIAN
# ============================================================


# ============================================================
# 1. Leitura correta do CSV
# ============================================================

primeira_linha <- readLines("cubagem.csv", n = 1)

sep_detectado <- if (grepl(";", primeira_linha, fixed = TRUE)) {
  ";"
} else {
  ","
}

dados <- read.csv(
  "cubagem.csv",
  sep = sep_detectado,
  fileEncoding = "UTF-8",
  stringsAsFactors = FALSE
)

if (ncol(dados) == 1) {
  stop(
    paste(
      "❌ O arquivo parece ter sido lido incorretamente",
      "(apenas 1 coluna detectada).\n",
      "Verifique o separador (',' ou ';') e salve novamente como CSV."
    )
  )
}

cat("✅ Colunas detectadas:\n")
print(names(dados))


# ============================================================
# 2. Verificar se as variáveis necessárias existem
# ============================================================

variaveis_necessarias <- c(
  "idfustemed",
  "numarv",
  "dap",
  "ht",
  "hi",
  "dicc1",
  "dicc2",
  "espcasca"
)

faltantes <- setdiff(variaveis_necessarias, names(dados))

if (length(faltantes) > 0) {
  stop(
    paste(
      "❌ As seguintes variáveis não foram encontradas no CSV:",
      paste(faltantes, collapse = ", ")
    )
  )
}


# ============================================================
# 3. Preparação dos dados
# ============================================================

# Converter variáveis numéricas
variaveis_numericas <- c(
  "dap",
  "ht",
  "hi",
  "dicc1",
  "dicc2",
  "espcasca"
)

for (v in variaveis_numericas) {
  dados[[v]] <- as.numeric(
    gsub(",", ".", as.character(dados[[v]]))
  )
}


# ============================================================
# 4. Verificação de valores ausentes
# ============================================================

cat("\n🔎 Valores ausentes por variável:\n")

print(
  colSums(
    is.na(
      dados[, c(
        "idfustemed",
        "numarv",
        "dap",
        "ht",
        "hi",
        "dicc1",
        "dicc2",
        "espcasca"
      )]
    )
  )
)


# ============================================================
# 5. Calcular diâmetro médio com casca
# ============================================================

dados$dicc <- (dados$dicc1 + dados$dicc2) / 2


# ============================================================
# 6. Remover registros incompletos
# ============================================================

n_antes <- nrow(dados)

dados <- dados[
  complete.cases(
    dados[, c(
      "idfustemed",
      "numarv",
      "dap",
      "ht",
      "hi",
      "dicc",
      "espcasca"
    )]
  ),
]

n_depois <- nrow(dados)

cat(
  "\n🧹 Registros removidos por dados ausentes:",
  n_antes - n_depois,
  "\n"
)


# ============================================================
# 7. Conferência básica dos dados
# ============================================================

cat("\n📊 Resumo das variáveis:\n")

print(
  summary(
    dados[, c(
      "dap",
      "ht",
      "hi",
      "dicc",
      "espcasca"
    )]
  )
)


# ============================================================
# 8. Seleção das variáveis para a cubagem
# ============================================================

cub <- dados[
  ,
  c(
    "idfustemed",
    "dap",
    "ht",
    "hi",
    "dicc",
    "espcasca"
  )
]


# Garantir tipos compatíveis com o cmrinvflor
cub$idfustemed <- as.character(cub$idfustemed)

cub$dap <- as.numeric(cub$dap)
cub$ht <- as.numeric(cub$ht)
cub$hi <- as.numeric(cub$hi)
cub$dicc <- as.numeric(cub$dicc)
cub$espcasca <- as.numeric(cub$espcasca)


# ============================================================
# 9. Verificar alturas inválidas
# ============================================================

n_invalidos <- sum(cub$hi > cub$ht, na.rm = TRUE)

if (n_invalidos > 0) {
  cat(
    "⚠️ Registros com HI > HT removidos:",
    n_invalidos,
    "\n"
  )
}

cub <- subset(cub, hi <= ht)


# ============================================================
# 10. Verificar diâmetro sem casca
# ============================================================

# O cmrinvflor calcula:
#
# di = dicc - (2 × espcasca)
#
# portanto, verificamos previamente se haverá valores negativos.

cub$di_sem_casca <- cub$dicc - (2 * cub$espcasca)

n_di_invalidos <- sum(cub$di_sem_casca < 0, na.rm = TRUE)

if (n_di_invalidos > 0) {
  stop(
    paste(
      "❌ Existem", n_di_invalidos,
      "registros em que o diâmetro sem casca é negativo.",
      "\nVerifique dicc e espcasca."
    )
  )
}

# Remover coluna auxiliar antes do smalian
cub$di_sem_casca <- NULL


# ============================================================
# 11. Conferência da estrutura para o cmrinvflor
# ============================================================

cat("\n🌳 Estrutura utilizada na cubagem:\n")

print(str(cub))

cat("\nNúmero de registros:", nrow(cub), "\n")
cat(
  "Número de árvores/fustes:",
  length(unique(cub$idfustemed)),
  "\n"
)


# ============================================================
# 12. Carregar pacote
# ============================================================

library(cmrinvflor)

cat("\n📦 Versão do cmrinvflor:\n")
print(packageVersion("cmrinvflor"))

cat("\n⚙️ Estrutura da função smalian():\n")
print(args(smalian))


# ============================================================
# 13. CORREÇÃO DE COMPATIBILIDADE DO cmrinvflor 4.0
# ============================================================
#
# A função parear_seqmed() da versão 4.0 utiliza:
#
#   dfdados[1]
#   dfdados[2]
#
# dentro de order().
#
# Esses objetos são data.frames de uma coluna, causando:
#
#   Error in xtfrm.data.frame(x)
#
# A correção é utilizar:
#
#   dfdados[[1]]
#   dfdados[[2]]
#
# que retornam vetores.
#
# Também corrigimos a comparação:
#
#   dfdados1[[1]] == dfdados2[[1]]
#
# ============================================================

parear_seqmed_corrigida <- function(dfdados) {
  
  # Ordenação correta dos vetores
  dfdados <- dfdados[
    order(dfdados[[1]], dfdados[[2]]),
    ,
    drop = FALSE
  ]
  
  nv <- names(dfdados)
  nc <- length(nv)
  
  nv1 <- c(
    nv[1],
    paste(nv[2:nc], 1, sep = "")
  )
  
  nv2 <- c(
    nv[1],
    paste(nv[2:nc], 2, sep = "")
  )
  
  nv <- nv1[1]
  
  for (i in 2:nc) {
    nv <- c(nv, nv1[i], nv2[i])
  }
  
  dfdados1 <- dfdados[
    -nrow(dfdados),
    ,
    drop = FALSE
  ]
  
  dfdados2 <- dfdados[
    -1,
    ,
    drop = FALSE
  ]
  
  names(dfdados1) <- nv1
  names(dfdados2) <- nv2
  
  dfdados <- cbind(
    dfdados1,
    dfdados2[, -1, drop = FALSE]
  )
  
  dfdados <- dfdados[
    dfdados1[[1]] == dfdados2[[1]],
    nv,
    drop = FALSE
  ]
  
  return(dfdados)
}


# ============================================================
# 14. Substituir a função problemática no namespace
# ============================================================

ns <- asNamespace("cmrinvflor")

unlockBinding("parear_seqmed", ns)

assign(
  "parear_seqmed",
  parear_seqmed_corrigida,
  envir = ns
)

lockBinding("parear_seqmed", ns)

cat("\n✅ Correção de compatibilidade aplicada ao cmrinvflor 4.0.\n")


# ============================================================
# 15. Conferir se a correção foi aplicada
# ============================================================

parear_atual <- get(
  "parear_seqmed",
  envir = asNamespace("cmrinvflor")
)

cat("\n🔎 Conferindo parear_seqmed():\n")

print(parear_atual)


# ============================================================
# 16. Cubagem rigorosa – Método de Smalian
# ============================================================

cat("\n🌲 Executando cubagem rigorosa pelo método de Smalian...\n")

vsmal <- smalian(
  cub,
  dcoms = 5,          # diâmetro mínimo comercial (cm)
  htoco = 10,         # altura do toco (cm)
  comcasca = FALSE,   # volume sem casca
  di_ou_ci = "di",    # utilizar diâmetro
  hcil_toco = 10,
  dbase_ponta = 5
)

cat("\n✅ Cubagem executada com sucesso!\n")


# ============================================================
# 17. Conferir resultado
# ============================================================

cat("\n📋 Variáveis disponíveis no resultado:\n")

print(names(vsmal))


# ============================================================
# 18. Selecionar variáveis principais
# ============================================================

cubagem <- vsmal[
  ,
  c(
    "idfustemed",
    "dap",
    "ht",
    "vprod_5"
  )
]


# ============================================================
# 19. Adicionar número da árvore
# ============================================================

matgen <- aggregate(
  list(numarv = dados$numarv),
  list(idfustemed = dados$idfustemed),
  function(x) {
    x[1]
  }
)


# Garantir mesmo tipo para a junção
matgen$idfustemed <- as.character(matgen$idfustemed)
cubagem$idfustemed <- as.character(cubagem$idfustemed)


cubagem <- merge(
  matgen,
  cubagem,
  by = "idfustemed",
  all.y = TRUE
)


# ============================================================
# 20. Filtrar volumes válidos
# ============================================================

n0 <- sum(
  cubagem$vprod_5 == 0,
  na.rm = TRUE
)

if (n0 > 0) {
  
  cat(
    "\n⚠️",
    n0,
    "árvores apresentaram volume igual a 0.",
    "\n"
  )
  
  cat(
    "Isso ocorre quando não há volume comercial acima",
    "do diâmetro mínimo especificado.\n"
  )
}


n_na <- sum(
  is.na(cubagem$vprod_5)
)

if (n_na > 0) {
  
  cat(
    "⚠️",
    n_na,
    "registros apresentam volume NA.\n"
  )
}


cubagem <- subset(
  cubagem,
  !is.na(vprod_5) & vprod_5 > 0
)


# ============================================================
# 21. Conferência final
# ============================================================

cat("\n📊 Resultado final da cubagem:\n")

print(summary(cubagem$vprod_5))

cat(
  "\nNúmero de árvores com volume válido:",
  nrow(cubagem),
  "\n"
)

cat(
  "Volume total comercial:",
  sum(cubagem$vprod_5, na.rm = TRUE),
  "\n"
)


# ============================================================
# 22. Visualizar resultado
# ============================================================

View(cubagem)


# ============================================================
# 23. Exportar resultados
# ============================================================

write.csv2(
  cubagem,
  "cubagem_smalian.csv",
  row.names = FALSE
)

cat(
  "\n✅ Arquivo 'cubagem_smalian.csv' salvo com sucesso!\n"
)
