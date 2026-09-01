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

setwd("C:/R_Projects/raca_decolonial_cientometria/data")
cat("📁 Diretório de trabalho:", getwd(), "\n")

### =============================
### 1. Importação e Conversão
### =============================


# Scopus (formato .csv)
M <- convert2df(file = "scopus_race_racial.csv", dbsource = "scopus", format = "csv")

# Merge e tratamento inicial
# M <- mergeDbSources(WOS, SCP, remove.duplicated = TRUE)
# M$CR <- M$CR_raw  # Substitui a coluna CR com CR_raw, se necessário

resultados <- biblioAnalysis(M)
summary(resultados, k = 10, pause = FALSE)


saveRDS(M, file = "bibli_data_race_racial.rds")


plot(resultados, k = 10)

# Citações mais relevantes
CR_articles <- citations(M, field = "article", sep = ";")
print(CR_articles$Cited[1:10])

CR_authors <- citations(M, field = "author", sep = ";")
print(CR_authors$Cited[1:10])

# Co-ocorrência de palavras-chave
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")
networkPlot(NetMatrix, n = 40, Title = "Mapa de co-ocorrência de palavras-chave", type = "fruchterman", size = TRUE)

# Thematic map
thematicMap(
  M, 
  field = "ID", 
  n = 250,
  minfreq = 5,
  ngrams = 1,
  stemming = FALSE,
  size = 0.5,
  n.labels = 1,
  community.repulsion = 0.1,
  repel = TRUE,
  remove.terms = NULL,
  synonyms = NULL,
  cluster = "walktrap",
  subgraphs = FALSE
  )

plot(biblioNetwork(
  M,
  analysis = "coupling",
  network = "authors",
  n = NULL,
  sep = ";",
  short = FALSE,
  shortlabel = TRUE,
  remove.terms = NULL,
  synonyms = NULL
)
)


# Três campos
threeFieldsPlot(M, fields = c("CR", "AU", "DE"), n = c(20, 20, 20))

# Produção ao longo do tempo
authorProdOverTime(M_corrigido_au, k = 10, graph = TRUE)

