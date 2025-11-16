-- Qual é o dia com maior engajamento de cada aluno que iniciou o curso no dia 01 do curso?

WITH
    tb_alunos_dia_01 AS (
        SELECT DISTINCT IdCliente 
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-25'
    )
    
SELECT
    t1.IdCliente,
    substr(t2.DtCriacao,1,10) AS dtDia,
    count(*) AS qtdeInteracoes

FROM tb_alunos_dia_01 AS t1

LEFT JOIN transacoes AS t2
ON t1.IdCliente = t2.IdCliente
AND substr(t2.DtCriacao,1,10) >= '2025-08-25'
AND substr(t2.DtCriacao,1,10) < '2025-08-30'

GROUP BY t1.IdCliente, dtDia

ORDER BY 