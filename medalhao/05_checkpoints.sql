-- Script 05: CHECKPOINTS. Primeiro executar Bronze; depois Silver; depois Gold.
-- Bronze
SELECT COUNT(*) AS clientes_bronze FROM db_bronze.tb_clientes_raw;
SELECT COUNT(*) AS vendas_bronze FROM db_bronze.tb_vendas_raw;
SELECT * FROM db_bronze.tb_clientes_raw WHERE email NOT LIKE '%@%.%';
SELECT * FROM db_bronze.tb_vendas_raw WHERE valor_venda IN ('NaN','0','-20,00');

SELECT * FROM db_bronze.tb_clientes_raw WHERE email NOT LIKE '%.%com%';

-- Silver (executar após corrigir e chamar a procedure)
SELECT status_email, COUNT(*) AS clientes FROM db_silver.tb_clientes GROUP BY status_email;
SELECT motivo, COUNT(*) AS vendas FROM db_silver.tb_vendas_rejeitadas GROUP BY motivo ORDER BY motivo;
SELECT COUNT(*) AS vendas_validas, SUM(valor_venda) AS receita_silver FROM db_silver.tb_vendas;

-- Gold (executar após construir o INSERT ou procedure Gold)
SELECT * FROM db_gold.tb_relatorio_vendas ORDER BY total_vendas DESC LIMIT 5;
SELECT SUM(total_vendas) AS receita_gold FROM db_gold.tb_relatorio_vendas;
SELECT
 (SELECT SUM(valor_venda) FROM db_silver.tb_vendas) AS receita_silver,
 (SELECT SUM(total_vendas) FROM db_gold.tb_relatorio_vendas) AS receita_gold;


SELECT id_cliente, nome, email, data_cadastro
FROM db_bronze.tb_clientes_raw
WHERE id_cliente IN (1, 2, 3, 4, 5)
ORDER BY id_cliente;

-- 2.1 — Tratamento das datas na Silver.
WITH datas_padronizadas AS (
	SELECT 
		id_venda,
        data_venda AS data_original,
        CASE 
			WHEN data_venda REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
				THEN data_venda
                
			WHEN data_Venda REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
				THEN replace(data_venda, '/', '-')
			
            WHEN data_venda REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
				THEN CONCAT(
					RIGHT(data_venda,4), '-',
                    SUBSTRING(data_venda, 4, 2), '-',
                    LEFT(data_venda, 2)
                )
			WHEN data_venda REGEXP '^[0-9]{4}[.][0-9]{2}[.][0-9]{2}$'
				THEN REPLACE(data_venda, '.', '-')
			
            ELSE NULL
		END AS data_padronizada
	FROM db_bronze.tb_vendas_raw
    WHERE id_venda IN(1, 2, 3, 4, 55)
)
SELECT
    id_venda,
    data_original,
    CASE
        WHEN data_padronizada REGEXP
            '^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'
        THEN
            CASE
                WHEN CAST(RIGHT(data_padronizada, 2) AS UNSIGNED)
                     <= DAY(LAST_DAY(CONCAT(LEFT(data_padronizada, 7), '-01')))
                THEN CAST(data_padronizada AS DATE)
                ELSE NULL
            END
        ELSE NULL
    END AS data_tratada
FROM datas_padronizadas
ORDER BY id_venda;