# Abrir interface biblioshiny
biblioshiny()









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
  "A COMBINATORIAL AUCTION-BASED COLLABORATIVE CLOUD SERVICES PLATFORM",
  "A RANDOMIZED ANT COLONY ALGORITHM FOR CONTINUOUS FUNCTION OPTIMIZATION",
  "ACCESS CONTROL WITH ROLE ATTRIBUTE CERTIFICATES",
  "ACETYLOME ANALYSIS OF ACETYLATION PROVIDING NEW INSIGHT INTO SCLEROTIAL GENERATION IN MEDICINAL FUNGUS POLYPORUS UMBELLATUS",
  "AID IN DYING: A CONSIDERATION OF TWO PERSPECTIVES",
  "ANTHROPOGENIC IMPACT ON SOILS IN THE URBAN DISTRICT OF BRATISLAVA- RAČA; [ANTROPOGÉNNY VPLYV NA PÔDY MESTSKEJ ČASTI BRATISLAVA-RAČA]",
  "APPLICATION OF MECHANICAL CARDIOPULMONARY RESUSCITATION DEVICES AND THEIR VALUE IN OUT-OF-HOSPITAL CARDIAC ARREST: A RETROSPECTIVE ANALYSIS OF THE GERMAN RESUSCITATION REGISTRY",
  "BIOCULTURAL ANALYSIS OF SEX DIFFERENCES IN MORTALITY PROFILES AND STRESS LEVELS IN THE LATE MEDIEVAL POPULATION FROM NOVA RACA, CROATIA",
  "CELL DIVISION MACHINERY DRIVES CELL-SPECIFIC GENE ACTIVATION DURING DIFFERENTIATION IN BACILLUS SUBTILIS",
  "DENTAL DISEASE IN THE LATE MEDIEVAL POPULATION FROM NOVA RAČA, CROATIA",
  "FITTING MATHEMATICAL MODELS TO LACTATION CURVES FROM HOLSTEIN COWS IN THE SOUTHWESTERN REGION OF THE STATE OF PARANA, BRAZIL",
  "GENETIC PARAMETERS OF POZOLERO MAIZE: ‘ELOTES OCCIDENTALES’ RACE; [PARÂMETROS GENÉTICOS DO MILHO POZOLERO: RAÇA 'ELOTES OCCIDENTALES']; [PARÁMETROS GENÉTICOS DE MAÍZ POZOLERO: RAZA ‘ELOTES OCCIDENTALES’]",
  "HYBRID-RACA: HYBRID RETRIEVAL-AUGMENTED COMPOSITION ASSISTANCE FOR REAL-TIME TEXT PREDICTION",
  "INFLUENCE OF PRODUCTION LEVEL, NUMBER, AND STAGE OF LACTATION ON MILK QUALITY IN COMPOST BARN SYSTEMS",
  "KING COLOMAN'S ROAD IN THE WESTERN PARTS OF THE REGION BETWEEN THE RIVERS SAVA AND DRAVA; [CESTA KRALJA KOLOMANA U ZAPADNOM MEDURIJEČJU SAVE I DRAVE]",
  "NEW FINDINGS OF SWORDS, FROM THE AREA OF BRATISLAVA GATE; [NOVÉ NÁLEZY MEČOV Z PRIESTORU BRATISLAVSKEJ BRÁNY]",
  "POLARITY PROTEINS BEM1 AND CDC24 ARE COMPONENTS OF THE FILAMENTOUS FUNGAL NADPH OXIDASE COMPLEX",
  "RACA, A BACTERIAL PROTEIN THAT ANCHORS CHROMOSOMES TO THE CELL POLES",
  "RACA-MEDIATED ROS SIGNALING IS REQUIRED FOR POLARIZED CELL DIFFERENTIATION IN CONIDIOGENESIS OF ASPERGILLUS FUMIGATUS",
  "REFERENCE-ASSISTED CHROMOSOME ASSEMBLY",
  "RELATION ALGEBRA REDUCTS OF CYLINDRIC ALGEBRAS AND COMPLETE REPRESENTATIONS",
  "ROMA KORTURARE, KAJ ŽANAS LE VURDONENCA: SOME ETHNOGRAPHIC ANSWERS TO THE ROMANI DIALECTOLOGICAL SURVEY",
  "SI RACA APP IN QUANTUM LEARNING, IS IT EFFECTIVE TO BE IMPLEMENTED IN EARLY READING MATERIAL FOR PRIMARY SCHOOL?",
  "SUBADULT STRESS IN THE MEDIEVAL AND EARLY MODERN POPULATIONS OF CONTINENTAL CROATIA; [SUBADULTNI STRES U SREDNJOVJEKOVNIM I NOVOVJEKOVNIM POPULACIJAMA KONTINENTALNE HRVATSKE]",
  "THE ACCOUNT BOOK OF THE WAQF OF HADŽI ALIJA FROM BRČKO IN THE ARCHIVE OF THE FRANCKE FOUNDATION IN HALLE; [OBRAČUNSKA KNJIGA VAKUFA HADŽI ALIJE IZ BRČKOG U ARHIVU FRANCKEOVE ZAKLADE U HALLEU]",
  "THE DE JONGH BROTHERS AND THE PHOTOGRAPHS OF PULA’S GERMAN LANGUAGE STATE GYMNASIUM; [RAĆA DE JONGH I FOTOGRAFIJE DRŽAVNE NJEMAČKE GIMNAZIJE U PULI]",
  "THE EFFECT OF REFLECTIVE ACTIVITIES ON REFLECTIVE THINKING ABILITY IN AN UNDERGRADUATE PHARMACY CURRICULUM",
  "THE STRUCTURE, ACTIVITY AND LIQUIDATION OF THE DANUBE-SAVA VICINAL RAILWAY STOCK COMPANY DURING THE KINGDOM OF SERBS, CROATS, AND SLOVENES/YUGOSLAVIA",
  "THE TRANSCRIPTOMIC SIGNATURE OF RACA ACTIVATION AND INACTIVATION PROVIDES NEW INSIGHTS INTO THE MORPHOGENETIC NETWORK OF ASPERGILLUS NIGER",
  "UNKNOWN EXTINCT VILLAGES IN THE ČESKÁ LÍPA DISTRICT; [NEZNÁMÉ ZANIKLÉ VESNICE NA ČESKOLIPSKU]"
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

saveRDS(M_final, file = "wos_scopus_filtrados.rds")

### =============================
### 4. Correção de Autores (Manual via Planilha)
### =============================

# Exporta planilha para correção externa
M_export <- M_final %>%
  select(AU, AF, AU_UN, TI, SO, PY, CR) %>%
  mutate(AU_corrigido = NA)

write_xlsx(M_export, "autores_para_corrigir.xlsx")

# Após edição, importar correções
correcao_au <- read_xlsx("autores_para_corrigir.xlsx") %>%
  select(TI, AU_corrigido)

# Aplicar correção
M_corrigido_au <- M_final %>%
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

# Citações mais relevantes
CR_articles <- citations(M_corrigido_au, field = "article", sep = ";")
print(CR_articles$Cited[1:10])

CR_authors <- citations(M_corrigido_au, field = "author", sep = ";")
print(CR_authors$Cited[1:10])

# Co-ocorrência de palavras-chave
NetMatrix <- biblioNetwork(M_corrigido_au, analysis = "co-occurrences", network = "keywords", sep = ";")
networkPlot(NetMatrix, n = 40, Title = "Mapa de co-ocorrência de palavras-chave", type = "fruchterman", size = TRUE)

# Thematic map
thematicMap(M_corrigido_au, field = "DE", n = 250, minfreq = 5, stemming = FALSE, size = 0.5)

# Três campos
threeFieldsPlot(M_corrigido_au, fields = c("CR", "AU", "DE"), n = c(20, 20, 20))

# Produção ao longo do tempo
authorProdOverTime(M_corrigido_au, k = 10, graph = TRUE)

# Abrir interface biblioshiny
biblioshiny()
