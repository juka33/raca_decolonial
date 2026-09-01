# Carrega pacotes
library(readr)
library(dplyr)
library(stringr)
library(tidyverse)
library(cld3)

# Lê o objeto RDS corrigido
M <- readRDS("C:/R_Projects/raca_decolonial_cientometria/data/bibli_data_race_racial.rds")

head(M)

dados_texto <- M %>%
  select(AU, PY, AB) %>%
  filter(
    !is.na(AB),
    AB != "",
    trimws(AB) != "[NO ABSTRACT AVAILABLE]"
  )

cat("Total de artigos com resumo real:", nrow(dados_texto), "\n")


# Detectar idioma de cada resumo
dados_texto$idioma <- cld3::detect_language(dados_texto$AB)

# Contar frequências
idiomas_freq <- table(dados_texto$idioma)
print(idiomas_freq)


dados_nao_ingles <- dados_texto %>% 
  filter(idioma != "en") %>%
  select(AU, PY, AB, idioma)

write_csv(dados_nao_ingles, "abstracts_nao_ingles.csv")

# Remover as traduções do abstract
dados_texto <- dados_texto %>%
  mutate(
    abstract_en = str_trim(str_extract(AB, "^[^;]+"))  # extrai tudo até o primeiro ";"
  ) %>%
  filter(!is.na(abstract_en) & abstract_en != "")  # remove se ficou vazio por erro

# Verificar as primeiras linhas
head(dados_texto$abstract_en, 3)

# Função de pré-processamento
preprocess_abstract <- function(text) {
  text |>
    iconv(from = "UTF-8", to = "ASCII//TRANSLIT") |>  # remove acentos
    tolower() |>                                      # caixa baixa
    str_replace_all("[^a-z ]", " ") |>                # remove tudo que não for letra
    str_squish()                                      # colapsa espaços
}

# Aplicar ao dataset
dados_texto <- dados_texto %>%
  mutate(abstract_clean = preprocess_abstract(abstract_en))

# Ver exemplo
cat(dados_texto$abstract_clean[1])

# Função corrigida para adicionar * antes de cada autor
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

# Criar os headers corretamente
dados_texto_fmt <- dados_texto %>%
  mutate(
    autores_fmt = sapply(AU, formatar_autores),
    header = paste0("**** ", autores_fmt, " *", PY)
  )

# Caminho do arquivo de saída
arquivo_saida <- "corpus_iramuteq_formatado.txt"

# Exportar no formato correto para IRaMuTeQ
write_lines(
  paste(
    dados_texto_fmt$header,
    dados_texto_fmt$abstract_clean,
    "",  # quebra de linha entre os documentos
    sep = "\n"
  ),
  arquivo_saida,
  sep = "\n"
)

cat("Arquivo salvo com sucesso em:", arquivo_saida)
