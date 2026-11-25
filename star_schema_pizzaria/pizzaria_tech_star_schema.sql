-- =============================================================
-- BANCO DE DADOS II | PIZZARIA TECH | STAR SCHEMA
-- Aluna: Laura Toledo
-- SGBD: MySQL 8.0 (MySQL Workbench)
-- Ordem de execucao: Missao 01 (DDL) -> Missao 02 (inserts do
-- professor + conferencia) -> Missoes 03 a 06 (consultas).
-- =============================================================


-- =============================================================
-- MISSAO 01 | CRIANDO AS TABELAS (DDL)
-- Regra do Star Schema: as DIMENSOES (contexto) sao criadas
-- primeiro; a FATO (medidas) por ultimo, porque ela referencia
-- as quatro dimensoes por chave estrangeira.
-- =============================================================

DROP DATABASE IF EXISTS bd_pizzaria_tech;
CREATE DATABASE bd_pizzaria_tech CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bd_pizzaria_tech;

-- Dimensao CLIENTE: quem comprou e onde mora.
CREATE TABLE dim_cliente (
    id_cliente   INT          NOT NULL AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    cidade       VARCHAR(100) NOT NULL,
    estado       CHAR(2)      NOT NULL,   -- sigla da UF sempre com 2 letras
    PRIMARY KEY (id_cliente)
) ENGINE=InnoDB;

-- Dimensao PRODUTO: o que foi vendido.
CREATE TABLE dim_produto (
    id_produto     INT           NOT NULL AUTO_INCREMENT,
    nome_produto   VARCHAR(100)  NOT NULL,
    categoria      VARCHAR(50)   NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL, -- DECIMAL evita erro de arredondamento em dinheiro
    PRIMARY KEY (id_produto)
) ENGINE=InnoDB;

-- Dimensao VENDEDOR: quem vendeu, em que turno e filial.
CREATE TABLE dim_vendedor (
    id_vendedor   INT          NOT NULL AUTO_INCREMENT,
    nome_vendedor VARCHAR(100) NOT NULL,
    turno         VARCHAR(20)  NOT NULL,
    filial        VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_vendedor)
) ENGINE=InnoDB;

-- Dimensao TEMPO: quando foi vendido (data ja "quebrada" em
-- dia, mes, ano e dia da semana para facilitar os agrupamentos).
CREATE TABLE dim_tempo (
    id_tempo   INT         NOT NULL AUTO_INCREMENT,
    data_venda DATE        NOT NULL,
    dia        INT         NOT NULL,
    mes        INT         NOT NULL,
    nome_mes   VARCHAR(20) NOT NULL,
    ano        INT         NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_tempo)
) ENGINE=InnoDB;