-- 2.2 - Tratamento dos valores monetários
WITH amostra AS (
    SELECT
        id_venda,
        valor_venda AS valor_original,
        TRIM(valor_venda) AS valor_texto
    FROM db_bronze.tb_vendas_raw
    WHERE id_venda IN (1, 2, 6, 7, 8, 13, 19, 30)
),
normalizados AS (
    SELECT
        id_venda,
        valor_original,
        CASE
            -- Milhar com ponto e decimal com vírgula: 1.200,00
            WHEN valor_texto REGEXP
                '^[+-]?[0-9]{1,3}([.][0-9]{3})+,[0-9]{1,2}$'
                THEN REPLACE(REPLACE(valor_texto, '.', ''), ',', '.')

            -- Decimal com vírgula: 399,90 ou -20,00
            WHEN valor_texto REGEXP '^[+-]?[0-9]+,[0-9]{1,2}$'
                THEN REPLACE(valor_texto, ',', '.')

            -- Inteiro ou decimal com ponto: 45, 150.5 ou 75.50
            WHEN valor_texto REGEXP '^[+-]?[0-9]+([.][0-9]{1,2})?$'
                THEN valor_texto

            ELSE NULL
        END AS valor_normalizado
    FROM amostra
),
convertidos AS (
    SELECT
        id_venda,
        valor_original,
        CASE
            WHEN valor_normalizado REGEXP '^[+-]?0*[0-9]{1,10}([.][0-9]{1,2})?$'
                THEN CAST(valor_normalizado AS DECIMAL(12,2))
            ELSE NULL
        END AS valor_tratado
    FROM normalizados
)
SELECT
    id_venda,
    valor_original,
    valor_tratado,
    CASE
        WHEN valor_tratado IS NULL THEN 'VALOR_INVALIDO'
        WHEN valor_tratado <= 0 THEN 'VALOR_NAO_POSITIVO'
        ELSE 'OK'
    END AS status_valor
FROM convertidos
ORDER BY id_venda;


-- 2.3 — Validação dos e-mails na Silver
WITH amostra AS (
    SELECT
        id_cliente,
        nome,
        email AS email_original,
        TRIM(email) AS email_texto
    FROM db_bronze.tb_clientes_raw
    WHERE id_cliente IN (1, 2, 5, 13)
),
ajustados AS (
    SELECT
        *,
        CASE
            WHEN REGEXP_LIKE(email_texto, '@gmail$', 'c')
                THEN CONCAT(email_texto, '.com')
            ELSE email_texto
        END AS email_candidato
    FROM amostra
),
validados AS (
    SELECT
        *,
        CASE
            WHEN CHAR_LENGTH(email_candidato) <= 120
                 AND email_candidato REGEXP
                     '^[A-Za-z0-9_%+-]+([.][A-Za-z0-9_%+-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?[.])+[A-Za-z]{2,}$'
                THEN email_candidato
            ELSE NULL
        END AS email_tratado
    FROM ajustados
)
SELECT
    id_cliente,
    nome,
    email_original,
    email_tratado,
    CASE
        WHEN email_tratado IS NULL THEN 'INVALIDO'
        WHEN email_tratado <> email_texto THEN 'CORRIGIDO'
        ELSE 'VALIDO'
    END AS status_email
FROM validados
ORDER BY id_cliente;


-- 2.4 — Classificar as vendas
WITH origem AS (
    SELECT
        v.id_venda,
        v.id_cliente,
        c.id_cliente AS cliente_encontrado,
        TRIM(v.valor_venda) AS valor_texto,
        v.data_venda AS data_original
    FROM db_bronze.tb_vendas_raw AS v
    LEFT JOIN db_bronze.tb_clientes_raw AS c
        ON c.id_cliente = v.id_cliente
),
padronizados AS (
    SELECT
        *,
        CASE
            -- Ano primeiro, com hífen, barra ou ponto.
            WHEN data_original REGEXP
                 '^[0-9]{4}(-[0-9]{2}-|/[0-9]{2}/|[.][0-9]{2}[.])[0-9]{2}$'
                THEN REPLACE(REPLACE(data_original, '/', '-'), '.', '-')
            -- Dia primeiro.
            WHEN data_original REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                THEN CONCAT(RIGHT(data_original, 4), '-',
                            SUBSTRING(data_original, 4, 2), '-',
                            LEFT(data_original, 2))
        END AS data_iso,
        CASE
            -- Número com vírgula decimal, com ou sem pontos de milhar.
            WHEN valor_texto REGEXP
                 '^[+-]?([0-9]+|[0-9]{1,3}([.][0-9]{3})+),[0-9]{1,2}$'
                THEN REPLACE(REPLACE(valor_texto, '.', ''), ',', '.')
            WHEN valor_texto REGEXP '^[+-]?[0-9]+([.][0-9]{1,2})?$'
                THEN valor_texto
        END AS valor_normalizado
    FROM origem
),
tratados AS (
    SELECT
        *,
        CASE
            WHEN data_iso REGEXP
                 '^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'
            THEN CASE
                WHEN CAST(RIGHT(data_iso, 2) AS UNSIGNED)
                     <= DAY(LAST_DAY(CONCAT(LEFT(data_iso, 7), '-01')))
                THEN CAST(data_iso AS DATE)
            END
        END AS data_tratada,
        CASE
            WHEN valor_normalizado REGEXP '^[+-]?0*[0-9]{1,10}([.][0-9]{1,2})?$'
                THEN CAST(valor_normalizado AS DECIMAL(12,2))
        END AS valor_tratado
    FROM padronizados
),
classificados AS (
    SELECT
        *,
        CASE
            WHEN cliente_encontrado IS NULL THEN 'CLIENTE_INEXISTENTE'
            WHEN valor_tratado IS NULL THEN 'VALOR_INVALIDO'
            WHEN valor_tratado <= 0 THEN 'VALOR_NAO_POSITIVO'
            WHEN data_tratada IS NULL THEN 'DATA_INVALIDA'
            ELSE NULL
        END AS motivo
    FROM tratados
)
SELECT
    id_venda,
    id_cliente,
    valor_tratado,
    data_tratada,
    COALESCE(motivo, 'VALIDA') AS resultado
