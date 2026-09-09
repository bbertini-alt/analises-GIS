library(terra)
library(sf)

# ============================
# 1) CARREGAR RASTER (1 banda)
# ============================
r <- rast("B8_fazenda.tif")

# verificar valores min/max
range(values(r), na.rm = TRUE)

# ajuste dos limites de cor (altere se desejar)
min_val <- global(r, "min", na.rm=TRUE)[1]
max_val <- global(r, "max", na.rm=TRUE)[1]
#definir cores
pal <- colorRampPalette(c(
  "#012A4A",  # azul profundo
  "#01497C",  # azul forte
  "#2A6F97",  # azul acinzentado
  "#2C8C99",  # azul esverdeado
  "#52B69A",  # verde água
  "#76C893",  # verde claro
  "#F4D35E",  # amarelo suave
  "#F4D301"   # amarelo forte / dourado
))(255)


# ============================
# 2) CARREGAR CONTORNO
# ============================
linha <- st_read("contorno_poligono.shp")

# ============================
# 3) PLOT INTERATIVO NA TELA
# ============================
plot(r,
     col = pal,
     axes = TRUE,
     main = "Banda 8 – Paleta fixa (estável)"
)

plot(st_geometry(linha),
     add = TRUE,
     col = "yellow",
     lwd = 2)

# ============================
# 4) EXPORTAR PNG SEM ALTERAR AS CORES
# ============================
png("B8_com_linha.png",
    width = 1200,
    height = 900,
    res = 150)

plot(r,
     col = pal,
     axes = TRUE,
     main = " "
)

plot(st_geometry(linha),
     add = TRUE,
     col = "yellow",
     lwd = 2)

dev.off()