-- Tabela FATO: cada linha = um item vendido.
-- Guarda apenas as chaves das dimensoes + as medidas numericas.
CREATE TABLE fact_venda (
    id_venda    INT           NOT NULL AUTO_INCREMENT,
    id_cliente  INT           NOT NULL,
    id_produto  INT           NOT NULL,
    id_vendedor INT           NOT NULL,
    id_tempo    INT           NOT NULL,
    quantidade  INT           NOT NULL,   -- medida
    valor_total DECIMAL(12,2) NOT NULL,   -- medida
    PRIMARY KEY (id_venda),
    -- ON DELETE RESTRICT: impede apagar um cliente/produto/vendedor/data
    --                     que ja tenha vendas (nao deixa a fato "orfa").
    -- ON UPDATE CASCADE:  se o id da dimensao mudar, a fato acompanha.
    CONSTRAINT fk_fact_cliente FOREIGN KEY (id_cliente)
        REFERENCES dim_cliente(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fact_produto FOREIGN KEY (id_produto)
        REFERENCES dim_produto(id_produto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fact_vendedor FOREIGN KEY (id_vendedor)
        REFERENCES dim_vendedor(id_vendedor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fact_tempo FOREIGN KEY (id_tempo)
        REFERENCES dim_tempo(id_tempo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- INSERTS FORNECIDOS NA AULA (SEM ALTERAR OS VALORES)
-- =============================================================


INSERT INTO dim_cliente (nome_cliente, cidade, estado) VALUES
('Lucas Pianof', 'Curitiba', 'PR'),
('Ana Souza', 'São Paulo', 'SP'),
('Pedro Lima', 'Rio de Janeiro', 'RJ'),
('Mariana Costa', 'Curitiba', 'PR'),
('Carlos Oliveira', 'Belo Horizonte', 'MG'),
('Juliana Mendes', 'Florianópolis', 'SC'),
('Rafael Torres', 'Campinas', 'SP'),
('Fernanda Rocha', 'Londrina', 'PR'),
('Gustavo Silva', 'Porto Alegre', 'RS'),
('Isabela Martins', 'São José dos Pinhais', 'PR'),
('Ricardo Lima', 'Maringá', 'PR'),
('Camila Dias', 'Sorocaba', 'SP'),
('Felipe Gomes', 'Joinville', 'SC'),
('Patrícia Santos', 'Curitiba', 'PR'),
('André Almeida', 'São Paulo', 'SP'),
('Tatiane Moreira', 'Londrina', 'PR'),
('João Ferreira', 'Curitiba', 'PR'),
('Aline Barbosa', 'Cascavel', 'PR'),
('Bruno Nunes', 'Santos', 'SP'),
('Luiza Castro', 'Campinas', 'SP'),
('Paulo Henrique', 'São Paulo', 'SP'),
('Carla Ribeiro', 'Curitiba', 'PR'),
('Eduardo Farias', 'Rio de Janeiro', 'RJ'),
('Renata Souza', 'Belo Horizonte', 'MG'),
('Vinícius Costa', 'Porto Alegre', 'RS'),
('Letícia Lopes', 'Londrina', 'PR'),
('Rodrigo Alves', 'Sorocaba', 'SP'),
('Daniela Rocha', 'Joinville', 'SC'),
('Matheus Duarte', 'São Paulo', 'SP'),
('Beatriz Moura', 'Curitiba', 'PR'),
('Henrique Ramos', 'Campinas', 'SP'),
('Débora Teixeira', 'São José dos Pinhais', 'PR'),
('César Pereira', 'Londrina', 'PR'),
('Fábio Cardoso', 'Curitiba', 'PR'),
('Larissa Brito', 'Belo Horizonte', 'MG'),
('Tiago Azevedo', 'Rio de Janeiro', 'RJ'),
('Adriana Neves', 'Campinas', 'SP'),
('Roberto Souza', 'São Paulo', 'SP'),
('Daniel Silva', 'Sorocaba', 'SP'),
('Fernanda Nogueira', 'Curitiba', 'PR'),
('Marcos Mendes', 'Porto Alegre', 'RS'),
('Sabrina Moreira', 'Joinville', 'SC'),
('Patrícia Lima', 'Londrina', 'PR'),
('Eduardo Oliveira', 'São Paulo', 'SP'),
('Lucas Andrade', 'Curitiba', 'PR'),
('Amanda Rocha', 'Florianópolis', 'SC'),
('Gabriel Barbosa', 'Campinas', 'SP'),
('Raquel Ribeiro', 'Sorocaba', 'SP'),
('Renan Dias', 'Curitiba', 'PR'),
('Joana Figueiredo', 'São José dos Pinhais', 'PR');








INSERT INTO dim_produto (nome_produto, categoria, preco_unitario) VALUES
('Pizza Margherita', 'Tradicional', 39.90),
('Pizza Calabresa', 'Tradicional', 42.50),
('Pizza 4 Queijos', 'Premium', 49.90),
('Pizza Portuguesa', 'Tradicional', 45.00),
('Pizza Frango c/ Catupiry', 'Tradicional', 44.50),
('Pizza Pepperoni', 'Premium', 48.90),
('Pizza Vegetariana', 'Especial', 46.50),
('Pizza Napolitana', 'Tradicional', 43.00),
('Pizza Bacon', 'Premium', 50.00),
('Pizza Toscana', 'Premium', 47.90),
('Pizza Alho e Óleo', 'Especial', 39.00),
('Pizza Rúcula c/ Tomate Seco', 'Especial', 49.00),
('Pizza Mexicana', 'Premium', 51.00),
('Pizza Mineira', 'Tradicional', 44.90),
('Pizza Baiana', 'Premium', 50.50),
('Pizza Quatro Estações', 'Premium', 52.00),
('Pizza Palmito', 'Tradicional', 43.90),
('Pizza Lombo', 'Tradicional', 45.90),
('Pizza Catuperu', 'Premium', 49.50),
('Pizza Três Queijos', 'Tradicional', 46.90),
('Pizza de Carne Seca', 'Premium', 50.90),
('Pizza Pepperoni e Bacon', 'Premium', 53.50),
('Pizza de Alho Poró', 'Especial', 46.00),
('Pizza Mediterrânea', 'Especial', 48.00),
('Pizza Supreme', 'Premium', 54.90),
('Pizza de Pesto', 'Especial', 47.50),
('Pizza Toscana c/ Gorgonzola', 'Premium', 52.90),
('Pizza Marguerita Especial', 'Premium', 48.50),
('Pizza Bacon Lovers', 'Premium', 55.00),
('Pizza Mista', 'Tradicional', 42.90),
('Pizza Portuguesa Especial', 'Premium', 49.90),
('Pizza Camarão', 'Premium', 59.90),
('Pizza Filé Mignon', 'Premium', 60.00),
('Pizza Provolone', 'Especial', 47.00),
('Pizza Hot', 'Premium', 53.00),
('Pizza Trufada', 'Gourmet', 65.00),
('Pizza Light', 'Especial', 39.90),
('Pizza Vegana', 'Especial', 44.00),
('Pizza Gorgonzola', 'Premium', 49.90),
('Pizza Italiana', 'Tradicional', 45.90),
('Pizza de Calabresa Picante', 'Premium', 51.90),
('Pizza Romeu e Julieta', 'Doce', 38.90),
('Pizza Chocolate', 'Doce', 42.00),
('Pizza Banana c/ Canela', 'Doce', 39.00),
('Pizza Sensação', 'Doce', 41.90),
('Pizza Nutella', 'Doce', 45.00),
('Pizza Brigadeiro', 'Doce', 40.50),
('Pizza Prestígio', 'Doce', 42.90),
('Pizza M&M’s', 'Doce', 43.90),
('Pizza de Morango', 'Doce', 41.50),
('Pizza Doce de Leite', 'Doce', 39.90);






INSERT INTO dim_vendedor (nome_vendedor, turno, filial) VALUES
('Carlos Silva', 'Noite', 'Centro'),
('Mariana Dias', 'Tarde', 'Água Verde'),
('João Ferreira', 'Noite', 'Centro'),
('Camila Rocha', 'Manhã', 'Centro'),
('Rafael Torres', 'Tarde', 'Centro'),
('Juliana Mendes', 'Noite', 'Centro'),
('André Oliveira', 'Tarde', 'Água Verde'),
('Paulo Souza', 'Manhã', 'Centro'),
('Isabela Santos', 'Tarde', 'Centro'),
('Patrícia Gomes', 'Noite', 'Centro'),
('Tiago Almeida', 'Tarde', 'Centro'),
('Amanda Ribeiro', 'Manhã', 'Centro'),
('Gustavo Costa', 'Noite', 'Água Verde'),
('Fernanda Lima', 'Tarde', 'Centro'),
('Eduardo Martins', 'Noite', 'Centro'),
('Larissa Teixeira', 'Manhã', 'Centro'),
('Renato Carvalho', 'Tarde', 'Centro'),
('Tatiane Nunes', 'Noite', 'Centro'),
('Rodrigo Silva', 'Noite', 'Água Verde'),
('Débora Ferreira', 'Manhã', 'Centro'),
('Joana Rocha', 'Tarde', 'Centro'),
('Felipe Castro', 'Noite', 'Centro'),
('Adriana Moreira', 'Tarde', 'Centro'),
('Gabriel Duarte', 'Manhã', 'Centro'),
('Luciana Farias', 'Noite', 'Centro'),
('Ricardo Oliveira', 'Tarde', 'Centro'),
('Vanessa Santos', 'Manhã', 'Centro'),
('Fábio Lopes', 'Tarde', 'Centro'),
('Beatriz Almeida', 'Noite', 'Centro'),
('Pedro Henrique', 'Tarde', 'Centro'),
('Sabrina Nogueira', 'Noite', 'Água Verde'),
('Fernando Rocha', 'Tarde', 'Centro'),
('Carla Ribeiro', 'Manhã', 'Centro'),
('Matheus Souza', 'Noite', 'Centro'),
('Lívia Castro', 'Tarde', 'Centro'),
('Luiz Eduardo', 'Manhã', 'Centro'),
('Renan Lima', 'Tarde', 'Centro'),
('Patrícia Alves', 'Noite', 'Centro'),
('Roberta Silva', 'Tarde', 'Centro'),
('Marcelo Costa', 'Manhã', 'Centro'),
('Tiago Ramos', 'Noite', 'Centro'),
('Aline Nunes', 'Tarde', 'Centro'),
('Caio Pereira', 'Manhã', 'Centro'),
('Cláudia Rocha', 'Tarde', 'Centro'),
('Rodrigo Dias', 'Noite', 'Centro'),
('Paula Carvalho', 'Manhã', 'Centro'),
('Mário Santos', 'Tarde', 'Centro'),
('Carolina Oliveira', 'Noite', 'Centro'),
('Bruno Ferreira', 'Tarde', 'Centro'),
('Juliana Souza', 'Manhã', 'Centro');




INSERT INTO dim_tempo (data_venda, dia, mes, nome_mes, ano, dia_semana) VALUES
('2025-10-01',1,10,'Outubro',2025,'Quarta-feira'),
('2025-10-02',2,10,'Outubro',2025,'Quinta-feira'),
('2025-10-03',3,10,'Outubro',2025,'Sexta-feira'),
('2025-10-04',4,10,'Outubro',2025,'Sábado'),
('2025-10-05',5,10,'Outubro',2025,'Domingo'),
('2025-10-06',6,10,'Outubro',2025,'Segunda-feira'),
('2025-10-07',7,10,'Outubro',2025,'Terça-feira'),
('2025-10-08',8,10,'Outubro',2025,'Quarta-feira'),
('2025-10-09',9,10,'Outubro',2025,'Quinta-feira'),
('2025-10-10',10,10,'Outubro',2025,'Sexta-feira'),
('2025-10-11',11,10,'Outubro',2025,'Sábado'),
('2025-10-12',12,10,'Outubro',2025,'Domingo'),
('2025-10-13',13,10,'Outubro',2025,'Segunda-feira'),
('2025-10-14',14,10,'Outubro',2025,'Terça-feira'),
('2025-10-15',15,10,'Outubro',2025,'Quarta-feira'),
('2025-10-16',16,10,'Outubro',2025,'Quinta-feira'),
('2025-10-17',17,10,'Outubro',2025,'Sexta-feira'),
('2025-10-18',18,10,'Outubro',2025,'Sábado'),
('2025-10-19',19,10,'Outubro',2025,'Domingo'),
('2025-10-20',20,10,'Outubro',2025,'Segunda-feira'),
('2025-10-21',21,10,'Outubro',2025,'Terça-feira'),
('2025-10-22',22,10,'Outubro',2025,'Quarta-feira'),
('2025-10-23',23,10,'Outubro',2025,'Quinta-feira'),
('2025-10-24',24,10,'Outubro',2025,'Sexta-feira'),
('2025-10-25',25,10,'Outubro',2025,'Sábado'),
('2025-10-26',26,10,'Outubro',2025,'Domingo'),
('2025-10-27',27,10,'Outubro',2025,'Segunda-feira'),
('2025-10-28',28,10,'Outubro',2025,'Terça-feira'),
('2025-10-29',29,10,'Outubro',2025,'Quarta-feira'),
('2025-10-30',30,10,'Outubro',2025,'Quinta-feira'),
('2025-10-31',31,10,'Outubro',2025,'Sexta-feira'),
('2025-11-01',1,11,'Novembro',2025,'Sábado'),
('2025-11-02',2,11,'Novembro',2025,'Domingo'),
('2025-11-03',3,11,'Novembro',2025,'Segunda-feira'),
('2025-11-04',4,11,'Novembro',2025,'Terça-feira'),
('2025-11-05',5,11,'Novembro',2025,'Quarta-feira'),
('2025-11-06',6,11,'Novembro',2025,'Quinta-feira'),
('2025-11-07',7,11,'Novembro',2025,'Sexta-feira'),
('2025-11-08',8,11,'Novembro',2025,'Sábado'),
('2025-11-09',9,11,'Novembro',2025,'Domingo'),
('2025-11-10',10,11,'Novembro',2025,'Segunda-feira'),
('2025-11-11',11,11,'Novembro',2025,'Terça-feira'),
('2025-11-12',12,11,'Novembro',2025,'Quarta-feira'),
('2025-11-13',13,11,'Novembro',2025,'Quinta-feira'),
('2025-11-14',14,11,'Novembro',2025,'Sexta-feira'),
('2025-11-15',15,11,'Novembro',2025,'Sábado'),
('2025-11-16',16,11,'Novembro',2025,'Domingo'),
('2025-11-17',17,11,'Novembro',2025,'Segunda-feira'),
('2025-11-18',18,11,'Novembro',2025,'Terça-feira'),
('2025-11-19',19,11,'Novembro',2025,'Quarta-feira');






INSERT INTO fact_venda (id_cliente, id_produto, id_vendedor, id_tempo, quantidade, valor_total) VALUES
(1, 1, 1, 1, 2, 79.80),
(2, 3, 5, 2, 1, 49.90),
(3, 5, 8, 3, 3, 133.50),
(4, 10, 6, 4, 2, 95.80),
(5, 7, 3, 5, 1, 46.50),
(6, 4, 2, 6, 2, 90.00),
(7, 6, 4, 7, 4, 195.60),
(8, 8, 1, 8, 3, 129.00),
(9, 9, 9, 9, 2, 100.00),
(10, 12, 10, 10, 1, 49.00),
(11, 14, 11, 11, 2, 100.00),
(12, 15, 12, 12, 1, 50.50),
(13, 16, 13, 13, 3, 156.00),
(14, 18, 14, 14, 2, 91.80),
(15, 19, 15, 15, 1, 49.50),
(16, 20, 16, 16, 4, 187.60),
(17, 21, 17, 17, 2, 101.80),
(18, 22, 18, 18, 1, 46.00),
(19, 23, 19, 19, 3, 144.00),
(20, 25, 20, 20, 1, 48.00),
(21, 26, 21, 21, 2, 105.80),
(22, 28, 22, 22, 3, 165.00),
(23, 29, 23, 23, 2, 110.00),
(24, 30, 24, 24, 1, 42.90),
(25, 32, 25, 25, 2, 119.80),
(26, 33, 26, 26, 1, 60.00),
(27, 34, 27, 27, 2, 94.00),
(28, 35, 28, 28, 3, 159.00),
(29, 36, 29, 29, 2, 130.00),
(30, 37, 30, 30, 1, 39.90),
(31, 38, 31, 31, 4, 176.00),
(32, 39, 32, 32, 2, 99.80),
(33, 40, 33, 33, 3, 137.70),
(34, 41, 34, 34, 1, 38.90),
(35, 42, 35, 35, 2, 84.00),
(36, 43, 36, 36, 1, 39.00),
(37, 44, 37, 37, 2, 83.80),
(38, 45, 38, 38, 3, 135.00),
(39, 46, 39, 39, 2, 81.00),
(40, 47, 40, 40, 1, 40.50),
(41, 48, 41, 41, 3, 128.70),
(42, 49, 42, 42, 2, 87.80),
(43, 50, 43, 43, 1, 39.90),
(44, 2, 44, 44, 2, 85.00),
(45, 5, 45, 45, 3, 133.50),
(46, 9, 46, 46, 1, 50.00),
(47, 12, 47, 47, 2, 98.00),
(48, 16, 48, 48, 3, 156.00),
(49, 20, 49, 49, 4, 187.60),
(50, 25, 50, 50, 2, 96.00);


-- =============================================================
-- MISSAO 02 | POPULANDO O DATA WAREHOUSE
-- Executar aqui os INSERTs do arquivo do professor, NESTA ORDEM:
--   1) dim_cliente  2) dim_produto  3) dim_vendedor  4) dim_tempo
--   5) fact_venda (por ultimo: depende das chaves das dimensoes)
-- Os valores originais NAO devem ser alterados.
-- =============================================================

