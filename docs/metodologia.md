# Documentação Metodológica: Indicadores Operacionais e Financeiros

## 1. Contextualização
Este documento descreve a racionalidade por trás da escolha dos indicadores apresentados no dashboard. A fundamentação baseia-se em princípios de **Gestão da Cadeia de Suprimentos (SCM)** e **Análise Financeira Corporativa**.

## 2. Indicadores Financeiros (Financial KPIs)

### 2.1. Faturamento Bruto (Gross Revenue)
*   **Definição:** Soma de todos os valores de venda no período selecionado.
*   **Importância:** Mede a escala da operação e a capacidade de penetração no mercado.

### 2.2. Ticket Médio (Average Order Value - AOV)
*   **Fórmula:** `Faturamento Total / Quantidade de Pedidos`
*   **Aplicação:** Indica a eficiência das estratégias de precificação e mix de produtos. Um ticket médio crescente sugere sucesso em estratégias de *cross-selling* ou aumento de preços.

### 2.3. Margem de Contribuição (%)
*   **Fórmula:** `((Preço de Venda - Custo - Frete) / Preço de Venda) * 100`
*   **Análise:** Fundamental para entender se a operação é sustentável. Frequentemente, categorias com alto faturamento possuem margens baixas (ex: Eletrônicos), enquanto nichos menores podem sustentar a rentabilidade do negócio.

## 3. Indicadores Operacionais (Operational KPIs)

### 3.1. Lead Time de Entrega
*   **Definição:** Intervalo de tempo (em dias) entre a data do pedido e a efetiva entrega ao cliente.
*   **Importância:** É um dos principais drivers de satisfação do cliente no e-commerce. Gargalos no lead time geralmente indicam ineficiências logísticas ou problemas com transportadoras.

### 3.2. Densidade Regional
*   **Análise:** Identifica onde está concentrada a demanda. Útil para decisões de descentralização de estoque (abertura de novos hubs logísticos) e otimização de rotas de frete.

## 4. Processo de Tratamento de Dados (ETL)
O projeto utiliza o paradigma *Tidy Data* (Wickham, 2014):
1.  **Limpeza:** Padronização de nomes de colunas e formatos de data.
2.  **Enriquecimento:** Criação de variáveis derivadas (`mes_pedido`, `margem_lucro`).
3.  **Filtragem Reativa:** Otimização do processamento no Shiny para garantir que apenas os dados necessários sejam carregados em memória durante a interação do usuário.
