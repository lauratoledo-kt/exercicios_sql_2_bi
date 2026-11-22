-- LABORATÓRIO: ARQUITETURA MEDALHÃO | MySQL 8.0+
-- Script 01: dados BRUTOS, com inconsistências intencionais.
-- Execute em ambiente de laboratório. Os DROP abaixo removem tabelas anteriores!
CREATE DATABASE IF NOT EXISTS db_bronze CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_bronze;
DROP TABLE IF EXISTS tb_vendas_raw;
DROP TABLE IF EXISTS tb_clientes_raw;

CREATE TABLE tb_clientes_raw (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(120),
    cidade VARCHAR(100),
    data_cadastro VARCHAR(30)
);
CREATE TABLE tb_vendas_raw (
    id_venda INT PRIMARY KEY,
    id_cliente INT,
    valor_venda VARCHAR(30),
    data_venda VARCHAR(30),
    produto VARCHAR(100)
);

-- A Bronze preserva a representação recebida da origem.
INSERT INTO tb_clientes_raw (id_cliente, nome, email, cidade, data_cadastro) VALUES
(1, 'Ana Silva', 'ana.silva@gmail.com', 'São Paulo', '2023/01/15'),
(2, 'João Souza', 'joao.souza@', 'Curitiba', '20-01-2023'),
(3, 'Maria Lima', 'maria.lima@gmail.com', 'Rio de Janeiro', '2023.01.25'),
(4, 'Carlos Pereira', 'carlos.pereira@gmail.com', 'Porto Alegre', '2023-01-30'),
(5, 'Fernanda Alves', 'fernanda@gmail', 'Curitiba', '2023/02/04'),
(6, 'Lucas Santos', 'lucas.santos@gmail.com', 'São Paulo', '09-02-2023'),
(7, 'Pedro Rocha', 'pedro.rocha@gmail.com', 'Fortaleza', '2023.02.14'),
(8, 'Juliana Dias', 'juliana.dias@gmail.com', 'Curitiba', '2023-02-19'),
(9, 'Ricardo Martins', 'ricardo.martins@gmail.com', 'Salvador', '2023/02/24'),
(10, 'Patrícia Souza', 'patricia.souza@gmail.com', 'São Paulo', '01-03-2023'),
(11, 'Beatriz Costa', 'beatriz.costa@gmail.com', 'Curitiba', '2023.03.06'),
(12, 'Rafael Oliveira', 'rafael.oliveira@gmail.com', 'Belo Horizonte', '2023-03-11'),
(13, 'Camila Ferreira', 'camila.ferreira@', 'Curitiba', '2023/03/16'),
(14, 'Bruno Almeida', 'bruno.almeida@gmail.com', 'Recife', '21-03-2023'),
(15, 'Larissa Ribeiro', 'larissa.ribeiro@gmail.com', 'Florianópolis', '2023.03.26'),
(16, 'Gustavo Mendes', 'gustavo.mendes@gmail.com', 'Curitiba', '2023-03-31'),
(17, 'Mariana Rocha', 'mariana.rocha@gmail.com', 'São Paulo', '2023/04/05'),
(18, 'Diego Martins', 'diego.martins@gmail.com', 'Brasília', '10-04-2023'),
(19, 'Aline Barbosa', 'aline.barbosa@gmail.com', 'Curitiba', '2023.04.15'),
(20, 'Felipe Gomes', 'felipe.gomes@gmail.com', 'Fortaleza', '2023-04-20'),
(21, 'Renata Castro', 'renata.castro@gmail.com', 'Curitiba', '2023/04/25'),
(22, 'Thiago Ribeiro', 'thiago.ribeiro@gmail.com', 'Porto Alegre', '30-04-2023'),
(23, 'Vanessa Lima', 'vanessa.lima@gmail.com', 'São Paulo', '2023.05.05'),
(24, 'Eduardo Correia', 'eduardo.correia@gmail.com', 'Curitiba', '2023-05-10'),
(25, 'Sofia Nunes', 'sofia.nunes@gmail.com', 'Curitiba', '2023/05/15');