-- Conferencia 1: quantidade de registros por tabela (esperado: 50 em cada).
SELECT 'dim_cliente' AS tabela, COUNT(*) AS registros FROM dim_cliente
UNION ALL SELECT 'dim_produto',  COUNT(*) FROM dim_produto
UNION ALL SELECT 'dim_vendedor', COUNT(*) FROM dim_vendedor
UNION ALL SELECT 'dim_tempo',    COUNT(*) FROM dim_tempo
UNION ALL SELECT 'fact_venda',   COUNT(*) FROM fact_venda;

-- Conferencia 2: integridade. Toda venda precisa apontar para
-- dimensoes existentes. Deve retornar ZERO linhas.
SELECT f.id_venda
FROM fact_venda f
LEFT JOIN dim_cliente  c ON c.id_cliente  = f.id_cliente
LEFT JOIN dim_produto  p ON p.id_produto  = f.id_produto
LEFT JOIN dim_vendedor v ON v.id_vendedor = f.id_vendedor
LEFT JOIN dim_tempo    t ON t.id_tempo    = f.id_tempo
WHERE c.id_cliente IS NULL OR p.id_produto IS NULL
   OR v.id_vendedor IS NULL OR t.id_tempo IS NULL;

-- Conferencia 3 (totais gerais, usados como referencia):
-- esperado: 50 registros | 104 unidades | R$ 4.948,90
SELECT COUNT(*) AS registros, SUM(quantidade) AS unidades, SUM(valor_total) AS faturamento
FROM fact_venda;


