### =============================
### 0. Configuração Inicial
### =============================

rm(list = ls(all = TRUE))  # Limpa a memória
par(mfrow = c(1, 1))

library(bibliometrix)
library(dplyr)
library(readr)
library(readxl)
library(writexl)
library(ggplot2)

setwd("C:/R_Projects/raca_decolonial_cientometria/data/final")
cat("📁 Diretório de trabalho:", getwd(), "\n")

### =============================
### 1. Importação e Conversão
### =============================

# Web of Science (formato .txt)
WOS <- convert2df(file = "wos_raca.txt", dbsource = "wos", format = "plaintext")

# Scopus (formato .csv)
SCP <- convert2df(file = "scopus_raca.csv", dbsource = "scopus", format = "csv")

# Merge e tratamento inicial
M <- mergeDbSources(WOS, SCP, remove.duplicated = TRUE)
M$CR <- M$CR_raw  # Substitui a coluna CR com CR_raw, se necessário

saveRDS(M, file = "bibliometric_data.rds")

### =============================
### 2. Filtragem de Artigos Relevantes
### =============================

# Exportar lista de artigos para revisão manual
listagem_artigos <- M %>%
  select(TI, AU, PY, SO) %>%
  arrange(TI)
write_csv(listagem_artigos, "lista_artigos_para_filtragem.csv")

# Artigos a excluir (fora do escopo temático)
titulos_excluir <- c(
  "ANÁLISE ECONÔMICA DA PRODUÇÃO DE OVINOS EM LOTAÇÃO ROTATIVA EM PASTAGEM DE CAPIM TANZÂNIA (PANICUM MAXIMUM (JACQ))",
  "FITTING MATHEMATICAL MODELS TO LACTATION CURVES FROM HOLSTEIN COWS IN THE SOUTHWESTERN REGION OF THE STATE OF PARANA, BRAZIL",
  "INFLUENCE OF PRODUCTION LEVEL, NUMBER, AND STAGE OF LACTATION ON MILK QUALITY IN COMPOST BARN SYSTEMS",
  "FEMININITIES AND MASCULINITIES IN THE CONTEMPORARY SCENE: ANALYSIS OF THE SPECTACLE CAMINHO DA SEDA, BY SAO PAULO'S RACA DANCE COMPANY"
  
)

M_filtrado <- M %>% filter(!(TI %in% titulos_excluir))

### =============================
### 3. Unificação de Duplicatas Manuais
### =============================

titulos_para_manter <- c(
  "CULINARY AND FOOD IN THE WORKS OF GILBERTO FREYRE: RACE, IDENTITY AND MODERNITY; [CULINÁRIA E ALIMENTAÇÃO EM GILBERTO FREYRE: RAÇA, IDENTIDADE E MODERNIDADE]",
  "FEMININITIES AND MASCULINITIES IN THE CONTEMPORARY SCENE: ANALYSIS OF THE SPECTACLE CAMINHO DA SEDA, BY SÃO PAULO’S RAÇA DANCE COMPANY; [FEMINILIDADES E MASCULINIDADES NA CENA CONTEMPORÂNEA: ANÁLISE DO ESPETÁCULO CAMINHO DA SEDA - RAÇA CIA DE DANÇA DE SÃO PAULO]; [FEMINIDADES Y MASCULINIDADES EN LA ESCENA CONTEMPORÁNEA: ANÁLISIS DE LO ESPECTÁCULO CAMINHO DA SEDA - RAÇA CIA DE DANZA DE SÃO PAULO]"
)

