# Exercícios SQL — BI

Exercícios de SQL (MySQL 8.0+) organizados por tema.

## Estrutura

- `medalhao/` — Hands-on da arquitetura medalhão (Bronze → Silver → Gold)
  - `01_camada_bronze.sql` — dados brutos, com inconsistências intencionais
  - `02_camada_silver.sql` — estrutura de destino da Silver
  - `03_camada_gold.sql` — estrutura analítica da Gold
  - `04_procedure_silver_desafio.sql` — procedure inicial (com problemas)
  - `05_checkpoints.sql` — consultas de conferência e procedures finais (Silver e Gold)
  - `ROTEIRO_SLIDES.md` — roteiro da aula
- `desafio_ddl/` — DDL do desafio SQL (`sql_quest`)
- `views/` — exercícios com VIEWs (`db_techmarket`)

## Ordem de execução (medalhão)

1. `01_camada_bronze.sql`
2. `02_camada_silver.sql`
3. `03_camada_gold.sql`
4. `04_procedure_silver_desafio.sql`
5. `05_checkpoints.sql`

Os scripts de DDL com `DROP` removem tabelas anteriores. Execute em ambiente de laboratório.
