-- 10. Como foi a curva de Churn do Curso de SQL?

/* SELECT
    substr(DtCriacao,1,10) AS dtDia,
    count(DISTINCT IdCliente) AS qtdeAtivados
FROM transacoes
WHERE DtCriacao >= '2025-08-25' AND DtCriacao < '2025-08-30'
GROUP BY substr(DtCriacao,1,10) */

WITH
    tb_clientes_d1 AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-25'
    )

SELECT
    substr(t2.DtCriacao,1,10) AS dtDia,
    count(DISTINCT t1.IdCliente) AS qtdeClientes,
    round(cast(count(DISTINCT t1.IdCliente) AS FLOAT) / (SELECT count (*) FROM tb_clientes_d1), 2) AS prop,
    round(1-(cast(count(DISTINCT t1.IdCliente) AS FLOAT) / (SELECT count (*) FROM tb_clientes_d1)), 2) AS prop_churn
    
FROM
    tb_clientes_d1 AS t1
    LEFT JOIN transacoes AS t2
    ON t1.IdCliente = t2.IdCliente 

WHERE DtCriacao >= '2025-08-25' AND DtCriacao < '2025-08-30'

GROUP BY 1