-- =============================================================
-- MISSAO 03 | QUAIS PIZZAS MAIS VENDEM EM CADA FILIAL?
-- Fato + dim_vendedor (filial) + dim_produto (nome da pizza).
-- Medida: SUM(quantidade) = unidades vendidas.
-- =============================================================
SELECT
    v.filial,
    p.nome_produto        AS pizza,
    SUM(f.quantidade)     AS unidades_vendidas
FROM fact_venda f
JOIN dim_vendedor v ON v.id_vendedor = f.id_vendedor
JOIN dim_produto  p ON p.id_produto  = f.id_produto
GROUP BY v.filial, p.nome_produto
ORDER BY v.filial, unidades_vendidas DESC, p.nome_produto;

-- (Complemento) Somente a pizza campea de cada filial, usando
-- funcao de janela do MySQL 8. RANK() mantem empates, se houver.
SELECT filial, pizza, unidades_vendidas
FROM (
    SELECT
        v.filial,
        p.nome_produto    AS pizza,
        SUM(f.quantidade) AS unidades_vendidas,
        RANK() OVER (PARTITION BY v.filial ORDER BY SUM(f.quantidade) DESC) AS posicao
    FROM fact_venda f
    JOIN dim_vendedor v ON v.id_vendedor = f.id_vendedor
    JOIN dim_produto  p ON p.id_produto  = f.id_produto
    GROUP BY v.filial, p.nome_produto
) ranking
WHERE posicao = 1
ORDER BY filial;


