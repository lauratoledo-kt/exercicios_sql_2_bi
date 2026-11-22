-- Script 04: PROCEDURE INICIAL (COM PROBLEMAS INTENCIONAIS)
-- Objetivo: diagnosticar por que o carregamento falha e reescrever as transformações.
-- A procedure cria normalmente, mas seu CALL pode falhar ao converter os dados brutos.
-- Não altere db_bronze; corrija apenas o processamento para db_silver.
CREATE DATABASE IF NOT EXISTS db_sp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP PROCEDURE IF EXISTS db_sp.sp_carregar_silver;
DELIMITER $$
CREATE PROCEDURE db_sp.sp_carregar_silver()
BEGIN
    -- TODO 1: transformar as datas heterogêneas antes de gravar em DATE.
    -- TODO 2: validar/corrigir e-mail sem inventar domínio inexistente.
    -- TODO 3: normalizar valores BR e internacionais para DECIMAL.
    -- TODO 4: rejeitar NaN, <= 0, datas inválidas e cliente inexistente.
    -- TODO 5: preencher tb_vendas_rejeitadas com motivo.
    -- TODO 6: tornar a carga reexecutável com transação e ROLLBACK.
    DELETE FROM db_silver.tb_vendas_rejeitadas;
    DELETE FROM db_silver.tb_vendas;
    DELETE FROM db_silver.tb_clientes;

    INSERT INTO db_silver.tb_clientes
      (id_cliente,nome,email,status_email,cidade,data_cadastro)
    SELECT id_cliente,nome,email,'VALIDO',cidade,data_cadastro
    FROM db_bronze.tb_clientes_raw;

    INSERT INTO db_silver.tb_vendas
      (id_venda,id_cliente,valor_venda,data_venda,produto)
    SELECT id_venda,id_cliente,valor_venda,data_venda,produto
    FROM db_bronze.tb_vendas_raw
    WHERE valor_venda <> 'NaN';
END $$
DELIMITER ;

-- Execute separadamente para observar os erros:
-- CALL db_sp.sp_carregar_silver();
