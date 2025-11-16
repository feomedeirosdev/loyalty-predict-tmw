-- Quantidade de transações acumuladas ao longo do tempo

WITH
    tb_qtde_transacao_dia_cliente AS (
        SELECT
            IdCliente,
            substr(DtCriacao,1,10) AS dtDia,
            count(IdTransacao) AS qtdeTransacao
        FROM transacoes
        WHERE
            DtCriacao >= '2025-08-25'
            AND DtCriacao < '2025-08-30' 
        GROUP BY IdCliente, substr(DtCriacao,1,10)
        ORDER BY IdCliente, substr(DtCriacao,1,10)
    )

SELECT
    *,
    sum(qtdeTransacao) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS qtdeTransacoesAcum

FROM tb_qtde_transacao_dia_cliente