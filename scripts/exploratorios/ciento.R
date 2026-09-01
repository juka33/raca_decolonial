# Pacotes
library(bibliometrix)
library(dplyr)
library(stringr)

# Caminho do arquivo
arquivo <- "C:/R_Projects/raca_decolonial_cientometria/raca_scopus.csv"

# 1. Carregar os dados da Scopus
scopus_data <- convert2df(arquivo, dbsource = "scopus", format = "csv")

# 2. Criar matriz de co-citação e top 20
CR_matrix <- biblioNetwork(scopus_data, analysis = "co-citation", network = "references", sep = ";")
cited_refs <- sort(rowSums(CR_matrix), decreasing = TRUE)
top_ref_names <- names(cited_refs[1:20])

# 3. Extrair sobrenome e ano
extract_surname_year <- function(ref) {
  ref_clean <- gsub("\\s+", " ", ref) # tira espaços múltiplos
  ref_clean <- str_remove_all(ref_clean, "\\(.*?\\)") # remove (título)
  m <- str_match(ref_clean, "^([A-ZÁÉÍÓÚÇÑ\\-]+)[^0-9]*([1-2][0-9]{3})")
  data.frame(
    raw = ref,
    surname = m[, 2],
    year = m[, 3],
    stringsAsFactors = FALSE
  )
}

top_ref_info <- extract_surname_year(top_ref_names)

# 4. Filtrar artigos que citam essas top referências
matches <- lapply(1:nrow(top_ref_info), function(i) {
  term <- top_ref_info$surname[i]
  year <- top_ref_info$year[i]
  if (!is.na(term) && !is.na(year)) {
    grep(paste0(term, ".*", year), scopus_data$CR, ignore.case = TRUE)
  } else {
    integer(0)
  }
})

# 5. Consolidar os resultados
article_ids <- unique(unlist(matches))
citantes_top <- scopus_data[article_ids, c("SR", "AU", "TI", "CR")]

# 6. Visualizar os artigos citantes
print(citantes_top)
