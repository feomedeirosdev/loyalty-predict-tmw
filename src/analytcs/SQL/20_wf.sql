WITH
    cliente_dias AS (
        SELECT DISTINCT
            IdCliente,
            substr(DtCriacao,1,10) AS dtDia
        FROM transacoes
        WHERE substr(DtCriacao,1,4) = '2025'
        ORDER BY IdCliente, dtDia
    ),
    diff_dia AS (
        SELECT
            *, 
            lag(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lag_tdDia,
            julianday(dtDia) - julianday(lag(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia)) AS diffDia

        FROM cliente_dias
    ),
    avg_dia_cliente AS (
        SELECT
            IdCliente,
            avg(diffDia) AS avgDia
        FROM diff_dia
        GROUP BY IdCliente
    )

SELECT
    avg(avgDia) AS avgGlobal
FROM avg_dia_cliente

