#############################################
# 🌲 KRIGAGEM ORDINÁRIA – SCRIPT CORRIGIDO
#############################################

library(sf)
library(geoR)
library(raster)
library(terra)
library(sp)
library(ggplot2)

#############################################
# 1️⃣ CARREGAR SOMENTE O POLÍGONO CORRETO
#############################################

shp <- st_read("C:/Users/bbert/OneDrive/Documentos/projetos/inventario/fazenda",
               layer = "fazenda")   # <<< CAMADA CERTA

# reprojeção apenas 1 vez
shp <- st_transform(shp, 32723)

plot(st_geometry(shp), col = "white")

areafaz <- sum(st_area(shp)) / 10000
cat("Área total da fazenda (ha):", areafaz, "\n")

#############################################
# 2️⃣ DADOS DO INVENTÁRIO
#############################################

invparc <- read.csv2("hipso_parcela.csv", stringsAsFactors = FALSE)

invparc <- aggregate(list(vcom = invparc$vparc), 
                     list(x = invparc$x, y = invparc$y, parcela = invparc$parcela), 
                     sum, na.rm = TRUE)

invparc <- invparc[, c("x", "y", "vcom")]

invparc_sf <- st_as_sf(invparc, coords = c("x", "y"), crs = 4326)
invparc_sf <- st_transform(invparc_sf, 32723)

invparc_sp <- as(invparc_sf, "Spatial")
vgeo <- as.geodata(invparc_sp, data.col = "vcom")

#############################################
# 3️⃣ VARIOGRAMA
#############################################

svar <- variog(vgeo, max.dist = 700)
plot(svar)

tau <- min(svar$v)
sigma <- max(svar$v) - tau
phi <- max(svar$uvec) / 3

ajuste <- variofit(svar, ini = c(sigma, phi), nugget = tau, cov.model = "exp")
lines(ajuste, col = "blue")

#############################################
# 4️⃣ CRIAR MALHA DA ÁREA
#############################################

ext <- st_bbox(shp)
res <- 20

x.seq <- seq(ext["xmin"], ext["xmax"], by = res)
y.seq <- seq(ext["ymin"], ext["ymax"], by = res)
grid <- expand.grid(x = x.seq, y = y.seq)
loc <- as.matrix(grid[, c("x", "y")])

kvgeo <- krige.conv(
  geodata = vgeo,
  loc = loc,
  krige = krige.control(obj.model = ajuste)
)

#############################################
# 5️⃣ GERAR RASTER E RECORTAR PELA ÁREA
#############################################

reskrige <- as.data.frame(grid)
names(reskrige) <- c("x", "y")
reskrige$vcom <- kvgeo$predict

coordinates(reskrige) <- ~x + y
gridded(reskrige) <- TRUE
crs(reskrige) <- crs(shp)

reskrige_r <- raster(reskrige)

shp_v <- vect(shp)
reskrige_t <- rast(reskrige_r)

# recorte correto agora que é POLÍGONO
reskrige_t <- crop(reskrige_t, shp_v)
reskrige_t <- mask(reskrige_t, shp_v)

reskrige_r <- raster(reskrige_t)

writeRaster(reskrige_r, "reskrige.tif", overwrite = TRUE)
cat("Arquivo 'reskrige.tif' salvo!\n")

#############################################
# 6️⃣ MAPA FINAL LIMPO
#############################################

df_plot <- as.data.frame(reskrige_r, xy = TRUE)
names(df_plot) <- c("x", "y", "vcom")

cores <- c("#2ca25f", "#99d8c9", "#fdd0a2", "#fc8d59", "#e34a33")

ggplot() +
  geom_raster(data = df_plot, aes(x = x, y = y, fill = vcom)) +
  geom_sf(data = shp, fill = NA, color = "black", size = 0.3) +
  scale_fill_gradientn(colours = cores, name = "Produtividade (m³)") +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(
    legend.position = "right",
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )


