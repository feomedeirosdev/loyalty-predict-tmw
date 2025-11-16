-- Quantidade de transações acumuladas ao longo do tempo

WITH
    tb_transacoes_dia AS (
        SELECT
            substr(DtCriacao,1,10) AS dtDia,
            count(IdTransacao) AS qtdeTransacoes
        FROM transacoes
        GROUP BY substr(DtCriacao,1,10)
    ),
    tb_transacoes_dia_acum AS (
        SELECT
            *,
            sum(qtdeTransacoes) OVER (ORDER BY dtDia) AS Acum
        FROM tb_transacoes_dia
)

SELECT *
FROM tb_transacoes_dia_acum
WHERE
    Acum >= 100000
    -- dtDia = '2024-06-20'
ORDER BY Acum 