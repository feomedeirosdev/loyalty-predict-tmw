-- quantas transações por dia

WITH
    tb_sumario_dias AS (
        SELECT
            substr(DtCriacao,1,10) AS dtDia,
            count(IdTransacao) AS qtdTRansacoesDia
        FROM transacoes
        WHERE
            substr(DtCriacao,1,10) >= '2025-08-25'
            AND substr(DtCriacao,1,10) < '2025-08-30'
        GROUP BY dtDia
    )

SELECT
    *,
    sum(qtdTRansacoesDia) OVER (ORDER BY dtDia) AS qtdeTRansacaoAcum
    
FROM tb_sumario_dias
