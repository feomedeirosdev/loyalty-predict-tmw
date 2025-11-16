WITH
    tb_cliente_dia AS (
        SELECT
            IdCliente,
            substr(DtCriacao,1,10) AS dtDia,
            count(DISTINCT IdTransacao) AS qtdeTransacao
        FROM transacoes
        WHERE
            DtCriacao >= '2025-08-25'
            AND DtCriacao < '2025-08-30'
        GROUP BY IdCliente, dtDia
    ), 
    tb_lag AS (
        SELECT
            *,
            sum(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS Acum,
            lag(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS LagTransacao,
            CASE
                WHEN lag(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) IS NULL THEN 0 
                ELSE lag(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) 
            END AS NewLagTransacao,
            sum(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) - 
            CASE
                WHEN lag(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) IS NULL THEN 0 
                ELSE lag(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) 
            END AS Diff
        FROM tb_cliente_dia
    )

SELECT
    IdCliente,
    dtDia,
    qtdeTransacao,
    Acum,
    NewLagTransacao,
    Diff,
    round((1.0 * qtdeTransacao / NewLagTransacao)*100,2) AS Prop
    
FROM tb_lag 