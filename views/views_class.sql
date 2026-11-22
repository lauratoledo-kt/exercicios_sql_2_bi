
CREATE DATABASE IF NOT EXISTS db_techmarket;
USE db_techmarket;

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    cidade VARCHAR(60),
    estado CHAR(2)
);

CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY,
    nome VARCHAR(100),
    equipe VARCHAR(50)
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY,
    descricao VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10,2)
);

CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    id_vendedor INT,
    data_pedido DATE,
    status_pedido VARCHAR(20),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
);

CREATE TABLE itens_pedido (
    id_item INT PRIMARY KEY,
    id_pedido INT,
    id_produto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    desconto_percentual DECIMAL(5,2),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

INSERT INTO clientes VALUES
(1,'Ana Souza','Curitiba','PR'),
(2,'Bruno Lima','Londrina','PR'),
(3,'Carla Mendes','Sao Paulo','SP'),
(4,'Daniel Rocha','Curitiba','PR'),
(5,'Eduarda Alves','Joinville','SC'),
(6,'Felipe Costa','Campinas','SP'),
(7,'Gabriela Martins','Maringa','PR'),
(8,'Henrique Dias','Florianopolis','SC');

INSERT INTO vendedores VALUES
(1,'Marcos Silva','Sul'),
(2,'Patricia Gomes','Sul'),
(3,'Ricardo Oliveira','Sudeste'),
(4,'Juliana Ferreira','Sudeste');

INSERT INTO produtos VALUES
(1,'Notebook Pro', 'Computadores',4500.00),
(2,'Mouse Gamer','Perifericos',180.00),
(3,'Teclado Mecanico','Perifericos',350.00),
(4,'Monitor 27','Monitores',1400.00),
(5,'Headset Pro','Audio',420.00),
(6,'Webcam HD','Acessorios',260.00),
(7,'SSD 1TB','Armazenamento',550.00),
(8,'Hub USB-C','Acessorios',150.00);

INSERT INTO pedidos VALUES
(101,1,1,'2026-09-01','Faturado'),
(102,2,1,'2026-09-02','Faturado'),
(103,3,3,'2026-09-03','Faturado'),
(104,4,2,'2026-09-05','Cancelado'),
(105,5,2,'2026-09-06','Faturado'),
(106,6,3,'2026-09-08','Faturado'),
(107,1,1,'2026-09-10','Faturado'),
(108,7,2,'2026-09-12','Pendente'),
(109,2,2,'2026-09-15','Faturado'),
(110,3,3,'2026-09-17','Faturado'),
(111,5,1,'2026-09-19','Faturado'),
(112,6,3,'2026-09-22','Faturado');

INSERT INTO itens_pedido VALUES
(1,101,1,1,4500,10),
(2,101,2,2,180,0),
(3,102,3,2,350,5),
(4,102,5,1,420,0),
(5,103,4,2,1400,10),
(6,103,6,1,260,0),
(7,104,1,1,4500,0),
(8,105,7,2,550,5),
(9,105,8,3,150,0),
(10,106,1,2,4500,5),
(11,106,3,1,350,0),
(12,107,4,1,1400,0),
(13,107,5,2,420,10),
(14,108,2,4,180,0),
(15,109,6,3,260,0),
(16,109,8,2,150,5),
(17,110,7,1,550,0),
(18,110,2,3,180,10),
(19,111,3,2,350,0),
(20,112,1,1,4500,15);


-- 1 — Preparar e conferir a base
USE db_techmarket;

SELECT
    (SELECT COUNT(*) FROM clientes)     AS clientes,
    (SELECT COUNT(*) FROM vendedores)  AS vendedores,
    (SELECT COUNT(*) FROM produtos)    AS produtos,
    (SELECT COUNT(*) FROM pedidos)     AS pedidos,
    (SELECT COUNT(*) FROM itens_pedido) AS itens_pedido;
    
-- CONFERINDO A DIFERENÇA ENTRE PEDIDO E ITEM
SELECT
    p.status_pedido,
    COUNT(DISTINCT p.id_pedido) AS qtd_pedidos,
    COUNT(i.id_item) AS qtd_itens
FROM pedidos AS p
LEFT JOIN itens_pedido AS i
    ON i.id_pedido = p.id_pedido
GROUP BY p.status_pedido
ORDER BY qtd_pedidos DESC, p.status_pedido;


-- MISSÃO 1 - CONFERIR AS VENDAS DETALHADAS ANTES DE CRIAR A VIEW
-- CONSULTA ANTES DA VIEW.
SELECT
    i.id_item,
    p.id_pedido,
    p.data_pedido,
    p.status_pedido,
    c.id_cliente,
    c.nome AS nome_cliente,
    c.cidade,
    c.estado,
    v.id_vendedor,
    v.nome AS nome_vendedor,
    v.equipe,
    pr.id_produto,
    pr.descricao AS nome_produto,
    pr.categoria,
    i.quantidade,
    i.preco_unitario,
    i.desconto_percentual,
    i.quantidade * i.preco_unitario AS valor_bruto,
    ROUND(
        i.quantidade * i.preco_unitario * i.desconto_percentual / 100,
        2
    ) AS valor_desconto,
    i.quantidade * i.preco_unitario - ROUND(
        i.quantidade * i.preco_unitario * i.desconto_percentual / 100,
        2
    ) AS valor_faturado
FROM itens_pedido AS i
INNER JOIN pedidos AS p
    ON p.id_pedido = i.id_pedido
INNER JOIN clientes AS c
    ON c.id_cliente = p.id_cliente
INNER JOIN vendedores AS v
    ON v.id_vendedor = p.id_vendedor
INNER JOIN produtos AS pr
    ON pr.id_produto = i.id_produto
WHERE p.status_pedido = 'Faturado'
ORDER BY i.id_item;

-- CRIANDO A VIEW 
USE db_techmarket;

CREATE OR REPLACE VIEW vw_vendas_detalhadas AS
SELECT
    i.id_item,
    p.id_pedido,
    p.data_pedido,
    p.status_pedido,
    c.id_cliente,
    c.nome AS nome_cliente,
    c.cidade,
    c.estado,
    v.id_vendedor,
    v.nome AS nome_vendedor,
    v.equipe,
    pr.id_produto,
    pr.descricao AS nome_produto,
    pr.categoria,
    i.quantidade,
    i.preco_unitario,
    i.desconto_percentual,
    i.quantidade * i.preco_unitario AS valor_bruto,
    ROUND(
        i.quantidade * i.preco_unitario * i.desconto_percentual / 100,
        2
    ) AS valor_desconto,
    i.quantidade * i.preco_unitario - ROUND(
        i.quantidade * i.preco_unitario * i.desconto_percentual / 100,
        2
    ) AS valor_faturado
FROM itens_pedido AS i
INNER JOIN pedidos AS p
    ON p.id_pedido = i.id_pedido
INNER JOIN clientes AS c
    ON c.id_cliente = p.id_cliente
INNER JOIN vendedores AS v
    ON v.id_vendedor = p.id_vendedor
INNER JOIN produtos AS pr
    ON pr.id_produto = i.id_produto
WHERE p.status_pedido = 'Faturado';

-- 1. Todos os itens faturados, do maior para o menor valor.
SELECT *
FROM vw_vendas_detalhadas
ORDER BY valor_faturado DESC, id_item;

-- 2. Os cinco itens com maior valor faturado, com cliente e produto.
SELECT id_pedido, id_item, nome_cliente, nome_produto, valor_faturado
FROM vw_vendas_detalhadas
ORDER BY valor_faturado DESC, id_item
LIMIT 5;

-- 3. Vendas para clientes do Paraná, em ordem cronológica.
SELECT data_pedido, id_pedido, id_item, nome_cliente, cidade,
       estado, nome_produto, quantidade, valor_faturado
FROM vw_vendas_detalhadas
WHERE estado = 'PR'
ORDER BY data_pedido, id_pedido, id_item;
-- CONSULTA DA QUANTIDADE DE FATURAMENTO E VALOR TOTAL FATURADO.
SELECT
    COUNT(*) AS itens_faturados,
    COUNT(DISTINCT id_pedido) AS pedidos_faturados,
    SUM(valor_faturado) AS faturamento_total
FROM vw_vendas_detalhadas;


-- MISSÃO 2 - DESEMPENHO DOS VENDEDORES.
CREATE OR REPLACE VIEW vw_desempenho_vendedores AS
SELECT
    v.id_vendedor,
    v.nome AS nome_vendedor,
    v.equipe,
    COUNT(DISTINCT vd.id_pedido) AS pedidos_faturados,
    COALESCE(SUM(vd.quantidade), 0) AS unidades_vendidas,
    COALESCE(SUM(vd.valor_faturado), 0.00) AS faturamento_total,
    COALESCE(
        ROUND(
            SUM(vd.valor_faturado)
            / NULLIF(COUNT(DISTINCT vd.id_pedido), 0),
            2
        ),
        0.00
    ) AS ticket_medio_pedido
FROM vendedores AS v
LEFT JOIN vw_vendas_detalhadas AS vd
    ON vd.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nome, v.equipe;

-- 4. Ranking dos vendedores por faturamento.
SELECT
    nome_vendedor,
    equipe,
    pedidos_faturados,
    unidades_vendidas,
    faturamento_total,
    ticket_medio_pedido
FROM vw_desempenho_vendedores
ORDER BY faturamento_total DESC, id_vendedor;

-- 5. Total de pedidos e faturamento por equipe.
SELECT
    equipe,
    SUM(pedidos_faturados) AS pedidos_faturados,
    SUM(faturamento_total) AS faturamento_total
FROM vw_desempenho_vendedores
GROUP BY equipe
ORDER BY faturamento_total DESC, equipe;


-- MISSÃO 3 - DESEMPENHO DOS PRODUTOS.

CREATE OR REPLACE VIEW vw_desempenho_produtos AS
SELECT
    p.id_produto,
    p.descricao AS nome_produto,
    p.categoria,
    COALESCE(SUM(vd.quantidade), 0) AS unidades_vendidas,
    COUNT(DISTINCT vd.id_pedido) AS pedidos_faturados,
    COALESCE(SUM(vd.valor_faturado), 0.00) AS faturamento_total
FROM produtos AS p
LEFT JOIN vw_vendas_detalhadas AS vd
    ON vd.id_produto = p.id_produto
GROUP BY p.id_produto, p.descricao, p.categoria;

-- 6. Produtos com maior receita.
SELECT nome_produto, categoria, unidades_vendidas, faturamento_total
FROM vw_desempenho_produtos
ORDER BY faturamento_total DESC, id_produto;

-- 7. Categorias com faturamento superior a R$ 2.000,00.
SELECT
    categoria,
    SUM(unidades_vendidas) AS unidades_vendidas,
    SUM(faturamento_total) AS faturamento_categoria
FROM vw_desempenho_produtos
GROUP BY categoria
HAVING SUM(faturamento_total) > 2000.00
ORDER BY faturamento_categoria DESC, categoria;

-- 8. Top 3 por valor médio faturado por unidade.
SELECT
    nome_produto,
    unidades_vendidas,
    faturamento_total,
    ROUND(faturamento_total / unidades_vendidas, 2) AS valor_medio_unidade
FROM vw_desempenho_produtos
WHERE unidades_vendidas > 0
ORDER BY faturamento_total / unidades_vendidas DESC, id_produto
LIMIT 3;


-- MISSÃO 4 - COMPORTAMENTO DOS CLIENTES
CREATE OR REPLACE VIEW vw_resumo_clientes AS
SELECT
    c.id_cliente,
    c.nome AS nome_cliente,
    c.cidade,
    c.estado,
    COUNT(DISTINCT vd.id_pedido) AS pedidos_faturados,
    COALESCE(SUM(vd.valor_faturado), 0.00) AS total_gasto
FROM clientes AS c
LEFT JOIN vw_vendas_detalhadas AS vd
    ON vd.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome, c.cidade, c.estado;

-- 9. Ranking dos clientes por gasto total, com ticket médio por pedido.
SELECT
    nome_cliente,
    estado,
    pedidos_faturados,
    total_gasto,
    COALESCE(
        ROUND(total_gasto / NULLIF(pedidos_faturados, 0), 2),
        0.00
    ) AS ticket_medio
FROM vw_resumo_clientes
ORDER BY total_gasto DESC, id_cliente;

-- 10. Classificação dos clientes para a campanha de fidelização.
SELECT
    nome_cliente,
    pedidos_faturados,
    total_gasto,
    CASE
        WHEN pedidos_faturados = 0 THEN 'Sem compras'
        WHEN total_gasto >= 5000.00 THEN 'VIP'
        WHEN total_gasto > 0 THEN 'Regular'
    END AS classificacao_cliente
FROM vw_resumo_clientes
ORDER BY total_gasto DESC, id_cliente;

-- 11. Faturamento, clientes cadastrados e média por cliente em cada estado.
SELECT
    estado,
    SUM(total_gasto) AS faturamento_estado,
    COUNT(*) AS clientes_cadastrados,
    ROUND(AVG(total_gasto), 2) AS media_por_cliente
FROM vw_resumo_clientes
GROUP BY estado
ORDER BY faturamento_estado DESC, estado;

-- MISSÃO 5 - PAINEL EXECUTIVO

-- 12. Pedidos, faturamento e ticket médio por equipe
WITH faturamento_equipe AS (
    SELECT equipe, SUM(faturamento_total) AS faturamento
    FROM vw_desempenho_vendedores
    GROUP BY equipe
),
pedidos_equipe AS (
    SELECT equipe, COUNT(DISTINCT id_pedido) AS pedidos_faturados
    FROM vw_vendas_detalhadas
    GROUP BY equipe
)
SELECT
    f.equipe,
    COALESCE(p.pedidos_faturados, 0) AS pedidos_faturados,
    f.faturamento,
    COALESCE(
        ROUND(f.faturamento / NULLIF(p.pedidos_faturados, 0), 2),
        0.00
    ) AS ticket_medio_equipe
FROM faturamento_equipe AS f
LEFT JOIN pedidos_equipe AS p
    ON p.equipe = f.equipe
ORDER BY f.faturamento DESC, f.equipe;

-- 13. Participação de cada categoria no faturamento
WITH receita_categoria AS (
    SELECT categoria, SUM(faturamento_total) AS faturamento_categoria
    FROM vw_desempenho_produtos
    GROUP BY categoria
),
receita_empresa AS (
    SELECT SUM(valor_faturado) AS faturamento_empresa
    FROM vw_vendas_detalhadas
)
SELECT
    c.categoria,
    c.faturamento_categoria,
    ROUND(
        100.00 * c.faturamento_categoria
        / NULLIF(e.faturamento_empresa, 0),
        2
    ) AS participacao_percentual
FROM receita_categoria AS c
CROSS JOIN receita_empresa AS e
ORDER BY c.faturamento_categoria DESC, c.categoria;

-- 14. Clientes que gastaram acima da média dos compradores
WITH media_compradores AS (
    SELECT
        SUM(valor_faturado)
        / NULLIF(COUNT(DISTINCT id_cliente), 0) AS media_gasto
    FROM vw_vendas_detalhadas
)
SELECT
    c.nome_cliente,
    c.estado,
    c.total_gasto,
    ROUND(c.total_gasto - m.media_gasto, 2) AS diferenca_para_media
FROM vw_resumo_clientes AS c
CROSS JOIN media_compradores AS m
WHERE c.pedidos_faturados > 0
  AND c.total_gasto > m.media_gasto
ORDER BY c.total_gasto DESC, c.id_cliente;


-- Missão 6 — DESCONTO TOTAL POR VENDEDOR.

ALTER VIEW vw_desempenho_vendedores AS
SELECT
    v.id_vendedor,
    v.nome AS nome_vendedor,
    v.equipe,
    COUNT(DISTINCT vd.id_pedido) AS pedidos_faturados,
    COALESCE(SUM(vd.quantidade), 0) AS unidades_vendidas,
    COALESCE(SUM(vd.valor_faturado), 0.00) AS faturamento_total,
    COALESCE(
        ROUND(
            SUM(vd.valor_faturado)
            / NULLIF(COUNT(DISTINCT vd.id_pedido), 0),
            2
        ),
        0.00
    ) AS ticket_medio_pedido,
    COALESCE(SUM(vd.valor_desconto), 0.00) AS desconto_total
FROM vendedores AS v
LEFT JOIN vw_vendas_detalhadas AS vd
    ON vd.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nome, v.equipe;

-- Conferência do novo indicador por vendedor.
SELECT
    nome_vendedor,
    equipe,
    pedidos_faturados,
    unidades_vendidas,
    faturamento_total,
    ticket_medio_pedido,
    desconto_total
FROM vw_desempenho_vendedores
ORDER BY desconto_total DESC, id_vendedor;

-- Conferência dos totais após o ALTER VIEW.
SELECT
    SUM(pedidos_faturados) AS total_pedidos,
    SUM(faturamento_total) AS faturamento_total,
    SUM(desconto_total) AS desconto_total
FROM vw_desempenho_vendedores;