FROM classificados
WHERE id_venda IN (7, 8, 19, 30, 41, 55)
ORDER BY id_venda;

-- SELECT
--    COALESCE(motivo, 'VALIDA') AS resultado,
--    COUNT(*) AS qtd_vendas
-- FROM classificados
-- GROUP BY COALESCE(motivo, 'VALIDA')
-- ORDER BY qtd_vendas DESC, resultado;



-- 2.5 — Montar a procedure Silver

DROP PROCEDURE IF EXISTS db_sp.sp_carregar_silver;

DELIMITER $$

CREATE PROCEDURE db_sp.sp_carregar_silver()
BEGIN
    DECLARE v_safe_updates INT;

    -- Em caso de erro, desfaz a carga e devolve o erro original.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET SESSION sql_safe_updates = v_safe_updates;
        DROP TEMPORARY TABLE IF EXISTS tmp_silver_vendas_classificadas;
        RESIGNAL;
    END;

    SET v_safe_updates = @@SESSION.sql_safe_updates;
    START TRANSACTION;

    -- 1. Limpa a Silver e restaura a configuração da sessão.
    SET SESSION sql_safe_updates = 0;
    DELETE FROM db_silver.tb_vendas_rejeitadas;
    DELETE FROM db_silver.tb_vendas;
    DELETE FROM db_silver.tb_clientes;
    SET SESSION sql_safe_updates = v_safe_updates;

    -- 2. Carrega todos os clientes, inclusive os de e-mail inválido.
    INSERT INTO db_silver.tb_clientes
        (id_cliente, nome, email, status_email, cidade, data_cadastro)
    WITH origem_clientes AS (
        SELECT id_cliente, nome, cidade, data_cadastro,
               TRIM(email) AS email_texto
        FROM db_bronze.tb_clientes_raw
    ),
    padronizados AS (
        SELECT *,
            CASE
                WHEN REGEXP_LIKE(email_texto, '@gmail$', 'c')
                    THEN CONCAT(email_texto, '.com')
                ELSE email_texto
            END AS email_candidato,
            CASE
                WHEN data_cadastro REGEXP
                     '^[0-9]{4}(-[0-9]{2}-|/[0-9]{2}/|[.][0-9]{2}[.])[0-9]{2}$'
                    THEN REPLACE(REPLACE(data_cadastro, '/', '-'), '.', '-')
                WHEN data_cadastro REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                    THEN CONCAT(RIGHT(data_cadastro, 4), '-',
                                SUBSTRING(data_cadastro, 4, 2), '-',
                                LEFT(data_cadastro, 2))
            END AS data_iso
        FROM origem_clientes
    ),
    tratados AS (
        SELECT *,
            CASE
                WHEN CHAR_LENGTH(email_candidato) <= 120
                     AND email_candidato REGEXP
                         '^[A-Za-z0-9_%+-]+([.][A-Za-z0-9_%+-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?[.])+[A-Za-z]{2,}$'
                    THEN email_candidato
            END AS email_tratado,
            CASE
                WHEN data_iso REGEXP
                     '^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'
                THEN CASE
                    WHEN CAST(RIGHT(data_iso, 2) AS UNSIGNED)
                         <= DAY(LAST_DAY(CONCAT(LEFT(data_iso, 7), '-01')))
                    THEN CAST(data_iso AS DATE)
                END
            END AS data_tratada
        FROM padronizados
    )
    SELECT id_cliente, nome, email_tratado,
           CASE
               WHEN email_tratado IS NULL THEN 'INVALIDO'
               WHEN email_tratado <> email_texto THEN 'CORRIGIDO'
               ELSE 'VALIDO'
           END,
           cidade, data_tratada
    FROM tratados;

    -- 3. Classifica cada venda uma vez e guarda o resultado temporariamente.
    DROP TEMPORARY TABLE IF EXISTS tmp_silver_vendas_classificadas;

    CREATE TEMPORARY TABLE tmp_silver_vendas_classificadas
    ENGINE = InnoDB AS
    WITH origem_vendas AS (
        SELECT v.id_venda, v.id_cliente, v.produto,
               v.valor_venda AS valor_original,
               v.data_venda AS data_original,
               TRIM(v.valor_venda) AS valor_texto,
               c.id_cliente AS cliente_encontrado
        FROM db_bronze.tb_vendas_raw AS v
        LEFT JOIN db_silver.tb_clientes AS c
            ON c.id_cliente = v.id_cliente
    ),
    padronizados AS (
        SELECT *,
            CASE
                WHEN data_original REGEXP
                     '^[0-9]{4}(-[0-9]{2}-|/[0-9]{2}/|[.][0-9]{2}[.])[0-9]{2}$'
                    THEN REPLACE(REPLACE(data_original, '/', '-'), '.', '-')
                WHEN data_original REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
                    THEN CONCAT(RIGHT(data_original, 4), '-',
                                SUBSTRING(data_original, 4, 2), '-',
                                LEFT(data_original, 2))
            END AS data_iso,
            CASE
                WHEN valor_texto REGEXP
                     '^[+-]?([0-9]+|[0-9]{1,3}([.][0-9]{3})+),[0-9]{1,2}$'
                    THEN REPLACE(REPLACE(valor_texto, '.', ''), ',', '.')
                WHEN valor_texto REGEXP '^[+-]?[0-9]+([.][0-9]{1,2})?$'
                    THEN valor_texto
            END AS valor_normalizado
        FROM origem_vendas
    ),
    tratados AS (
        SELECT *,
            CASE
                WHEN data_iso REGEXP
                     '^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'
                THEN CASE
                    WHEN CAST(RIGHT(data_iso, 2) AS UNSIGNED)
                         <= DAY(LAST_DAY(CONCAT(LEFT(data_iso, 7), '-01')))
                    THEN CAST(data_iso AS DATE)
                END
            END AS data_tratada,
            CASE
                WHEN valor_normalizado REGEXP
                     '^[+-]?0*[0-9]{1,10}([.][0-9]{1,2})?$'
                    THEN CAST(valor_normalizado AS DECIMAL(12,2))
            END AS valor_tratado
        FROM padronizados
    )
    SELECT id_venda, id_cliente, produto, valor_original, data_original,
           valor_tratado, data_tratada,
           CASE
               WHEN cliente_encontrado IS NULL THEN 'CLIENTE_INEXISTENTE'
               WHEN valor_tratado IS NULL THEN 'VALOR_INVALIDO'
               WHEN valor_tratado <= 0 THEN 'VALOR_NAO_POSITIVO'
               WHEN data_tratada IS NULL THEN 'DATA_INVALIDA'
               ELSE NULL
           END AS motivo
    FROM tratados;

    -- 4. Distribui as vendas sem alterar seus identificadores originais.
    INSERT INTO db_silver.tb_vendas
        (id_venda, id_cliente, valor_venda, data_venda, produto)
    SELECT id_venda, id_cliente, valor_tratado, data_tratada, produto
    FROM tmp_silver_vendas_classificadas
    WHERE motivo IS NULL;

    INSERT INTO db_silver.tb_vendas_rejeitadas
        (id_venda, id_cliente, valor_venda_original,
         data_venda_original, produto, motivo)
    SELECT id_venda, id_cliente, valor_original, data_original, produto, motivo
    FROM tmp_silver_vendas_classificadas
    WHERE motivo IS NOT NULL;

    DROP TEMPORARY TABLE tmp_silver_vendas_classificadas;
    COMMIT;
