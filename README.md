# Entre epistemologias e silêncios — materiais suplementares

Materiais suplementares (scripts em R, base de artigos e saídas do IRaMuTeQ) associados ao artigo:

> **Silva Junior, Nivaldo da.** (2026). Entre epistemologias e silêncios: uma análise crítica da produção acadêmica brasileira sobre raça e suas referências teóricas. *Tempo Social*, 38(2), 1–27. https://doi.org/10.11606/0103-2070.ts.2026.240727

- Página do artigo: https://revistas.usp.br/ts/pt_BR/article/view/240727
- Periódico: [Tempo Social — Revista de Sociologia da USP](https://revistas.usp.br/ts) (ISSN 0103-2070)
- Licença do artigo: [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)

---

## Sobre o artigo

O estudo analisa criticamente a produção acadêmica brasileira sobre raça a partir de **241 artigos** indexados na Scopus e na Web of Science. A análise cientométrica foi conduzida em R com o pacote `bibliometrix`, e a análise textual dos resumos foi conduzida no **IRaMuTeQ** (classificação hierárquica descendente, especificidades, estatísticas lexicais e nuvens de palavras).

Palavras-chave: raça, cientometria, epistemologias negras, feminismo negro, decolonialidade.

---

## Natureza deste repositório

Este **não** é um pacote de replicação automatizada. É um registro retrospectivo e honesto do material efetivamente utilizado na pesquisa, disponibilizado para fins de transparência metodológica e reuso acadêmico. Em particular:

- Os scripts são disponibilizados **na forma histórica preservada pelo autor**, incluindo caminhos absolutos do tipo `C:/R_Projects/raca_decolonial_cientometria/...`. Quem quiser executá-los precisará adaptar esses caminhos.
- Alguns scripts contêm **blocos exploratórios, comentados ou executados fora de ordem**, típicos de trabalho interativo no RStudio.
- Etapas relevantes do fluxo foram **manuais ou por interface gráfica**: filtragem de artigos fora do escopo, unificação de duplicatas, correção de nomes de autores, correção/tradução de resumos, uso do `biblioshiny()` e uso do IRaMuTeQ. Essas etapas estão descritas no artigo e nos comentários dos scripts, mas não são reproduzíveis por execução automática.
- Os **arquivos brutos exportados da Scopus e da Web of Science não são redistribuídos** aqui, por restrição de licença dessas bases. O repositório documenta como a coleta foi feita para que ela possa ser refeita por quem tenha acesso institucional.

---

## Estrutura

```
.
├── scripts/                     Scripts em R do fluxo principal
│   ├── biblio_organizado.R          (1) importação, merge WoS+Scopus, deduplicação, filtragem
│   ├── normalizar_citacoes.R        (2) normalização do campo de referências citadas (CR)
│   ├── normalizar_arigos_resumos.R  (3) exportação de resumos para revisão/tradução manual
│   ├── resumos_para_iramuteq.R      (4) montagem do corpus formatado para o IRaMuTeQ
│   ├── analise_biblio.R             (5) análises bibliométricas, mapas temáticos, redes
│   └── exploratorios/               scripts anteriores e de estudo, preservados
├── dados/
│   ├── wos_scopus_filtrados.rds     base final de artigos (objeto bibliometrix)
│   ├── lista_artigos_para_filtragem.csv  listagem de artigos (título, autores, ano, fonte)
│   ├── Scopus_exported_refine_values.csv valores agregados exportados da Scopus
│   ├── autores_para_corrigir.xlsx   planilha de correspondência usada na correção de autores
│   └── curadoria_resumos/           tabelas da revisão e tradução manual dos resumos
├── figuras/                      figuras finais utilizadas no artigo
├── iramuteq/
│   ├── corpus_iramuteq_corrigido.txt         corpus final formatado para o IRaMuTeQ
│   └── corpus_iramuteq_corrigido_corpus_2/   saídas do IRaMuTeQ
│       ├── ..._stat_1/         estatísticas lexicais (formas ativas, hapax, Zipf)
│       ├── ..._alceste_2/      classificação hierárquica descendente (CHD/Reinert)
│       ├── ..._spec_1/         especificidades e AFC por modalidade
│       ├── ..._wordcloud_1/    nuvem de palavras
│       └── ..._wordcloud_2/    nuvem de palavras (segunda configuração)
├── MANIFEST.csv                 inventário de todos os arquivos deste repositório
├── CITATION.cff                 instruções de citação
└── LICENSE                      licença do código (MIT)
```

---

## Ordem de execução do fluxo

A numeração abaixo reconstrói a sequência lógica; os nomes dos arquivos foram preservados como no projeto original.

1. **`biblio_organizado.R`** — importa `wos_raca.txt` (Web of Science, plaintext) e `scopus_raca.csv` (Scopus, CSV) com `convert2df()`, une as bases com `mergeDbSources(remove.duplicated = TRUE)`, substitui `CR` por `CR_raw`, exporta a listagem de artigos para triagem manual, remove títulos fora do escopo temático, resolve duplicatas remanescentes e aplica a planilha de correção de autores (`autores_para_corrigir.xlsx`). Salva `bibliometric_data.rds` / `bibliometric_data_cor.rds`.
2. **`normalizar_citacoes.R`** — aplica regras de expressão regular ao campo `CR` para unificar variantes de referências citadas (por exemplo, as diversas grafias de Davis, Almeida, Boxer, Carneiro), passo necessário para as análises de co-citação e de citações locais.
3. **`normalizar_arigos_resumos.R`** — detecta o idioma dos resumos com `cld3`, exporta os resumos em português/não identificados para revisão e tradução manual.
4. **`resumos_para_iramuteq.R`** — reincorpora os resumos traduzidos (`abstracts_en.xlsx`), formata cabeçalhos de variáveis no padrão IRaMuTeQ (`**** *autor *ano`) e grava `corpus_iramuteq_corrigido.txt`.
5. **`analise_biblio.R`** — análises descritivas (`biblioAnalysis`), citações por artigo e por autor, redes de co-ocorrência de palavras-chave, mapas temáticos, *three fields plot*, produção por autor ao longo do tempo e abertura do `biblioshiny()`.

Os scripts em `scripts/exploratorios/` (`base.R`, `ciento.R`, `bibliometria_muitobom.R`, `abstract_iramuteq.R`) correspondem a versões anteriores e a testes do pacote; são mantidos por transparência e não fazem parte do fluxo final.

## Figuras

A pasta `figuras/` reúne as figuras finais do artigo, geradas com `bibliometrix`/`biblioshiny` e com `ggplot2`. Os nomes foram padronizados para uso em controle de versão; o nome original de cada arquivo está registrado na coluna `nome_original` do `MANIFEST.csv`.

| Arquivo | Conteúdo |
|---|---|
| `producao_cientifica_anual.png` | Produção científica anual do corpus |
| `trend_topics.png` | *Trend topics* no corpus (Keywords Plus) |
| `mapa_tematico_DE_15.png` | Mapa temático, palavras-chave dos autores, 15 termos |
| `mapa_tematico_DE_20.png` | Mapa temático, palavras-chave dos autores, 20 termos |
| `mapa_tematico_palavras_autor.png` | Mapa temático das palavras-chave dos autores |
| `mapa_tematico_keywords_plus.png` | Mapa temático das Keywords Plus |
| `three_fields_plot.png` / `_v2.png` | Diagrama de três campos (referências citadas, autores, palavras-chave) |
| `10_autores_mais_citados.png` / `_v2.png` | Dez autores mais citados no corpus |
| `10_trabalhos_mais_citados.png` | Dez trabalhos mais citados no corpus |
| `obras_lelia_gonzalez_mais_citadas.png` | Obras de Lélia Gonzalez mais citadas (normalizadas) |
| `citacoes_a_lelia_gonzalez.png` | Distribuição anual dos documentos que citam a autora |

## Ambiente

Análise conduzida em R com os pacotes `bibliometrix`, `dplyr`, `readr`, `readxl`, `writexl`, `stringr`, `tidyverse`, `ggplot2` e `cld3`. A análise textual foi feita no [IRaMuTeQ](http://www.iramuteq.org/), que utiliza R e Python.

## Dados

| Fonte | Redistribuída aqui? | Observação |
|---|---|---|
| Web of Science (`wos_raca.txt`) | Não | Exportação bruta sujeita à licença da base. |
| Scopus (`scopus_raca.csv`) | Não | Exportação bruta sujeita à licença da base. |
| Base final integrada (`wos_scopus_filtrados.rds`) | Sim | Objeto derivado, após merge, deduplicação, filtragem e correções manuais. |
| Listagem de artigos (`lista_artigos_para_filtragem.csv`) | Sim | Metadados bibliográficos (título, autores, ano, fonte). |
| Planilhas de curadoria (`autores_para_corrigir.xlsx`, `abstracts_en.xlsx`) | Sim | Tabelas de correspondência preenchidas manualmente pelo autor, insumos dos scripts 1 e 4. |
| Tabelas de curadoria de resumos (`dados/curadoria_resumos/`) | Sim | Contêm resumos integrais tal como indexados nas bases, disponibilizados para documentar a etapa de revisão e tradução manual. |
| Corpus e saídas do IRaMuTeQ | Sim | O corpus contém resumos pré-processados (minúsculas, sem acentos e sem pontuação). |

O uso dos metadados e resumos derivados de Scopus e Web of Science segue os termos dessas bases; o material aqui disponibilizado tem finalidade exclusivamente acadêmica e não comercial.

## Licenças

- **Código** (`scripts/`): [MIT](LICENSE).
- **Documentação e produtos analíticos** (README, `MANIFEST.csv`, figuras, saídas do IRaMuTeQ): [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/), em coerência com a licença do artigo.
- **Metadados bibliográficos de terceiros**: direitos dos respectivos titulares e das bases de origem.

## Como citar

Cite o artigo. Para citar especificamente este repositório, veja `CITATION.cff` ou use o botão "Cite this repository" no GitHub.

## Declaração sobre uso de inteligência artificial

A **organização e a documentação deste repositório** foram elaboradas com o auxílio de um assistente de inteligência artificial (Perplexity Computer), em setembro de 2026. O auxílio compreendeu: a curadoria e a seleção dos arquivos preservados do projeto; a definição da estrutura de pastas; a leitura dos scripts para reconstruir e descrever a sequência do fluxo de trabalho; a redação deste `README.md`; a geração do `MANIFEST.csv`; a preparação do `CITATION.cff`, do `LICENSE` e do `.gitignore`; e a publicação dos arquivos no GitHub.

A **pesquisa** — formulação do problema, decisões teóricas e metodológicas, estratégia de busca nas bases, triagem e filtragem dos artigos, correções manuais de autores e referências, parâmetros das análises, interpretação dos resultados e redação do artigo — é de autoria e responsabilidade exclusivas do autor. Os scripts em `scripts/` foram escritos pelo autor durante a pesquisa e são disponibilizados na forma histórica em que foram preservados; nenhum deles foi reescrito, refatorado ou substituído na preparação deste repositório. Os dados, o corpus e as saídas analíticas aqui depositados são exatamente os produzidos durante a pesquisa, sem regeração.

Nenhum resultado, referência bibliográfica ou dado deste repositório foi gerado por inteligência artificial.

## Contato

Nivaldo da Silva Junior — Universidade Federal de São Carlos (UFSCar) — nivaldo.junior33@gmail.com
