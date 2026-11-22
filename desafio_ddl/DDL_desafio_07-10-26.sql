CREATE DATABASE sql_quest;

USE sql_quest;

CREATE TABLE jogadores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    classe VARCHAR(50) NOT NULL,
    nivel INT NOT NULL,
    moedas INT NOT NULL DEFAULT 0,
    pontos INT NOT NULL,
    guilda VARCHAR(50),
    bonus INT,
    status_jogador VARCHAR(30) NOT NULL,
    classificacao VARCHAR(30)
);

INSERT INTO jogadores
(nome, classe, nivel, moedas, pontos, guilda, bonus, status_jogador)
VALUES
('Arthas', 'Guerreiro', 18, 950, 7200, 'Dragões', 500, 'ATIVO'),

('Luna', 'Maga', 22, 1500, 9800, 'Fênix', NULL, 'ATIVO'),

('Thorim', 'Guerreiro', 15, 450, 5100, 'Dragões', 300, 'ATIVO'),

('Nyx', 'Assassina', 26, 2100, 12500, 'Sombras', NULL, 'ATIVO'),

('Eldrin', 'Mago', 12, 300, 3900, 'Fênix', 200, 'ATIVO'),

('Kael', 'Arqueiro', 20, 1100, 8300, 'Dragões', NULL, 'ATIVO'),

('Morgana', 'Maga', 30, 3200, 16000, 'Sombras', 1000, 'ATIVO'),

('Ragnar', 'Guerreiro', 8, 150, 1800, 'Dragões', NULL, 'INATIVO'),

('Lyra', 'Arqueira', 17, 700, 6500, 'Fênix', 400, 'ATIVO'),

('Draven', 'Assassino', 25, 1800, 11200, 'Sombras', 700, 'ATIVO'),

('Orion', 'Mago', 6, 80, 900, NULL, NULL, 'INATIVO'),

('Freya', 'Guerreira', 21, 1300, 8900, 'Dragões', 600, 'ATIVO');


SELECT 
	COUNT(*) AS total_jogadores,
    COUNT(*) - COUNT(classificacao) AS sem_classificacao
FROM sql_quest.jogadores;


-- 1 — Reconstruir a classificação por pontos.
SELECT
	id,
    nome,
    pontos,
    classificacao AS classificacao_atual,
    CASE
		WHEN pontos >= 12000 THEN 'LENDÁRIO'
        WHEN pontos >= 8000 THEN 'ELITE'
        WHEN pontos >= 5000 THEN 'VETERANO'
        ELSE 'APRENDIZ'
	END AS nova_classificacao
FROM sql_quest.jogadores
ORDER BY pontos DESC, id;

SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

UPDATE sql_quest.jogadores
SET classificacao = CASE
    WHEN pontos >= 12000 THEN 'LENDÁRIO'
    WHEN pontos >= 8000  THEN 'ELITE'
    WHEN pontos >= 5000  THEN 'VETERANO'
    ELSE 'APRENDIZ'
END
WHERE classificacao IS NULL;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

SELECT 
	classificacao,
    COUNT(*) AS qtd_jogadores
FROM sql_quest.jogadores
GROUP BY classificacao
ORDER BY MAX(pontos) DESC;

-- 2 — Corrigir os bônus ausentes.
-- Conferindo quem será alterado
SELECT
	id,
    nome,
    bonus AS bonus_atual,
    COALESCE(bonus, 0) AS bonus_corrigido
FROM sql_quest.jogadores
WHERE bonus IS NULL
ORDER BY id;

-- Gerindo as correções
SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

UPDATE sql_quest.jogadores
SET bonus = COALESCE(bonus, 0)
WHERE bonus IS NULL;

SELECT ROW_COUNT() AS jogadores_atualizados;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

SELECT
    COUNT(*) AS total_jogadores,
    COUNT(*) - COUNT(bonus) AS bonus_nulos,
    COUNT(CASE WHEN bonus = 0 THEN 1 END) AS bonus_zerados
FROM sql_quest.jogadores;

