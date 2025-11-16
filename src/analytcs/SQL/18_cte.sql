-- 11. Quem iniciou o curso no primeiro dia, em média, assistiu quantas aulas?

WITH 
    tb_cliente_primeiro_dia AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-25'
    ),
    tb_dias_curso AS (
        SELECT DISTINCT
            t2.IdCliente,
            substr(DtCriacao,1,10) AS dtDia
        FROM transacoes AS t1
            INNER JOIN tb_cliente_primeiro_dia AS t2
            ON t1.IdCliente = t2.IdCliente
        WHERE
            dtDia >= '2025-08-25'
            AND dtDia < '2025-08-30'
    ), 
    tb_percent_cliente AS (
        SELECT
            IdCliente,
            (cast(count(dtDia) AS FLOAT)/5)*100 AS medDias_per
        FROM tb_dias_curso
        GROUP BY IdCliente
    )

SELECT avg(medDias_per) * 5/100 AS medDias
FROM tb_percent_cliente





