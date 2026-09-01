# Limpando a mem?ria do R
rm(list=ls(all=TRUE))
par(mfrow=c(1,1))

library(bibliometrix)

# Colocar o caminho da pasta de destino que cont?m os arquivos baixados
setwd("C:/R_Projects/raca_decolonial_cientometria/data")

# Visualizar o caminho que está selecionado
getwd()

# Visualizar os arquivos que estão no caminho selecionado
dir()

# A melhor maneira de fazer a coleta de dados da WoS é por via .txt
WOS <- convert2df(file = "wos.txt", dbsource = "wos", format = "plaintext")

# A melhor maneira de fazer a coleta de dados da Scopus é por via .bib
#SCP0 <- convert2df(file = "scopus0.bib", dbsource = "scopus", format = "bibtex")
#não indexou as referências (CR)

# A melhor maneira de fazer a coleta de dados da Scopus é por via .bib
#SCP1 <- convert2df(file = "scopus1.txt", dbsource = "scopus", format = "plaintext")
#esse não ficou legal, não achou o M


# A melhor maneira de fazer a coleta de dados da Scopus é por via .bib
SCP <- convert2df(file = "scopus3.csv", dbsource = "scopus", format = "csv")

# Unindo as duas bases e removendo as duplicidades
M <- mergeDbSources(WOS, SCP, remove.duplicated = TRUE)

# Corrigir o campo CR
M$CR <- M$CR_raw

resultados <- biblioAnalysis(M)
citacoes <- citations(M, field = "article", sep = ";")

# Dados principais
# export_data <- M[,c("AU", "PY", "TI", "SO", "DE", "ID", "TC", "DI", "LA", "DT", "CR", "AB")]

# Melhor salvar no formato R direto pois o CSV pode gerar erros no Shiny
saveRDS(M, file = "bibliometric_data.rds")


#####
### Se houver problemas nos sobrenomes
library(writexl)

# Selecionar colunas úteis para edição (exemplo)
M_export <- M[, c("AU", "AF", "AU_UN", "TI", "SO", "PY", "CR")]

# Adicionar coluna vazia para você preencher (ex.: correção de AU)
M_export$AU_corrigido <- NA

write_xlsx(M_export, path = "autores_para_corrigir.xlsx")

library(readxl)

# Lê o arquivo preenchido
corrigido_df <- read_xlsx("autores_para_corrigir.xlsx")

# Substituir apenas quando AU_corrigido estiver preenchido
M$AU <- ifelse(!is.na(corrigido_df$AU_corrigido), corrigido_df$AU_corrigido, M$AU)

# Corrigir o campo CR
M$CR <- M$CR_raw

# Melhor salvar no formato R direto pois o CSV pode gerar erros no Shiny
saveRDS(M, file = "bibliometric_data1.rds")
#####


# Calculando os parâmetros
resultados <- biblioAnalysis(M) #análise descritiva dos dados
summary(resultados, k = 10, pause = FALSE)

print(bibliometric_data.rds)

# Artigos mais citados (geral)
CR_articles <- citations(M, field = "article", sep = ";")
top_cited_articles <- CR_articles$Cited[1:10]
print(top_cited_articles)

# Autores mais citados (em geral)
CR_authors <- citations(M, field = "author", sep = ";")
top_cited_authors <- CR_authors$Cited[1:10]
print(top_cited_authors)

# intra-country (SCP) and inter-country (MCP) collaboration indices
plot(x = resultados, k = 10, pause = FALSE)

## Temas Emergentes (Thematic Map)
# Em seguida, gere o mapa temático
thematicMap(M, field = "DE", n = 250, minfreq = 5, stemming = FALSE, size = 0.5)

# Co-ocorrência de palavras-chave (para mapear temas semântico-conceituais)
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")
networkPlot(NetMatrix, n = 40, Title = "Mapa de co-ocorrência de palavras-chave", type = "fruchterman", size = TRUE)


threeFieldsPlot(M, fields = c("CR", "AU", "DE"), n = c(20, 20, 20))


# Artigos mais citados
CR <- citations(M, field = "article", sep = ";")
cbind(CR$Cited[1:10])

# Autores mais citados
CR_Aut <- citations(M, field = "author", sep = ";")
cbind(CR_Aut$Cited[1:10])

# Autores mais citados dentro de uma mesma revista
CR_Aut_Loc <- localCitations(M, sep = ";")
CR_Aut_Loc$Authors[1:10,]


# Produ??o hist?rica dos autores
topAU <- authorProdOverTime(M, k = 10, graph = TRUE)




#chame a vers?o do pacote em shiny
biblioshiny()

# Para importar os arquivos no Shiny
# entre na guia Data
# data - Import or Load





R.version

# caso necessite atualizar o R

#instale o pacote de atualiza??o e o execute 
#install.packages("installr")
#library(installr)

#updateR()


