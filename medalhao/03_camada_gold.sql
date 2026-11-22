-- Script 03: estrutura analítica; o povoamento é missão dos alunos.
CREATE DATABASE IF NOT EXISTS db_gold CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_gold;
DROP TABLE IF EXISTS tb_relatorio_vendas;
CREATE TABLE tb_relatorio_vendas (
 id_cliente INT PRIMARY KEY,
 nome_cliente VARCHAR(100) NOT NULL,
 total_vendas DECIMAL(14,2) NOT NULL,
 qtd_vendas INT NOT NULL,
 ticket_medio DECIMAL(14,2) NOT NULL
);
