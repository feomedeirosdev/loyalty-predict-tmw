SELECT
    substr(DtCriacao, 1, 7) AS DtMes,
    count(DISTINCT IdCliente) AS MAU,
    count(IdTransacao) AS QtdeTransacoesMes

FROM transacoes

GROUP BY 1
ORDER BY 1