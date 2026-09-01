library(dplyr)
library(stringr)
library(readxl)
library(readr)

# 1. Carregar a base principal
M_corrigido_au <- readRDS("C:/R_Projects/raca_decolonial_cientometria/data/final/bibliometric_data_cor.rds")

# 2. Carregar os resumos corrigidos
resumos_corrigidos <- read_excel("C:/R_Projects/raca_decolonial_cientometria/data/final/abstracts_en.xlsx")

# 3. Juntar os dados pelo DOI (DI)
dados_atualizados <- M_corrigido_au %>%
  left_join(resumos_corrigidos, by = "DI") %>%
  mutate(
    abstract_final = case_when(
      !is.na(AB_traduzido) & AB_traduzido != "" ~ AB_traduzido,
      TRUE ~ AB
    )
  ) %>%
  filter(
    !is.na(abstract_final),
    !str_detect(tolower(abstract_final), "\\[?no abstract available\\]?")
  )

# 4. Função para formatar autores corretamente
formatar_autores <- function(autores) {
  autores %>%
    str_split(";") %>%
    unlist() %>%
    str_squish() %>%
    tolower() %>%
    str_replace_all(" ", "_") %>%
    paste0("*", .) %>%
    paste(collapse = " ")
}

# 5. Aplicar a função linha a linha (rowwise)
dados_formatado <- dados_atualizados %>%
  rowwise() %>%
  mutate(
    autores_formatados = formatar_autores(AU),
    header = paste0("**** ", autores_formatados, " *", PY),
    bloco = paste(header, abstract_final, sep = "\n")
  ) %>%
  ungroup()

# 6. Exportar para IRaMuTeQ com quebra de linha entre documentos
write_lines(dados_formatado$bloco, "corpus_iramuteq_corrigido.txt", sep = "\n\n")

cat("✅ Corpus gerado com sucesso: 'corpus_iramuteq_corrigido.txt'\n")