-- =============================================================
-- MISSAO 04 | QUAIS DIAS DA SEMANA TEM MAIOR FATURAMENTO?
-- Fato + dim_tempo (dia_semana).
-- Medidas: SUM(quantidade) e SUM(valor_total).
-- =============================================================
SELECT
    t.dia_semana,
    SUM(f.quantidade)  AS unidades_vendidas,
    SUM(f.valor_total) AS faturamento_total
FROM fact_venda f
JOIN dim_tempo t ON t.id_tempo = f.id_tempo
GROUP BY t.dia_semana
ORDER BY faturamento_total DESC;


-- =============================================================
-- MISSAO 05 | QUAL VENDEDOR APRESENTA O MELHOR DESEMPENHO?
-- Fato + dim_vendedor. Agrupa pelo id (evita juntar dois
-- vendedores homonimos) e exibe nome, filial e turno.
-- =============================================================
SELECT
    v.nome_vendedor,
    v.filial,
    v.turno,
    SUM(f.quantidade)  AS unidades_vendidas,
    SUM(f.valor_total) AS faturamento_total
FROM fact_venda f
JOIN dim_vendedor v ON v.id_vendedor = f.id_vendedor
GROUP BY v.id_vendedor, v.nome_vendedor, v.filial, v.turno
ORDER BY faturamento_total DESC;


