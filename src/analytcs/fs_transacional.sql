/*
dtRef,
t1.IdCliente,
t1.idadeDias,
t1.qtdeAtivacaoVida,
t1.qtdeAtivacaoD56,
t1.qtdeAtivacaoD28,
t1.qtdeAtivacaoD14,
t1.qtdeAtivacaoD7,
t1.qtdeTransacaoVida,
t1.qtdeTransacaoD56,
t1.qtdeTransacaoD28,
t1.qtdeTransacaoD14,
t1.qtdeTransacaoD7,
t1.saldoVida,
t1.saldoD56,
t1.saldoD28,
t1.saldoD14,
t1.saldoD7,
t1.qtdePosVida,
t1.qtdePontosPosD56,
t1.qtdePontosPosD28,
t1.qtdePontosPosD14,
t1.qtdePontosPosD7,
t1.qtdeNegVida,
t1.qtdePontosNegD56,
t1.qtdePontosNegD28,
t1.qtdePontosNegD14,
t1.qtdePontosNegD7,
t1.qtdeTransacaoDiaVida,
t1.qtdeTransacaoDiaD56,
t1.qtdeTransacaoDiaD28,
t1.qtdeTransacaoDiaD14,
t1.qtdeTransacaoDiaD7,
t1.pctAtivacaoMAU,
t2.qtdeHorasVida,
t2.qtdeHorasD56,
t2.qtdeHorasD28,
t2.qtdeHorasD14,
t2.qtdeHorasD7,
t3.avgIntervaloDiasVida,
t3.avgIntervaloDiasD28,
t4.qtdeTransacaoManha,
t4.qtdeTransacaoTarde,
t4.qtdeTransacaoNoite,
t4.pctTransacaoManha,
t4.pctTransacaoTarde,
t4.pctTransacaoNoite,
t5.pctChatMessage,
t5.pctAirflowLover,
t5.pctRLover,
t5.pctResgatarPonei,
t5.pctListaDepresnca,
t5.pctPresencaStreak,
t5.pctTrocaStreamElemets,
t5.pctReembolsoStreamElements,
t5.pctRPG,
t5.pctChurnModel
*/

