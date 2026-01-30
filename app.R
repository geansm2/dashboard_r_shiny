# ==============================================================================
# PROJETO: Dashboard de Indicadores Operacionais e Financeiros
# OBJETIVO: App Shiny para Portfolio de Portfólio (Gestão de Negócios)
# AUTOR: Gean Machado
# DATA: 2024
# ==============================================================================

# 1. Carregamento de Bibliotecas -----------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(DT)
library(lubridate)

# 2. Pré-processamento e Carga de Dados ----------------------------------------

# Nota: Em um ambiente real, carregaríamos o CSV gerado.
# Para garantir que o app rode de primeira, vou incluir a geração rápida aqui se o arquivo não existir.
if(!file.exists("data/vendas_operacionais.csv")) {
  source("R/generate_data.R")
}

dados <- read_csv("data/vendas_operacionais.csv")

# 3. Interface do Usuário (UI) -------------------------------------------------
ui <- page_navbar(
  title = "Dashboard Operacional & Financeiro",
  theme = bs_theme(version = 5, bootswatch = "cosmo", primary = "#2c3e50"),

  # Sidebar (Filtros Globais)
  sidebar = sidebar(
    title = "Filtros de Análise",
    dateRangeInput("data_filtro", "Período de Análise:",
                   start = min(dados$data_pedido),
                   end = max(dados$data_pedido),
                   language = "pt-BR", separator = " até "),

    selectInput("categoria_filtro", "Categoria de Produto:",
                choices = c("Todas", unique(dados$categoria)),
                selected = "Todas"),

    checkboxGroupInput("regiao_filtro", "Regiões:",
                       choices = unique(dados$regiao),
                       selected = unique(dados$regiao))
  ),

  # Página Principal: Visão Geral
  nav_panel(
    title = "Visão Geral",

    # Linha 1: Cards de KPI
    layout_column_wrap(
      width = 1/4,
      value_box(
        title = "Faturamento Total",
        value = uiOutput("kpi_faturamento"),
        showcase = icon("dollar-sign"),
        theme = "primary"
      ),
      value_box(
        title = "Ticket Médio",
        value = uiOutput("kpi_ticket"),
        showcase = icon("cart-shopping"),
        theme = "info"
      ),
      value_box(
        title = "Lead Time Médio",
        value = uiOutput("kpi_leadtime"),
        showcase = icon("truck"),
        theme = "warning"
      ),
      value_box(
        title = "Margem de Lucro",
        value = uiOutput("kpi_margem"),
        showcase = icon("chart-line"),
        theme = "success"
      )
    ),

    # Linha 2: Gráficos Principais
    layout_column_wrap(
      width = 1/2,
      card(
        card_header("Evolução Mensal (Faturamento vs Margem)"),
        plotlyOutput("plot_evolucao")
      ),
      card(
        card_header("Performance por Categoria"),
        plotlyOutput("plot_categoria")
      )
    )
  ),

  # Página 2: Detalhamento Operacional
  nav_panel(
    title = "Dados Operacionais",
    card(
      card_header("Base de Pedidos Filtrada"),
      DTOutput("tabela_dados")
    )
  ),

  # Rodapé/Informações
  nav_spacer(),
  nav_item(
    tags$a(href = "https://github.com/geansm2", icon("github"), " Perfil GitHub")
  )
)

# 4. Lógica do Servidor (Server) -----------------------------------------------
server <- function(input, output, session) {

  # 4.1 Dados Reativos (Filtrados)
  dados_filtrados <- reactive({
    df <- dados %>%
      filter(data_pedido >= input$data_filtro[1],
             data_pedido <= input$data_filtro[2],
             regiao %in% input$regiao_filtro)

    if (input$categoria_filtro != "Todas") {
      df <- df %>% filter(categoria == input$categoria_filtro)
    }

    return(df)
  })

  # 4.2 Outputs de KPI
  output$kpi_faturamento <- renderUI({
    val <- sum(dados_filtrados()$preco_venda)
    paste0("R$ ", format(round(val, 2), big.mark = ".", decimal.mark = ","))
  })

  output$kpi_ticket <- renderUI({
    val <- mean(dados_filtrados()$preco_venda)
    paste0("R$ ", format(round(val, 2), big.mark = ".", decimal.mark = ","))
  })

  output$kpi_leadtime <- renderUI({
    val <- mean(dados_filtrados()$dias_entrega)
    paste0(round(val, 1), " dias")
  })

  output$kpi_margem <- renderUI({
    receita <- sum(dados_filtrados()$preco_venda)
    lucro <- sum(dados_filtrados()$margem_lucro)
    perc <- (lucro / receita) * 100
    paste0(round(perc, 1), "%")
  })

  # 4.3 Gráfico de Evolução
  output$plot_evolucao <- renderPlotly({
    p <- dados_filtrados() %>%
      group_by(mes_pedido) %>%
      summarise(Faturamento = sum(preco_venda),
                Margem = sum(margem_lucro)) %>%
      ggplot(aes(x = mes_pedido)) +
      geom_line(aes(y = Faturamento, color = "Faturamento"), size = 1) +
      geom_line(aes(y = Margem, color = "Margem Lucro"), size = 1) +
      scale_color_manual(values = c("Faturamento" = "#2c3e50", "Margem Lucro" = "#27ae60")) +
      labs(x = NULL, y = "Valor (R$)", color = "Legenda") +
      theme_minimal()

    ggplotly(p)
  })

  # 4.4 Gráfico de Categorias
  output$plot_categoria <- renderPlotly({
    p <- dados_filtrados() %>%
      group_by(categoria) %>%
      summarise(Volume = n()) %>%
      ggplot(aes(x = reorder(categoria, Volume), y = Volume, fill = categoria)) +
      geom_col() +
      coord_flip() +
      labs(x = NULL, y = "Quantidade de Pedidos") +
      theme_minimal() +
      theme(legend.position = "none")

    ggplotly(p)
  })

  # 4.5 Tabela Operacional
  output$tabela_dados <- renderDT({
    datatable(dados_filtrados(),
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE,
              colnames = c("ID", "Data Pedido", "Categoria", "Região", "Venda", "Custo", "Frete", "Dias Entrega", "Data Entrega", "Margem", "Mês")) %>%
      formatCurrency(c("preco_venda", "custo_produto", "frete", "margem_lucro"), "R$ ")
  })
}

# 5. Execução do App -----------------------------------------------------------
shinyApp(ui = ui, server = server)
