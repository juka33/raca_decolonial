# Normalização de citações

### =============================
### 0. Configuração Inicial
### =============================

rm(list = ls(all = TRUE))  # Limpa a memória
par(mfrow = c(1, 1))

# Pacotes necessários
library(dplyr)
library(stringr)
library(bibliometrix)

# 1. Carregar dados
arquivo_rds <- "C:/R_Projects/raca_decolonial_cientometria/data/bibli_data_race_racial.rds"
M <- readRDS(arquivo_rds)


sum(is.na(M$CR) | trimws(M$CR) == "")



# 2. Definir regras de normalização
regras_normalizacao <- list(
  # DAVIS ANGELA
  "DAVIS A\\.,?\\s.*MULHERES.*CLASSE" = "DAVIS A., MULHERES, RAÇA E CLASSE, (2016)",
  "DAVIS ANGELA\\.,?\\s2016.*CLASSE" = "DAVIS A., MULHERES, RAÇA E CLASSE, (2016)",
  
  # WAGLEY
  "WAGLEY C\\.,?\\s.*RACE AND CLASS.*BRAZIL" = "WAGLEY C., RACE AND CLASS IN RURAL BRAZIL, (1952)",
  
  # ALMEIDA SILVIO
  "ALMEIDA SILVIO LUIZ.*RACISMO ESTRUTURAL" = "ALMEIDA S., O QUE É RACISMO ESTRUTURAL?, (2018)",
  
  # BOXER
  "BOXER.*IGREJA.*IB[ÉE]RICA" = "BOXER C. R., IGREJA MILITANTE E A EXPANSÃO IBÉRICA, 1440-1770, (2007)",
  "BOXER, (2007)" = "BOXER C. R., IGREJA MILITANTE E A EXPANSÃO IBÉRICA, 1440-1770, (2007)",
  
  # CARNEIRO SUELI
  "CARNEIRO SUELI.*MOVIMENTO.*PP.*117-13[23]" = "CARNEIRO S., MULHERES EM MOVIMENTO, (2003)"
)

# 3. Função para normalizar cada referência individual
normalizar_referencia <- function(ref, regras) {
  ref <- str_trim(ref)
  for (regra in names(regras)) {
    if (str_detect(ref, regra)) {
      return(regras[[regra]])
    }
  }
  return(ref)
}

# 4. Função para aplicar ao campo CR (linha por linha)
corrigir_cr <- function(linha_cr) {
  if (is.na(linha_cr) || linha_cr == "") return(NA)
  refs <- str_split(linha_cr, ";")[[1]]
  refs_corrigidas <- sapply(refs, normalizar_referencia, regras = regras_normalizacao)
  paste(refs_corrigidas, collapse = "; ")
}

# 5. Aplicar de forma segura
M <- M %>%
  mutate(CR = sapply(CR, corrigir_cr))

# 5. Salvar objeto corrigido
arquivo_saida <- "bibli_data_race_racial_cr_corrigido.rds"
saveRDS(M, arquivo_saida)


biblioshiny()


M$CR <- sapply(M$CR, normalizar_referencia, regras = regras_normalizacao)

cat("✅ Normalização concluída.\n")

# 5. Salvar objeto corrigido
arquivo_saida <- "bibli_data_race_racial_cr_corrigido.rds"
saveRDS(M, arquivo_saida)
cat("💾 Arquivo salvo como:", arquivo_saida, "\n")

head(M)

biblioshiny()

# Renomear a coluna
M_biblio <- M_corrigido_au %>%
  select(-CR) %>%
  rename(CR = CR_raw)

# Garantir que CR seja string única por linha, sem NAs
M_biblio_limpo <- M_biblio %>%
  filter(!is.na(CR), CR != "") %>%        # remove NAs e vazios
  mutate(CR = as.character(CR))           # garante que é character

local_cr <- localCitations(M_biblio_limpo)


top_local_cr <- head(
  local_cr$Papers[order(local_cr$Papers$LCS, decreasing = TRUE), ],
  20
)

print(top_local_cr)

top_autores_local <- head(
  local_cr$Authors[order(local_cr$Authors$LocalCitations, decreasing = TRUE), ],
  20
)

print(top_autores_local)



str(local_cr)

names(local_cr)




# 6. Análise local de citações (já com CR corrigido)
cat("📊 Calculando referências mais citadas localmente...\n")
local_cr <- localCitations(M_biblio)
top_local_cr <- head(local_cr$Cited[order(local_cr$Cited$LocalCitations, decreasing = TRUE), ], 20)

print(top_local_cr)

# Fim do script
cat("✅ Script finalizado com sucesso.\n")