INSERT INTO tb_vendas_raw (id_venda, id_cliente, valor_venda, data_venda, produto) VALUES
(1, 8, '150.5', '2023/07/04', 'Monitor'),
(2, 15, '75.50', '07-07-2023', 'Mousepad'),
(3, 22, '2.399,00', '2023.07.10', 'Webcam'),
(4, 5, '999,99', '2023-07-13', 'Mouse Gamer'),
(5, 12, '1.750,00', '2023/07/16', 'Monitor'),
(6, 19, '45', '19-07-2023', 'Mousepad'),
(7, 2, '399,90', '2023.07.22', 'Webcam'),
(8, 9, 'NaN', '2023-07-25', 'Mouse Gamer'),
(9, 16, '139,90', '2023/07/28', 'Monitor'),
(10, 23, '450', '31-07-2023', 'Mousepad'),
(11, 6, '89,9', '2023.08.03', 'Webcam'),
(12, 13, '580,00', '2023-08-06', 'Mouse Gamer'),
(13, 20, '1.200,00', '2023/08/09', 'Monitor'),
(14, 3, '220', '12-08-2023', 'Mousepad'),
(15, 10, '320,00', '2023.08.15', 'Webcam'),
(16, 17, '250,00', '2023-08-18', 'Mouse Gamer'),
(17, 24, '150.5', '2023/08/21', 'Monitor'),
(18, 7, '75.50', '24-08-2023', 'Mousepad'),
(19, 14, '0', '2023.08.27', 'Webcam'),
(20, 21, '999,99', '2023-08-30', 'Mouse Gamer'),
(21, 4, '1.750,00', '2023/07/03', 'Monitor'),
(22, 11, '45', '06-07-2023', 'Mousepad'),
(23, 18, '399,90', '2023.07.09', 'Webcam'),
(24, 1, '85,00', '2023-07-12', 'Mouse Gamer'),
(25, 8, '139,90', '2023/07/15', 'Monitor'),
(26, 15, '450', '18-07-2023', 'Mousepad'),
(27, 22, '89,9', '2023.07.21', 'Webcam'),
(28, 5, '580,00', '2023-07-24', 'Mouse Gamer'),
(29, 12, '1.200,00', '2023/07/27', 'Monitor'),
(30, 19, '-20,00', '30-07-2023', 'Mousepad'),
(31, 2, '320,00', '2023.08.02', 'Webcam'),
(32, 9, '250,00', '2023-08-05', 'Mouse Gamer'),
(33, 16, '150.5', '2023/08/08', 'Monitor'),
(34, 23, '75.50', '11-08-2023', 'Mousepad'),
(35, 6, '2.399,00', '2023.08.14', 'Webcam'),
(36, 13, '999,99', '2023-08-17', 'Mouse Gamer'),
(37, 20, '1.750,00', '2023/08/20', 'Monitor'),
(38, 3, '45', '23-08-2023', 'Mousepad'),
(39, 10, '399,90', '2023.08.26', 'Webcam'),
(40, 17, '85,00', '2023-08-29', 'Mouse Gamer'),
(41, 999, '139,90', '2023/07/02', 'Monitor'),
(42, 7, '450', '05-07-2023', 'Mousepad'),
(43, 14, '89,9', '2023.07.08', 'Webcam'),
(44, 21, '580,00', '2023-07-11', 'Mouse Gamer'),
(45, 4, '1.200,00', '2023/07/14', 'Monitor'),
(46, 11, '220', '17-07-2023', 'Mousepad'),
(47, 18, '320,00', '2023.07.20', 'Webcam'),
(48, 1, '250,00', '2023-07-23', 'Mouse Gamer'),
(49, 8, '150.5', '2023/07/26', 'Monitor'),
(50, 15, '75.50', '29-07-2023', 'Mousepad'),
(51, 22, '2.399,00', '2023.08.01', 'Webcam'),
(52, 5, '999,99', '2023-08-04', 'Mouse Gamer'),
(53, 12, '1.750,00', '2023/08/07', 'Monitor'),
(54, 19, '45', '10-08-2023', 'Mousepad'),
(55, 2, '399,90', 'sem-data', 'Webcam'),
(56, 9, '85,00', '2023-08-16', 'Mouse Gamer'),
(57, 16, '139,90', '2023/08/19', 'Monitor'),
(58, 23, '450', '22-08-2023', 'Mousepad'),
(59, 6, '89,9', '2023.08.25', 'Webcam'),
(60, 13, '580,00', '2023-08-28', 'Mouse Gamer'),
(61, 20, '1.200,00', '2023/07/01', 'Monitor'),
(62, 3, '220', '04-07-2023', 'Mousepad'),
(63, 10, '320,00', '2023.07.07', 'Webcam'),
(64, 17, '250,00', '2023-07-10', 'Mouse Gamer'),
(65, 24, '150.5', '2023/07/13', 'Monitor'),
(66, 7, '75.50', '16-07-2023', 'Mousepad'),
(67, 14, '2.399,00', '2023.07.19', 'Webcam'),
(68, 21, '999,99', '2023-07-22', 'Mouse Gamer'),
(69, 4, '1.750,00', '2023/07/25', 'Monitor'),
(70, 11, '45', '28-07-2023', 'Mousepad'),
(71, 18, '399,90', '2023.07.31', 'Webcam'),
(72, 1, '85,00', '2023-08-03', 'Mouse Gamer');

SELECT COUNT(*) AS clientes_raw FROM tb_clientes_raw;
SELECT COUNT(*) AS vendas_raw FROM tb_vendas_raw;



