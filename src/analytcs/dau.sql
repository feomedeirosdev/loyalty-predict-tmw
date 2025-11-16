SELECT
    substr(DtCriacao,1,10) AS DtDia,
    count(DISTINCT IdCliente) AS DAU,
    count(DISTINCT IdTransacao) AS QtdeTransacoesDia

FROM transacoes
GROUP BY 1
ORDER BY 1