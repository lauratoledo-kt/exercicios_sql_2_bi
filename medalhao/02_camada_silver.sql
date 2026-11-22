-- Script 02: estrutura de destino. NÃO insere nem transforma dados.
CREATE DATABASE IF NOT EXISTS db_silver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_silver;
DROP TABLE IF EXISTS tb_vendas_rejeitadas;
DROP TABLE IF EXISTS tb_vendas;
DROP TABLE IF EXISTS tb_clientes;

CREATE TABLE tb_clientes (
 id_cliente INT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(120) NULL,
 status_email ENUM('VALIDO','CORRIGIDO','INVALIDO') NOT NULL,
 cidade VARCHAR(100),
 data_cadastro DATE NULL
);
CREATE TABLE tb_vendas (
 id_venda INT PRIMARY KEY,
 id_cliente INT NOT NULL,
 valor_venda DECIMAL(12,2) NOT NULL,
 data_venda DATE NOT NULL,
 produto VARCHAR(100) NOT NULL,
 CONSTRAINT fk_venda_cliente FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente)
);
CREATE TABLE tb_vendas_rejeitadas (
 id_venda INT PRIMARY KEY,
 id_cliente INT,
 valor_venda_original VARCHAR(30),
 data_venda_original VARCHAR(30),
 produto VARCHAR(100),
 motivo VARCHAR(60) NOT NULL
);