END$$

DELIMITER ;

CALL db_sp.sp_carregar_silver();

SELECT status_email, COUNT(*) AS qtd_clientes
FROM db_silver.tb_clientes
GROUP BY status_email;

SELECT COUNT(*) AS vendas_validas, SUM(valor_venda) AS faturamento_silver
FROM db_silver.tb_vendas;

SELECT id_venda, id_cliente, valor_venda_original, data_venda_original, motivo
FROM db_silver.tb_vendas_rejeitadas
ORDER BY id_venda;


-- 3.1 — Montar a consulta da Gold
SELECT
    c.id_cliente,
    c.nome AS nome_cliente,
    COALESCE(SUM(v.valor_venda), 0.00) AS total_vendas,
    COUNT(v.id_venda) AS qtd_vendas,
    ROUND(COALESCE(AVG(v.valor_venda), 0.00), 2) AS ticket_medio
FROM db_silver.tb_clientes AS c
LEFT JOIN db_silver.tb_vendas AS v
    ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY c.id_cliente;


-- 3.2 — Criar a procedure Gold

DROP PROCEDURE IF EXISTS db_sp.sp_carregar_gold;

DELIMITER $$

CREATE PROCEDURE db_sp.sp_carregar_gold()
BEGIN
    DECLARE v_safe_updates INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET SESSION sql_safe_updates = v_safe_updates;
        DROP TEMPORARY TABLE IF EXISTS tmp_resumo_vendas;
        RESIGNAL;
    END;

    SET v_safe_updates = @@SESSION.sql_safe_updates;
    START TRANSACTION;

    -- 1. Cria uma tabela temporária com a estrutura da Gold.
    DROP TEMPORARY TABLE IF EXISTS tmp_resumo_vendas;

    CREATE TEMPORARY TABLE tmp_resumo_vendas
    LIKE db_gold.tb_relatorio_vendas;

    -- 2. Calcula os indicadores a partir da Silver.
    INSERT INTO tmp_resumo_vendas
        (id_cliente, nome_cliente, total_vendas, qtd_vendas, ticket_medio)
    SELECT
        c.id_cliente,
        c.nome,
        COALESCE(SUM(v.valor_venda), 0.00),
        COUNT(v.id_venda),
        ROUND(COALESCE(AVG(v.valor_venda), 0.00), 2)
    FROM db_silver.tb_clientes AS c
    LEFT JOIN db_silver.tb_vendas AS v
        ON v.id_cliente = c.id_cliente
    GROUP BY c.id_cliente, c.nome;

    -- 3. Substitui o relatório anterior dentro da transação.
    SET SESSION sql_safe_updates = 0;
    DELETE FROM db_gold.tb_relatorio_vendas;
    SET SESSION sql_safe_updates = v_safe_updates;

    INSERT INTO db_gold.tb_relatorio_vendas
        (id_cliente, nome_cliente, total_vendas, qtd_vendas, ticket_medio)
    SELECT id_cliente, nome_cliente, total_vendas, qtd_vendas, ticket_medio
    FROM tmp_resumo_vendas;

    -- 4. Remove a tabela temporária e confirma a atualização.
    DROP TEMPORARY TABLE tmp_resumo_vendas;
    COMMIT;
END$$

DELIMITER ;


CALL db_sp.sp_carregar_gold();

SELECT
    COUNT(*) AS clientes_no_relatorio,
    SUM(qtd_vendas) AS vendas_consolidadas,
    SUM(total_vendas) AS faturamento_gold
FROM db_gold.tb_relatorio_vendas;

SELECT *
FROM db_gold.tb_relatorio_vendas
WHERE id_cliente IN (1, 25)
ORDER BY id_cliente;