titulos_duplicados <- c(
  "CULINARY AND FOOD IN GILBERTO FREYRE: RACE, IDENTITY AND MODERNITY; [CULINÁRIA E ALIMENTAÇÃO EM GILBERTO FREYRE: RAÇA, IDENTIDADE E MODERNIDADE]",
  "CULINARY AND FOOD IN THE WORKS OF GILBERTO FREYRE: RACE, IDENTITY AND MODERNITY; [CULINÁRIA E ALIMENTAÇÃO EM GILBERTO FREYRE: RAÇA, IDENTIDADE E MODERNIDADE]",
  "FEMININITIES AND MASCULINITIES IN THE CONTEMPORARY SCENE: ANALYSIS OF THE SPECTACLE CAMINHO DA SEDA, BY SAO PAULO'S RACA DANCE COMPANY",
  "FEMININITIES AND MASCULINITIES IN THE CONTEMPORARY SCENE: ANALYSIS OF THE SPECTACLE CAMINHO DA SEDA, BY SÃO PAULO’S RAÇA DANCE COMPANY; [FEMINILIDADES E MASCULINIDADES NA CENA CONTEMPORÂNEA: ANÁLISE DO ESPETÁCULO CAMINHO DA SEDA - RAÇA CIA DE DANÇA DE SÃO PAULO]; [FEMINIDADES Y MASCULINIDADES EN LA ESCENA CONTEMPORÁNEA: ANÁLISIS DE LO ESPECTÁCULO CAMINHO DA SEDA - RAÇA CIA DE DANZA DE SÃO PAULO]"
)

M_final <- M_filtrado %>%
  filter(!(TI %in% titulos_duplicados)) %>%
  bind_rows(M_filtrado %>% filter(TI %in% titulos_para_manter))

saveRDS(M_filtrado, file = "wos_scopus_filtrados.rds")

### =============================
### 4. Correção de Autores (Manual via Planilha)
### =============================

# Exporta planilha para correção externa
M_export <- M_filtrado %>%
  select(AU, AF, AU_UN, TI, SO, PY, CR) %>%
  mutate(AU_corrigido = NA)

write_xlsx(M_export, "autores_para_corrigir.xlsx")

# Após edição, importar correções
correcao_au <- read_xlsx("autores_para_corrigir.xlsx") %>%
  select(TI, AU_corrigido)

# Aplicar correção
M_corrigido_au <- M_filtrado %>%
  left_join(correcao_au, by = "TI") %>%
  mutate(AU = ifelse(!is.na(AU_corrigido), AU_corrigido, AU)) %>%
  select(-AU_corrigido)

saveRDS(M_corrigido_au, "bibliometric_data_cor.rds")

### =============================
### 5. Análises Bibliométricas
### =============================

resultados <- biblioAnalysis(M_corrigido_au)
summary(resultados, k = 10, pause = FALSE)

plot(resultados, k = 10)


sapply(resultados, function(x) sum(is.na(x)))

str(resultados, max.level = 1)


# Extrair os 10 autores mais produtivos
top_autores <- resultados$Authors %>%
  as.data.frame() %>%
  tibble::rownames_to_column("author") %>%
  rename(articles = Freq) %>%
  slice_max(order_by = articles, n = 10)

# Plot
ggplot(top_autores, aes(x = reorder(author, articles), y = articles)) +
  geom_col(fill = "#1f77b4") +
  coord_flip() +
  labs(title = "Autores mais produtivos",
       x = "Autor",
       y = "Número de artigos") +
  theme_minimal()



# Citações mais relevantes
CR_articles <- citations(M_corrigido_au, field = "article", sep = ";")
print(CR_articles$Cited[1:10])

CR_authors <- citations(M_corrigido_au, field = "author", sep = ";")
print(CR_authors$Cited[1:10])

# Criar data.frame excluindo "ANONYMOUS"
df_autores <- data.frame(
  Autor = names(CR_authors$Cited),
  Citacoes = as.numeric(CR_authors$Cited)
) %>%
  filter(toupper(Autor) != "ANONYMOUS") %>%
  slice_max(order_by = Citacoes, n = 10)


ggplot(df_autores, aes(x = reorder(Autor, Citacoes), y = Citacoes)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 autores mais citados", x = "Autor", y = "Citações") +
  theme_minimal()

# Plot
ggplot(df_autores, aes(x = Citacoes, y = reorder(Autor, Citacoes))) +
  geom_segment(aes(x = 0, xend = Citacoes, y = Autor, yend = Autor), color = "grey60") +
  geom_point(aes(size = Citacoes), color = "#08306b", fill = "#08306b", shape = 21, stroke = 1.5) +
  geom_text(aes(label = Citacoes), hjust = 0.5, vjust = 0.35, color = "white", fontface = "bold", size = 4) +
  scale_size(range = c(5, 10)) +
  labs(
    title = "10 autores mais citados",
    x = "Número de citações",
    y = "Trabalhos"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10),
    legend.position = "none"
  )



