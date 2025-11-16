-- Saldo de pontos acumulado de cada cliente

WITH
    tb_cliente_dia AS (
        SELECT
            IdCliente,
            substr(DtCriacao,1,10) AS DtDia,
            sum(QtdePontos) AS TotPts
        FROM transacoes AS t1
        GROUP BY
            IdCliente,
            substr(DtCriacao,1,10)
    )

SELECT
    *,
    sum(TotPts) OVER (PARTITION BY IdCliente ORDER BY DtDia) AS TotPtsAcum
FROM
    tb_cliente_dia 