WITH
    tb_transacao AS (
        SELECT
            *,
            substr(DtCriacao,1,10) AS dtDia,
            cast(substr(DtCriacao,12,2) AS INT) - 3 AS dtHora
        FROM transacoes
        WHERE DtCriacao < '2025-10-01'
    ),
    tb_agg_transacao AS (
        SELECT 
            IdCliente,
            max(julianday(date('2025-10-01','-1 day')) - julianday(dtCriacao)) AS idadeDias,
            -- Ativações
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
            sum(CASE WHEN dtDia >= date('2025-10-01','-7 day')  AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegD7,
            -- Turnos (VALORES ABSOLUTOS)
            count(CASE WHEN dtHora BETWEEN 7 AND 11 THEN IdTransacao END) AS qtdeTransacaoManha,
            count(CASE WHEN dtHora BETWEEN 12 AND 18 THEN IdTransacao END) AS qtdeTransacaoTarde,
            count(CASE WHEN dtHora > 18 OR dtHora < 7 THEN IdTransacao END) AS qtdeTransacaoNoite,
            -- Turnos (VALORES PERCENTUAIS)
            1. * count(CASE WHEN dtHora BETWEEN 7 AND 11 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoManha,
            1. * count(CASE WHEN dtHora BETWEEN 12 AND 18 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoTarde,
            1. * count(CASE WHEN dtHora > 18 OR dtHora < 7 THEN IdTransacao END) / count(IdTransacao) AS pctTransacaoNoite
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
    ),
    tb_share_produtos AS (
        SELECT
            t1.IdCliente,
            -- ABSOLUTO
            count(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) AS qtdeChatMessage,
            count(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) AS qtdeAirflowLover,
            count(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) AS qtdeRLover,
            count(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) AS qtdeResgatarPonei,
            count(CASE WHEN DescNomeProduto = 'Lista de presnça' THEN t1.IdTransacao END) AS qtdeListaDepresnca,
            count(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) AS qtdePresencaStreak,
            count(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElemets' THEN t1.IdTransacao END) AS qtdeTrocaStreamElemets,
            count(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) AS qtdeReembolsoStreamElements,
            count(CASE WHEN DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) AS qtdeRPG,
            count(CASE WHEN DescCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) AS qtdeChurnModel,
            -- PERCENTUAL
            1. * count(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctChatMessage,
            1. * count(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctAirflowLover,
            1. * count(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctRLover,
            1. * count(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctResgatarPonei,
            1. * count(CASE WHEN DescNomeProduto = 'Lista de presnça' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctListaDepresnca,
            1. * count(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctPresencaStreak,
            1. * count(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElemets' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctTrocaStreamElemets,
            1. * count(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctReembolsoStreamElements,
            1. * count(CASE WHEN DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctRPG,
            1. * count(CASE WHEN DescCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS pctChurnModel
        FROM
            transacoes AS t1
            LEFT JOIN transacao_produto AS t2
            ON t1.Idtransacao = t2.Idtransacao
            LEFT JOIN produtos AS t3
            ON t2.IdProduto = t3.IdProduto
        GROUP BY IdCliente
    ),
    tb_join AS (
        SELECT
            t1.IdCliente,
            t1.idadeDias,
            t1.qtdeAtivacaoVida,
            t1.qtdeAtivacaoD56,
            t1.qtdeAtivacaoD28,
            t1.qtdeAtivacaoD14,
            t1.qtdeAtivacaoD7,
            t1.qtdeTransacaoVida,
            t1.qtdeTransacaoD56,
            t1.qtdeTransacaoD28,
            t1.qtdeTransacaoD14,
            t1.qtdeTransacaoD7,
            t1.saldoVida,
            t1.saldoD56,
            t1.saldoD28,
            t1.saldoD14,
            t1.saldoD7,
            t1.qtdePosVida,
            t1.qtdePontosPosD56,
            t1.qtdePontosPosD28,
            t1.qtdePontosPosD14,
            t1.qtdePontosPosD7,
            t1.qtdeNegVida,
            t1.qtdePontosNegD56,
            t1.qtdePontosNegD28,
            t1.qtdePontosNegD14,
            t1.qtdePontosNegD7,
            t1.qtdeTransacaoDiaVida,
            t1.qtdeTransacaoDiaD56,
            t1.qtdeTransacaoDiaD28,
            t1.qtdeTransacaoDiaD14,
            t1.qtdeTransacaoDiaD7,
            t1.pctAtivacaoMAU,
            t2.qtdeHorasVida,
            t2.qtdeHorasD56,
            t2.qtdeHorasD28,
            t2.qtdeHorasD14,
            t2.qtdeHorasD7,
            t3.avgIntervaloDiasVida,
            t3.avgIntervaloDiasD28,
            t4.qtdeTransacaoManha,
            t4.qtdeTransacaoTarde,
            t4.qtdeTransacaoNoite,
            t4.pctTransacaoManha,
            t4.pctTransacaoTarde,
            t4.pctTransacaoNoite,
            t5.pctChatMessage,
            t5.pctAirflowLover,
            t5.pctRLover,
            t5.pctResgatarPonei,
            t5.pctListaDepresnca,
            t5.pctPresencaStreak,
            t5.pctTrocaStreamElemets,
            t5.pctReembolsoStreamElements,
            t5.pctRPG,
            t5.pctChurnModel
        FROM
            tb_agg_calc AS t1
            LEFT JOIN tb_hora_cliente AS t2
            ON t1.IdCliente = t2.IdCliente
            LEFT JOIN tb_intervalo_dias AS t3
            ON t1.IdCliente = t3.IdCliente
            LEFT JOIN tb_agg_transacao AS t4
            ON t1.IdCliente = t4.IdCliente
            LEFT JOIN tb_share_produtos AS t5
            ON t1.IdCliente = t5.IdCliente
    )

SELECT
    date('2025-10-01','-1 day') AS dtRef,
    *
FROM tb_join 