-- =============================================================
-- MISSAO 06 | COMO O TICKET MEDIO VARIA ENTRE CIDADES?
-- Fato + dim_cliente (cidade).
-- Ticket medio = faturamento / numero de registros da fato
-- (cada linha da fact_venda e uma unidade de analise).
-- AVG(valor_total) faz exatamente SUM(valor_total) / COUNT(*).
-- =============================================================
SELECT
    c.cidade,
    c.estado,
    COUNT(*)                     AS registros_venda,
    SUM(f.valor_total)           AS faturamento_total,
    ROUND(AVG(f.valor_total), 2) AS ticket_medio
FROM fact_venda f
JOIN dim_cliente c ON c.id_cliente = f.id_cliente
GROUP BY c.cidade, c.estado
ORDER BY ticket_medio DESC;


-- =============================================================
-- MISSAO 07 | TRANSFORMANDO DADOS EM DECISOES
-- Analise gerencial baseada nos resultados das Missoes 03 a 06.
-- (A versao completa vai no PDF; aqui ficam as respostas e as
--  consultas de apoio que fundamentam as recomendacoes.)
-- Referencia geral: 50 vendas | 104 unidades | R$ 4.948,90.
-- =============================================================

-- -------------------------------------------------------------
-- 7.1 Qual pizza apresenta maior quantidade vendida em cada filial?
-- Fonte: Missao 03 (consulta com RANK()).
--   Centro     -> Pizza Tres Queijos (8 unidades)
--   Agua Verde -> Pizza Vegana       (4 unidades)
-- O que significa: no Centro a preferencia e por uma pizza
-- Tradicional; na Agua Verde, por uma Especial. Os publicos sao
-- diferentes, entao producao e promocoes devem ser planejadas por
-- filial, e nao de forma unica para a rede.
-- Atencao: a base e desbalanceada (45 vendedores no Centro e 5 na
-- Agua Verde), por isso o volume do Centro e naturalmente maior.
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 7.2 Qual dia da semana apresentou o maior faturamento?
-- Fonte: Missao 04.
--   Terca-feira -> R$ 911,60 (19 unidades)
--   Sabado (R$ 592,40) e domingo (R$ 577,20) ficaram em ultimo.
-- O que significa: o fim de semana, que costuma ser o pico de uma
-- pizzaria, e o periodo mais fraco da rede. Ha espaco para
-- aumentar a receita justamente nesses dias.
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 7.3 Qual vendedor obteve o melhor desempenho em faturamento?
-- Fonte: Missao 05.
--   Carlos Silva (Centro, Noite) -> R$ 208,80 (5 unidades)
--   Em seguida: Camila Rocha (R$ 195,60) e, empatados,
--   Bruno Ferreira e Larissa Teixeira (R$ 187,60).
-- O que significa: o turno da noite concentra o maior faturamento
-- (ver consulta de apoio 7.A). As praticas de Carlos Silva podem
-- servir de referencia em treinamentos para os demais vendedores.
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 7.4 Qual cidade apresentou o maior ticket medio?
-- Fonte: Missao 06.
--   Santos -> R$ 144,00 (apenas 1 venda)
--   Com mais vendas: Joinville (R$ 134,27 em 3 vendas) e
--   Campinas (R$ 120,28 em 5 vendas).
--   Curitiba tem o maior volume (10 vendas, R$ 974,60), mas um
--   ticket menor (R$ 97,46).
-- O que significa: Santos lidera, mas uma unica venda nao e uma
-- amostra confiavel. Joinville e Campinas mostram clientes que
-- gastam mais por pedido de forma mais consistente. Curitiba
-- compra com frequencia, mas gasta menos por pedido.
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 7.5 Duas acoes recomendadas
--
-- ACAO 1: Promocao de fim de semana.
--   Base: Missao 04 (sabado e domingo com menor faturamento).
--   Proposta: combos e promocoes especificas para sabado e
--   domingo, com destaque para as pizzas Premium, que sao a
--   categoria de maior faturamento (consulta de apoio 7.B).
--
-- ACAO 2: Aumentar o ticket medio em Curitiba e planejar por filial.
--   Base: Missoes 03 e 06.
--   Proposta: em Curitiba, que ja tem volume alto, oferecer
--   combos (pizza + doce) para elevar o valor por pedido. Na
--   producao, reforcar Tres Queijos no Centro e Vegana/Especiais
--   na Agua Verde.
--
-- Observacao sobre a qualidade dos dados: em 14 das 50 vendas,
-- valor_total nao e igual a quantidade x preco_unitario (consulta
-- de apoio 7.C). Como os dados originais nao podem ser alterados,
-- as analises usam valor_total como registrado. Recomenda-se que
-- a empresa revise a origem desses valores (descontos, acrescimos
-- ou erro de registro no sistema OLTP).
-- -------------------------------------------------------------

