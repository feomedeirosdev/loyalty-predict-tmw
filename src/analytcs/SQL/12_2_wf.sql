-- Qual é o dia com maior engajamento de cada aluno que iniciou o curso no dia 01 do curso?

WITH
    tb_alunos_dia_01 AS (
        SELECT DISTINCT IdCliente 
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-25'
    ),
    tb_transacoes_dias_de_curso AS (
        SELECT
            IdTransacao,
            IdCliente,
            substr(DtCriacao,1,10) AS dtDia
        FROM transacoes
        WHERE
            substr(DtCriacao,1,10) >= '2025-08-25' 
            AND substr(DtCriacao,1,10) < '2025-08-30'
    ),
    tb_dia_cliente AS (
        SELECT
            t1.IdCliente,
            t2.dtDia,
            count(*) AS qdtInteracoes
        FROM tb_alunos_dia_01 AS t1
            LEFT JOIN tb_transacoes_dias_de_curso AS t2
            ON t1.IdCliente = t2.IdCliente
        GROUP BY t1.IdCliente, t2.dtDia
        ORDER BY 1, 3 DESC
    ), 
    tb_rn AS (
        SELECT 
        *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qdtInteracoes DESC, dtDia) AS rn
    
        FROM tb_dia_cliente
    )

SELECT IdCliente, dtDia, qdtInteracoes
FROM tb_rn WHERE rn = 1
    