-- 3 - RECOMPENSAR OS JOGADORES ACIMA DA MÉDIA.
SELECT 
	j.nome,
    j.pontos,
    m.media_pontos,
    j.moedas AS moedas_atuais,
    j.moedas + 250 AS moedas_apos_recompensa
FROM sql_quest.jogadores AS j
CROSS JOIN (
	SELECT AVG(pontos) AS media_pontos
    FROM sql_quest.jogadores
) AS m
WHERE j.pontos > m.media_pontos
ORDER BY j.pontos DESC, j.id;

SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

UPDATE sql_quest.jogadores AS j
CROSS JOIN (
    SELECT AVG(pontos) AS media_pontos
    FROM sql_quest.jogadores
) AS m
SET j.moedas = j.moedas + 250
WHERE j.pontos > m.media_pontos;

SELECT ROW_COUNT() AS jogadores_recompensados;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

-- 4 - GUERRA DAS GUILDAS.

SELECT 
	guilda,
    COUNT(*) AS integrantes,
    ROUND(AVG(pontos), 2) AS media_pontos
FROM sql_quest.jogadores
WHERE guilda IS NOT NULL
GROUP BY guilda
ORDER BY media_pontos DESC;

SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

UPDATE sql_quest.jogadores AS j
INNER JOIN (
	SELECT guilda
    FROM sql_quest.jogadores
    WHERE guilda IS NOT NULL
    GROUP BY guilda
    HAVING AVG(pontos) > 7000
) AS vencedoras
	ON vencedoras.guilda = j.guilda
SET j.moedas = j.moedas + 300;

SELECT ROW_COUNT() AS jogadres_recompensados;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

-- JOGADORES RECOMPENSADOS
SELECT nome, moedas
FROM sql_quest.jogadores
WHERE guilda = 'Sombras'
ORDER BY pontos DESC;


-- 5 - CONSELHO DOS CAMPEÕES
SELECT
    id,
    nome,
    pontos,
    nivel AS nivel_atual,
    nivel + 1 AS nivel_apos_promocao
FROM sql_quest.jogadores
ORDER BY pontos DESC, id ASC
LIMIT 3;

UPDATE sql_quest.jogadores
SET nivel = nivel + 1
ORDER BY pontos DESC, id ASC
LIMIT 3;

SELECT ROW_COUNT() AS jogadores_promovidos;

-- 6 - TREINAMENTO EMERGENCIAL.
SELECT
    id,
    nome,
    status_jogador,
    nivel AS nivel_atual,
    nivel + 2 AS nivel_apos_treinamento
FROM sql_quest.jogadores
WHERE status_jogador = 'ATIVO'
  AND nivel < 18
ORDER BY id;

SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

UPDATE sql_quest.jogadores
SET nivel = nivel + 2
WHERE status_jogador = 'ATIVO'
  AND nivel < 18;

SELECT ROW_COUNT() AS jogadores_treinados;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

SELECT id, nome, nivel
FROM sql_quest.jogadores
WHERE id IN (3, 5, 9)
ORDER BY id;

-- 7 - REMOVER OS ESPIÕES DE NULLMASTER
SELECT id, nome, pontos, status_jogador
FROM sql_quest.jogadores
WHERE status_jogador = 'INATIVO'
  AND pontos < 2000
ORDER BY id;

SET @quest_safe_updates_anterior = @@SESSION.sql_safe_updates;
SET SESSION sql_safe_updates = 0;

DELETE FROM sql_quest.jogadores
WHERE status_jogador = 'INATIVO'
  AND pontos < 2000;

SELECT ROW_COUNT() AS jogadores_removidos;

SET SESSION sql_safe_updates = @quest_safe_updates_anterior;

SELECT COUNT(*) AS jogadores_restantes
FROM sql_quest.jogadores;

SELECT
    id,
    nome,
    nivel,
    moedas,
    pontos,
    guilda,
    bonus,
    status_jogador,
    classificacao
FROM sql_quest.jogadores
ORDER BY pontos DESC, id ASC;