-- Consulta de apoio 7.A: faturamento por turno.
SELECT
    v.turno,
    COUNT(*)           AS registros_venda,
    SUM(f.valor_total) AS faturamento_total
FROM fact_venda f
JOIN dim_vendedor v ON v.id_vendedor = f.id_vendedor
GROUP BY v.turno
ORDER BY faturamento_total DESC;

-- Consulta de apoio 7.B: faturamento por categoria de pizza.
SELECT
    p.categoria,
    SUM(f.quantidade)  AS unidades_vendidas,
    SUM(f.valor_total) AS faturamento_total
FROM fact_venda f
JOIN dim_produto p ON p.id_produto = f.id_produto
GROUP BY p.categoria
ORDER BY faturamento_total DESC;

-- Consulta de apoio 7.C: vendas em que valor_total difere de
-- quantidade x preco_unitario (deve retornar 14 linhas).
SELECT
    f.id_venda,
    p.nome_produto,
    f.quantidade,
    p.preco_unitario,
    f.valor_total,
    f.quantidade * p.preco_unitario AS valor_calculado
FROM fact_venda f
JOIN dim_produto p ON p.id_produto = f.id_produto
WHERE f.valor_total <> f.quantidade * p.preco_unitario
ORDER BY f.id_venda;

-- Consulta de apoio 7.D: quantidade de vendedores por filial
-- (explica o desbalanceamento entre Centro e Agua Verde).
SELECT filial, COUNT(*) AS vendedores
FROM dim_vendedor
GROUP BY filial;

