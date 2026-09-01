library(dplyr)
library(readr)

# Carregar a base corrigida
dados <- readRDS("C:/R_Projects/raca_decolonial_cientometria/data/final/bibliometric_data_cor.rds")

# Selecionar colunas relevantes
dados_export <- dados %>%
  select(
    autor = AU,     # autores
    ano = PY,       # ano de publicação
    titulo = TI,    # título do artigo
    resumo = AB,    # abstract
    doi = DI        # DOI
  )

# Salvar para limpeza manual
write_csv(dados_export, "C:/R_Projects/raca_decolonial_cientometria/data/final/resumos_para_limpeza_manual.csv")

cat("✅ Arquivo 'resumos_para_limpeza_manual.csv' salvo com sucesso.\n")


# Instale se necessário:
# install.packages("cld3")

library(cld3)
library(dplyr)


# Aplica a função de detecção de idioma
dados_idiomas <- dados %>%
  mutate(idioma_abstract = cld3::detect_language(AB))

# Frequência dos idiomas detectados
idiomas_freq <- table(dados_idiomas$idioma_abstract)
print(idiomas_freq)


library(dplyr)
library(readr)

# Subset com resumos em português ou não identificados
abstracts_pt <- dados_idiomas %>%
  filter(idioma_abstract %in% c("pt", "ig")) %>%
  select(AU, PY, TI, AB, DI)

# Exportar para revisão e substituição manual
write_csv(abstracts_pt, "C:/R_Projects/raca_decolonial_cientometria/data/final/abstracts_para_traduzir.csv")
cat("✅ Arquivo 'abstracts_para_traduzir.csv' salvo com sucesso.")