# Criar data.frame com os dados dos artigos mais citados
df_artigos <- data.frame(
  Artigo = names(CR_articles$Cited)[1:20],
  Citacoes = as.numeric(CR_articles$Cited[1:20])
)

# Extrair ano, se quiser usar depois (não é obrigatório)
df_artigos$Ano <- str_extract(df_artigos$Artigo, "\\(\\d{4}\\)") %>%
  str_remove_all("[()]") %>%
  as.integer()

# Plot
ggplot(df_artigos, aes(x = Citacoes, y = reorder(Artigo, Citacoes))) +
  geom_segment(aes(x = 0, xend = Citacoes, y = Artigo, yend = Artigo), color = "grey60") +
  geom_point(aes(size = Citacoes), color = "#2171b5", fill = "#2171b5", shape = 21, stroke = 1.5) +
  geom_text(aes(label = Citacoes), hjust = 0.5, vjust = 0.35, color = "white", fontface = "bold", size = 4) +
  scale_size(range = c(5, 10)) +
  labs(
    title = "10 trabalhos mais citados",
    x = "Número de citações",
    y = "Trabalhos"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10),
    legend.position = "none"
  )

trendTopics(
  M_corrigido_au,
  field = "ID",        # ou "DE" para palavras-chave dos autores
  n = 10,              # número de termos
  ngrams = 1,          # termos simples; use 2 para bigramas
  min.freq = 5,        # frequência mínima para incluir
  size = 1,            # tamanho do ponto base
  stemming = FALSE,    # manter palavras originais
  labelsize = 0.8,     # tamanho dos rótulos
  year.label = TRUE,   # mostrar anos no eixo X
  ylim = c(NA, NA)     # ou defina um limite Y
)


#fazer trend topics
library(dplyr)
library(tidyr)
library(stringr)

# Remover NAs e explodir os termos
tokens_por_ano <- M_corrigido_au %>%
  filter(!is.na(ID), !is.na(PY)) %>%
  separate_rows(ID, sep = ";") %>%
  mutate(ID = str_trim(ID)) %>%
  filter(ID != "") %>%
  count(ID, PY, name = "freq")

# Termos mais frequentes
top_terms <- tokens_por_ano %>%
  group_by(ID) %>%
  summarise(total = sum(freq)) %>%
  arrange(desc(total)) %>%
  slice_head(n = 10) %>%
  pull(ID)

tokens_filtrados <- tokens_por_ano %>%
  filter(ID %in% top_terms)

library(ggplot2)

ggplot(tokens_filtrados, aes(x = PY, y = ID)) +
  geom_line(aes(group = ID), color = "gray70") +
  geom_point(aes(size = freq), color = "#2171b5", fill = "#2171b5", shape = 21, alpha = 0.9) +
  scale_size_continuous(range = c(3, 10)) +
  labs(
    title = "Trend Topics no corpus (Keywords Plus - ID)",
    x = "Ano",
    y = "Termo",
    size = "Frequência"
  ) +
  theme_minimal(base_size = 13)





# Co-ocorrência de palavras-chave
NetMatrix <- biblioNetwork(M_corrigido_au, analysis = "co-occurrences", network = "keywords", sep = ";")
networkPlot(NetMatrix, n = 40, Title = "Mapa de co-ocorrência de palavras-chave", type = "fruchterman", size = TRUE)

# Thematic map de palavra chave dos autores "DE"
thematicMap(M_corrigido_au, field = "DE", n = 250, minfreq = 20, stemming = FALSE, size = 0.5)

# Thematic map de palavra chave Keywords Plus "ID"
thematicMap(M_corrigido_au, field = "ID", n = 250, minfreq = 1, stemming = TRUE, size = 0.5)

# Três campos
threeFieldsPlot(M_corrigido_au, fields = c("CR", "AU", "ID"), n = c(20, 20, 20))

# Produção ao longo do tempo
authorProdOverTime(M_corrigido_au, k = 10, graph = TRUE)

# Abrir interface biblioshiny
biblioshiny()



