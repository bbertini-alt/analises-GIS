library(terra)
library(sf)

# carregar o raster .tif
r <- rast("B8_fazenda.tif")

# carregar a linha já criada
linha <- st_read("contorno_poligono.shp")

# plotar raster
plot(r, col=terrain.colors(255))

# adicionar linha por cima
plot(st_geometry(linha), 
     add = TRUE, 
     col = "yellow", 
     lwd = 2)
png("raster_com_linha.png", width=1200, height=900, res=150)

plot(r, col=terrain.colors(255))
plot(st_geometry(linha), add = TRUE, col = "Yellow", lwd = 2)

dev.off()
