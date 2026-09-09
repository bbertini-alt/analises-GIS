# ============================================================
# 🔹 1. Leitura correta do CSV
# ============================================================
primeira_linha <- readLines("fustes.csv", n = 1)
sep_detectado <- if (any(grepl(";", primeira_linha))) ";" else ","

arv <- read.csv("fustes.csv",
                sep = sep_detectado,
                fileEncoding = "UTF-8",
                stringsAsFactors = FALSE)

if (ncol(arv) == 1) {
  stop("❌ O arquivo parece ter sido lido incorretamente (apenas 1 coluna detectada).
Verifique o separador (',' ou ';') e tente salvar novamente como CSV padrão no Excel.")
}

cat("✅ Colunas detectadas:\n")
print(names(arv))

# ============================================================
# 🔹 2. Padronização de colunas
# ============================================================
names(arv) <- trimws(names(arv))

# Converter colunas numéricas (tratando vírgulas)
arv$dap   <- as.numeric(gsub(",", ".", arv$dap))
arv$ht    <- as.numeric(gsub(",", ".", arv$ht))
arv$htre  <- as.numeric(gsub(",", ".", arv$htre))
arv$areaparc <- as.numeric(gsub(",", ".", arv$areaparc))

# ============================================================
# 🔹 3. Contar número de dominantes por parcela
# ============================================================
nhdom <- with(subset(arv, grepl("dominant", tolower(desc_cat))),
              aggregate(list(nhdom = ht),
                        list(parcela = parcela),
                        length))

View(nhdom)
unique(nhdom$nhdom)

##ESCOLHER A MÉDIA DAS 5 DOMINANTES (ALTURA DAS 5 MAIS GROSSAS) EM CADA PARCELA (EVITA ERROS DA BASE)
#fhdom<-function(x){
#x<-x[order(x$dap, decreasing = T),]
#x<-x[!is.na(x$ht) & x$ht>0,]
#x<-x[1:round(x$areaparc[1]/100),];
#return(data.frame(parcela=x$parcela[1],hdom=mean(x$ht)))
#}

## CRIAR COLUNA ALTURA DOMINANTE (CASO AS 5 MAIS GROSSAS SEJAM AS DOMINANTES - BASE CORRETA)
hdom<-with(subset(arv,desc_cat=='Dominante'),
           aggregate(list(hdom=ht),
                     list(parcela=parcela),
                     mean, na.rm=T))

arv<-merge(arv,hdom,by='parcela'); ##CRIA A COLUNA DA MÉDIA DAS DOMINANTES POR PARCELA

head(arv);
View(arv);
#----------------SE JÁ TIVER COLUNA HDOM, RODAR A PARTIR DAQUI---------------------------------------------------------

#MODELO HIPSOMETRICO GENÉRICO
modelo<-'log(ht)~I(log(hdom))+I(1/dap)';

#Excluir árvores que a altura não foi medida (NA)
selarv<-subset(arv,!is.na(ht) & ht> 0 & dap>0); 
nrow(arv)
nrow(selarv) 

#CRIANDO O MODELO LINEAR PARA A HIPSOMETRIA GENÉRICA
ajhipso<-lm(modelo, selarv)
coef(ajhipso)
sumario<-summary(ajhipso)

#RETORNANDO OS VALORES DOS BETAS (Questão 1-a,b,c)
(bs<-as.vector(coef(ajhipso)));
paste(bs[1],bs[2],bs[3]);

#Coeficiente de determinacao (R-Squared)
R2adj=sumario$adj.r.squared
R2adj

#Coeficiente de determinacao em porcentagem (%) - Round define a qtde de casas decimais 
R2adjp=round(R2adj*100,2) 
R2adjp #Questão 1-f

#INDICE DE FURNIVAL (corrigir o erro residual para m)
y<-selarv$ht;
D(expression(log(y)),'y'); #Derivada
dy<-1/y;
(medgeo<-exp(mean(log(dy)))); #média geometrica

#sumario$sigma = Erro padrão residual em m³  ♥ 
(IF<-1/medgeo*sumario$sigma); #Questão 1-d
#Indice de furnival em porcentagem
(IFperc<-round(IF/mean(y)*100,2));#Questão 1-e

#CALCULANDO A ALTURA ESTIMADA A PARTIR DO MODELO 
arv$htest<-exp(bs[1]+bs[2]*log(arv$hdom)+bs[3]/arv$dap); 
View(arv)

x11();
par(mfrow=c(1,2))
with(arv,plot(htest~dap,xlab='dap(cm)',
              ylab='htest(m)',pch='*',col='red'))
with(arv,plot(ht~dap,xlab='dap(cm)',
              ylab='ht(m)',pch='*',col='green'))

x11();
with(arv,plot(ht~dap,xlab='dap(cm)',
              ylab='ht(m)',pch='*',col='green'))
with(arv,points(htest~dap,pch='*',col='red'));

#Htre = altura real
arv$htre<-arv$ht;
ii<-is.na(arv$ht)
sum (ii) #total de arvores com ht nula

#todo mundo que NÃO TIVER ALTURA REAL, vai receber a HTEST
arv$htre[ii]<-arv$htest[ii];
View(arv)

#agora tenho a altura de todas as árvores (real ou estimada)
# volumetria --------------------------------------------------------------
cubagem <- read.csv2('cubagem_smalian.csv')
View(cubagem)

#Modelo de Berkhout (v=b0*dap^b1)
modelo<-'vprod_5~b0*dap^b1';
(ajmb=nls (modelo,cubagem,start= list(b0=pi/40000*0.45,b1=2))); #ajmb = ajuste do modelo de berkhout
coef(ajmb);
sumario<-summary(ajmb);


syx=sumario$sigma;syx;#erro padrão residual modelo de berkhout
syxperc=syx/mean(cubagem$vprod_5)*100; syxperc;# erro padrão residual em porcentagem modelo de berkhout

#Modelo de Spurr (v=b0+b1*dap^2ht)
modeloS<-'vprod_5~I(dap^2*ht)';#Modelo de spurr
ajms=lm(formula = modeloS,data = cubagem);#ajms= ajuste modelo de spurr
coef(ajms);
spurr=summary(ajms);
sys=spurr$sigma;#sys= erro padrão residual modelo de spurr (m³)
sysp=round(sys/mean(cubagem$vprod_5)*100,2);sysp;#sysp= erro padrão residual do modelo de spurr em porcentagem
R2adj=spurr$adj.r.squared; #coeficiente de determinação
R2adjp=round(R2adj*100,2);R2adjp; #coeficiente de determinação

#Modelo de Spurr logaritmico (ln(v)=b0+b1*ln(dap^2*ht))
summary(cubagem$vprod_5)
sum(is.na(cubagem$vprod_5))      # quantos são NA
sum(cubagem$vprod_5 == 0, na.rm = TRUE)  # quantos são 0
sum(cubagem$vprod_5 < 0, na.rm = TRUE)   # quantos são negativos
cubagem[cubagem$vprod_5 == 0, ]


modeloSL='log(vprod_5)~log(dap^2*ht)';#Modelo de spurr logaritmico
ajmsl=lm(modeloSL,cubagem);#ajmsl=ajuste modelo spurr logaritmico
print(summary(ajmsl));
anova(ajmsl);
##Índice de Furnival 
##Para o cálculo do IF deve-se calcular a inversa da média geométrica da derivada da variável dependente e, em seguida,
##multiplicar pelo erro padrão residual obtido no ajuste com a variável transformada

y<-cubagem$vprod_5;
D(expression(log(y)),'y');
dy<-1/y;

(medgeo<-exp(mean(log(dy), na.rm=T))); # Média geométrica
spurrlog=summary(ajmsl);spurrlog;
sysl=1/medgeo*spurrlog$sigma;#sysl-erro padrão da média com escala convertida de lnm³ para  m³ 
syslp=sysl/mean(y)*100;syslp;#syslp- erro padrão spurr log corrigido
R2adjsl=spurrlog$adj.r.squared; #coeficiente de determinação spurr log
R2adjpsl=round(R2adjsl*100,2);R2adjpsl; #coeficiente de determinação spurr log
as.vector(sysl)


#Modelo de Schumacher & Hall
modeloSH<-'vprod_5~b0*dap^b1*ht^b2';
(ajsh=nls(modeloSH,cubagem, start=list(b0=pi/40000*0.45,b1=2,b2=1)));
coef(ajsh);
(schumacher<-summary(ajsh));

(sysh<-schumacher$sigma); #Erro padrão residual
(syshp<-sysh/mean(cubagem$vprod_5)*100); #Syx percentual

#Modelo de Schumacher & Hall (Logaritmico); ln(vicc) = b0+b1*ln(dap)+b2*ln(ht)
modeloSHL<-'log(vprod_5)~log(dap)+log(ht)';

###Ajuste de modelos lineares múltiplos
ajshl<-lm(formula = modeloSHL, data = cubagem);
schumacherl=summary(ajshl);
coef(ajshl)
syshl=1/medgeo*schumacherl$sigma;#sysl-erro padrão da média com escala convertida de lnm³ para  m³ 
syshlp=syshl/mean(y)*100;syshlp;#syslp- erro padrão spurr log corrigido
R2adjsl=schumacherl$adj.r.squared; #coeficiente de determinação spurr log
R2adjpsl=round(R2adjsl*100,2);R2adjpsl; #coeficiente de determinação spurr log

#Modelo de Takata v=dap²ht/b0+b1*dap
modeloT<-'I((dap^2*ht)/vprod_5)~(dap)';
ajlin=lm(modeloT,cubagem);
summary(ajlin);
coef(ajlin)
modeloT='vprod_5~(dap^2*ht)/(b0+b1*dap)';
(ajt=nls(modeloT,cubagem, start=list(b0=32779.47722,b1=-88.22484)));
coef(ajt);
(takata<-summary(ajt));

(syt<-takata$sigma); #Erro padrão residual
(sytp<-syt/mean(cubagem$vprod_5)*100);sytp; #Syx percentual

#calculando os volumes preditos
(cubagem$vprod_5estberk=predict(ajmb));#berkhout est
(cubagem$vprod_5estspurr=predict(ajms));#spurr est

(fc<-exp(0.5*spurrlog$sigma^2));# fator de meyer
cubagem$vprod_5estspurrlog=exp(predict(ajmsl))*fc;#spurr log est

(cubagem$vprod_5estschum=predict(ajsh));#schumacher est

(fm<-exp(0.5*schumacherl$sigma^2));#fator de meyer
cubagem$vprod_5estchumlog=exp(predict(ajshl))*fm;#schumacher log est
(cubagem$vprod_5esttakata=predict(ajt)); #takata est

#calculando os resíduos
cubagem$resberk=residuals(ajmb);# res berkhout
cubagem$resspurr=residuals(ajms);# res spurr
cubagem$resspurrlog<-cubagem$vprod_5-cubagem$vprod_5estspurrlog;#res spurr log
cubagem$resschumacher=residuals(ajsh);# res schumacher log
cubagem$resschumacherlog<-cubagem$vprod_5-cubagem$vprod_5estchumlog;#res schumacher log
cubagem$restakata=residuals(ajt);# res takata

library(fBasics);
x11();
par(mfrow=c(3,2))
qqnormPlot((cubagem$resberk),title = FALSE, main = "Berkhout");
qqnormPlot((cubagem$resspurr),title = FALSE, main = "Spurr");
qqnormPlot((cubagem$resspurrlog),title = FALSE, main = "Spurr log");
qqnormPlot((cubagem$resschumacher),title = FALSE, main = "Schumacher & Hall");
qqnormPlot((cubagem$resschumacherlog),title = FALSE, main = "Schumacher & Hall log");
qqnormPlot((cubagem$restakata),title = FALSE, main = "Takata");

#grafico de residuos

x11();
par(mfrow=c(3,2))
with(cubagem,plot(vprod_5estberk,resberk,pch='*',#berkhout
                  main='Berkhout',
                  xlab='Volume estimado(m?)',
                  ylab='Res?duos (m?)',
                  col='red',ylim=c(-0.06,0.06)));
abline(h=0);

with(cubagem,plot(vprod_5estspurr,resspurr,pch='*',
                  main='Spurr',
                  xlab='Volume estimado(m?)',
                  ylab='Res?duos (m?)',
                  col='red',ylim=c(-0.06,0.06)));
abline(h=0);

with(cubagem,plot(vprod_5estspurrlog,resspurrlog,pch='*',
                  main='Spurr log',
                  xlab='Volume estimado(m?)',
                  ylab='Res?duos (m?)',
                  col='red',ylim=c(-0.06,0.06)));
abline(h=0);

with(cubagem,
     plot(vprod_5estschum,resschumacher,pch='*',
          main='Schumacher & Hall',
          xlab='Volume estimado(m?)',
          ylab='Res?duos (m?)',
          col='blue',ylim=c(-0.06,0.06)));
abline(h=0);

with(cubagem,
     plot(vprod_5estchumlog,resschumacherlog,pch='*',
          main='Schumacher log',
          xlab='Volume estimado(m?)',
          ylab='Res?duos (m?)',
          col='red',ylim=c(-0.06,0.06)));
abline(h=0);

with(cubagem,plot(vprod_5esttakata,restakata,pch='*',#berkhout
                  main='Takata',
                  xlab='Volume estimado(m?)',
                  ylab='Res?duos (m?)',
                  col='red',ylim=c(-0.06,0.06)));
abline(h=0);

selarv <- subset(arv,!is.na(dap) & !is.na(htre) 
                 & dap>0 & htre>0)


(bs<-as.vector(coef(ajsh)))

#colocar o codigo modelo selecionado dentro dos parenteses 

selarv$vprod_5<-(bs[1]*(selarv$dap)^bs[2]*(selarv$htre)^bs[3])
#modeloSH<-'vprod_7~b0*dap^b1*ht^b2'

View(selarv)
names(selarv)
write.csv2(selarv,'fustes_final.csv',);
# Aplicar o modelo TAKATA no vprod_5

# bs[1] = b0
# bs[2] = b1

selarv$vprod_5 <- ( (selarv$dap^2) * selarv$htre ) / ( bs[1] + bs[2] * selarv$dap )

# Registrar fórmula (se quiser mostrar no relatório)
modeloTAK <- 'vprod_5 ~ (dap^2 * ht) / (b0 + b1*dap)'

View(selarv)
names(selarv)

# Salvar arquivo atualizado
write.csv2(selarv, 'fustes_final.csv', row.names = FALSE)


parc <- with(selarv,
             aggregate(list(vparc = vprod_5),
                       list(plantio = plantio,
                            parcela = parcela,
                            areaparc = areaparc,
                            x = x,
                            y = y),
                       sum))


write.csv2(parc,'hipso_parcela.csv',);

###############################################################################################################################
###############################################################################################################################
#juntar os dados do cadastro com a selarv de modo que cada linha de selarv tenha os atributos do cadastro (indicado pela coluna plantio presente nas duas)
#############################################
# 🔹 JUNÇÃO DE SELARV E CADASTRO
#    (baseada na coluna "plantio")
#############################################

# --- Função auxiliar para detectar separador ---
detectar_sep <- function(arquivo) {
  primeira_linha <- readLines(arquivo, n = 1)
  if (grepl(";", primeira_linha)) return(";")
  if (grepl(",", primeira_linha)) return(",")
  return(";")  # padrão caso não detecte
}

# --- 1️⃣ Ler arquivos com detecção automática ---
cat("📂 Lendo arquivos...\n")

sep_cad <- detectar_sep("cadastro.csv")
cadastro <- read.csv("cadastro.csv", sep = sep_cad, stringsAsFactors = FALSE)

sep_sel <- detectar_sep("fustes_final.csv")
selarv <- read.csv("fustes_final.csv", sep = sep_sel, stringsAsFactors = FALSE)

cat("✅ Arquivos lidos com sucesso!\n")
cat("   Linhas cadastro:", nrow(cadastro), "\n")
cat("   Linhas selarv:", nrow(selarv), "\n\n")

# --- 2️⃣ Conferir se a coluna 'plantio' existe em ambos ---
if (!("plantio" %in% names(cadastro)) | !("plantio" %in% names(selarv))) {
  stop("❌ A coluna 'plantio' precisa estar presente em ambos os arquivos!")
}

# --- 3️⃣ Fazer o merge (junção) ---
cat("🔄 Unindo dados pelo campo 'plantio'...\n")

selarv_full <- merge(
  selarv,
  cadastro,
  by = "plantio",
  all.x = TRUE  # mantém todas as linhas da selarv
)

cat("✅ Junção concluída!\n")
cat("   Linhas finais:", nrow(selarv_full), "\n\n")

# --- 4️⃣ Verificar se há plantios sem correspondência ---
sem_match <- selarv_full[is.na(selarv_full[, ncol(selarv_full)]), "plantio"]
if (length(sem_match) > 0) {
  cat("⚠️ Atenção: há", length(unique(sem_match)), "plantio(s) sem correspondência no cadastro.\n")
  print(unique(sem_match))
} else {
  cat("🌿 Todos os plantios encontrados no cadastro!\n")
}

write.csv2(selarv_full,'fustes_final.csv',);
#############################################

