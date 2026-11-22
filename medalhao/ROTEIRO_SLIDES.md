# Roteiro de slides — Hands-on em sala (8 telas)

1. **Missão de hoje:** Resgatar um pipeline de vendas. Três camadas: Bronze → Silver → Gold. Ferramenta: MySQL 8.0+.
2. **O que já recebemos:** Bronze com clientes e vendas; datas e valores monetários heterogêneos; e-mails incompletos; registros inválidos.
3. **Preparando o ambiente:** executar 01 Bronze, 02 Silver, 03 Gold, 04 Procedure. Tentar CALL e registrar erro.
4. **Checkpoint A:** contagens e amostras de erros na Bronze. Não corrigir a origem.
5. **Desafio Silver:** transformar datas/valores, classificar e-mail, rejeitar vendas inconsistentes. Preservar ids. Procedure reexecutável.
6. **Checkpoint B:** mostrar aceitos, rejeitados, motivos; repetir CALL e conferir estabilidade.
7. **Desafio Gold:** receita por cliente, quantidade, ticket médio, ranking e clientes sem compras. Validar total Silver = total Gold.
8. **Entrega e reflexão:** equipe_pipeline.sql + relatório curto; explicar por que Bronze é imutável, por que rejeitar registros e como evitar carga parcial.
