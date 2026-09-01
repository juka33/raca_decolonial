#Carregar o pacote
library(bibliometrix)

##########################################
### Comandos mais frequentes do pacote ###
##########################################

#Importar e converter os dados, para verificar as variáveis
file <- "https://www.bibliometrix.org/datasets/savedrecs.bib"
M <- convert2df(file = file, dbsource = "isi", format = "bibtex")

#Verificar e calcular as principais métricas
results <- biblioAnalysis(M, sep = ";")
options(width = 100)

#Visualizar os dados e resultados gerais
S <- summary(object = results, k = 10, pause = FALSE)

#Gráficos principais
plot(x = results, k = 10, pause = FALSE)

#Análise de referências citadas <- importante

#Artigos mais citados
CR <- citations(M, field = "article", sep = ";")
cbind(CR$Cited[1:10])

#Autores mais citados
CR <- citations(M, field = "author", sep = ";")
cbind(CR$Cited[1:10])
CR <- localCitations(M, sep = ";")


##########################
### Merge WoS e Scopus ###
##########################

fwd #indicar o local

S = convert2df("scopus.bib", dbsourse = "scopus", format = "bibtex")
View(S)

W = convert2df("web_of_science.bib", dbsource = "wos", format = "bibtex")
View(W)

