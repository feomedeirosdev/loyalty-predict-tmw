WITH
    tb_transacao AS (
        SELECT
            *,
            substr(DtCriacao,1,10) AS dtDia
        FROM transacoes
        WHERE DtCriacao < '2025-10-01'
    ),
    tb_agg_transacao AS (
        SELECT 
            IdCliente,
            -- dtDia,
            -- Ativação (dias distintos)
            count(DISTINCT dtDia) AS qtdeAtivacaoVida,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01','-56 day') THEN dtDia END) AS qtdeAtivacaoD56,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01','-28 day') THEN dtDia END) AS qtdeAtivacaoD28,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01','-14 day') THEN dtDia END) AS qtdeAtivacaoD14,
            count(DISTINCT CASE WHEN dtDia >= date('2025-10-01','-7 day')  THEN dtDia END) AS qtdeAtivacaoD7,
            -- Transações
            count(IdTransacao) AS qtdeTransacaoVida,
            count(CASE WHEN dtDia >= date('2025-10-01','-56 day') THEN IdTransacao END) AS qtdeTransacaoD56,
            count(CASE WHEN dtDia >= date('2025-10-01','-28 day') THEN IdTransacao END) AS qtdeTransacaoD28,
            count(CASE WHEN dtDia >= date('2025-10-01','-14 day') THEN IdTransacao END) AS qtdeTransacaoD14,
            count(CASE WHEN dtDia >= date('2025-10-01','-7 day')  THEN IdTransacao END) AS qtdeTransacaoD7,
            -- Saldo de pontos
            sum(qtdePontos) AS saldoVida,
            sum(CASE WHEN dtDia >= date('2025-10-01','-56 day') THEN qtdePontos ELSE 0 END) AS saldoD56,
            sum(CASE WHEN dtDia >= date('2025-10-01','-28 day') THEN qtdePontos ELSE 0 END) AS saldoD28,
            sum(CASE WHEN dtDia >= date('2025-10-01','-14 day') THEN qtdePontos ELSE 0 END) AS saldoD14,
            sum(CASE WHEN dtDia >= date('2025-10-01','-7 day')  THEN qtdePontos ELSE 0 END) AS saldoD7,
            -- Pontos positivos
            sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePosVida,
            sum(CASE WHEN dtDia >= date('2025-10-01','-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD56,
            sum(CASE WHEN dtDia >= date('2025-10-01','-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD28,
            sum(CASE WHEN dtDia >= date('2025-10-01','-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD14,
            sum(CASE WHEN dtDia >= date('2025-10-01','-7 day')  AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD7,
            -- Pontos negativos
            sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdeNegVida,
            sum(CASE WHEN dtDia >= date('2025-10-01','-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD56,
            sum(CASE WHEN dtDia >= date('2025-10-01','-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD28,
            sum(CASE WHEN dtDia >= date('2025-10-01','-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD14,
            sum(CASE WHEN dtDia >= date('2025-10-01','-7 day')  AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD7
        FROM tb_transacao
        GROUP BY IdCliente
    ),
    tb_agg_calc AS (
        SELECT
            *,
            coalesce(1. * qtdeTransacaoVida / qtdeAtivacaoVida, 0) AS qtdeTransacaoDiaVida,
            coalesce(1. * qtdeTransacaoD56 / qtdeAtivacaoD56, 0) AS qtdeTransacaoDiaD56,
            coalesce(1. * qtdeTransacaoD28 / qtdeAtivacaoD28, 0) AS qtdeTransacaoDiaD28,
            coalesce(1. * qtdeTransacaoD14 / qtdeAtivacaoD14, 0) AS qtdeTransacaoDiaD14,
            coalesce(1. * qtdeTransacaoD7  / qtdeAtivacaoD7,  0) AS qtdeTransacaoDiaD7,

            coalesce(1. * qtdeAtivacaoD28 / 28,0) AS pctAtivacaoMAU
        FROM tb_agg_transacao
    ),
    tb_horas_dia AS (
        SELECT
            IdCliente,
            dtDia,
            min(julianday(DtCriacao)) AS dtInicial,
            max(julianday(DtCriacao)) AS dtFinal,
            24 * 60 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracaoMin,
            24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao
        FROM tb_transacao
        GROUP BY IdCliente, dtDia
    ),
    tb_hora_cliente AS (
        SELECT
            IdCliente,
            sum(duracao) AS qtdeHorasVida,
            sum(CASE WHEN dtDia >= date('2025-10-01','-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56,
            sum(CASE WHEN dtDia >= date('2025-10-01','-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
            sum(CASE WHEN dtDia >= date('2025-10-01','-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
            sum(CASE WHEN dtDia >= date('2025-10-01','-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7
        FROM tb_horas_dia
        GROUP BY IdCliente
    ),
    tb_lag_dia AS (
        SELECT 
            IdCliente,
            dtDia,
            lag(dtDia) OVER (PARTITION BY IdCliente ORDER BY dtDia) AS lagDia
        FROM tb_horas_dia
    ),
    tb_diff_dia AS (
        SELECT
            *,
            julianday(dtDia) - julianday(lagDia) AS diffDia
        FROM tb_lag_dia
    ),
    tb_intervalo_dias AS (
        SELECT
            IdCliente,
            avg(julianday(dtDia) - julianday(lagDia)) AS avgIntervaloDiasVida,
            avg(CASE WHEN dtDia >= date('2025-10-01','-28 day') THEN julianday(dtDia) - julianday(lagDia) END) AS avgIntervaloDiasD28
        FROM tb_lag_dia
        GROUP BY IdCliente
    )

SELECT
    t1.IdCliente,
    t2.qtdeHorasVida,
    t2.qtdeHorasD56,
    t2.qtdeHorasD28,
    t2.qtdeHorasD14,
    t2.qtdeHorasD7,
    t3.avgIntervaloDiasVida,
    t3.avgIntervaloDiasD28

FROM
    tb_agg_calc AS t1

    LEFT JOIN tb_hora_cliente AS t2
    ON t1.IdCliente = t2.IdCliente

    LEFT JOIN tb_intervalo_dias AS t3
    ON t1.IdCliente = t3.IdCliente

LIMIT 21
