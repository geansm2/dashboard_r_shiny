# Script para Geração de Dados Sintéticos (Vendas Operacionais e Financeiras)
# Objetivo: Criar um dataset para o dashboard Shiny

library(tidyverse)
library(lubridate)

set.seed(42) # Garantir reprodutividade

# Configurações
n_pedidos <- 1000
categorias <- c("Eletrônicos", "Móveis", "Vestuário", "Beleza", "Esportes")
regioes <- c("Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul")

# Gerando os dados
df_vendas <- tibble(
  id_pedido = seq(1, n_pedidos),
  data_pedido = sample(seq(as.Date('2023-01-01'), as.Date('2023-12-31'), by="day"), n_pedidos, replace = TRUE),
  categoria = sample(categorias, n_pedidos, replace = TRUE),
  regiao = sample(regioes, n_pedidos, replace = TRUE, prob = c(0.1, 0.2, 0.1, 0.4, 0.2)),
  preco_venda = runif(n_pedidos, 50, 2000),
  custo_produto = preco_venda * runif(n_pedidos, 0.4, 0.7),
  frete = preco_venda * runif(n_pedidos, 0.05, 0.15)
) %>%
  mutate(
    # Adicionando Lead Time (tempo de entrega entre 2 e 15 dias)
    dias_entrega = sample(2:15, n_pedidos, replace = TRUE),
    data_entrega = data_pedido + days(dias_entrega),
    # Cálculos financeiros
    margem_lucro = preco_venda - custo_produto - frete,
    mes_pedido = floor_date(data_pedido, "month")
  )

# Salvando os dados
write_csv(df_vendas, "data/vendas_operacionais.csv")

message("Dataset gerado com sucesso em data/vendas_operacionais.csv")
