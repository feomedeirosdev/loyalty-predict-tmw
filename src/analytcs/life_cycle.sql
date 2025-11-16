-- curiosa:        idade < 7
-- fiel:           recência < 7 e recência anterior < 14
-- turista:        7 <= recência <= 14
-- desencantado:   14 < recência <= 28
-- zumbi:          recência >= 28
-- reconquistado:  recência < 7 e 14 <= recência anterior <= 28
-- reborn:         recência < 7 e recência anterior > 28

WITH
    tb_daily AS (
        SELECT DISTINCT
            IdCliente,
            substr(DtCriacao, 1,10) as dtDia
        FROM transacoes
        WHERE substr(DtCriacao,1,10) < '{date}'
    ),
    tb_idade AS (
        SELECT
            IdCliente,
            min(dtDia) AS dtPrimTransacao,
            cast(max(julianday('{date}') - julianday(dtDia)) AS INT) AS qtdeDiasPrimTransacao,
            -- max(dtDia) AS dtUltTransacao,
            cast(min(julianday('{date}') - julianday(dtDia)) AS INT) AS qtdeDiasUltTransacao
        FROM tb_daily
        GROUP BY IdCliente
    ),
    tb_rn AS(
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY dtDia DESC) AS rnDia
        FROM tb_daily
    ), 
    tb_penultima_ativacao AS (
        SELECT
            *,
            cast(julianday('{date}') - julianday(dtDia) AS INT) AS qtdeDiasPenultimaTransacao
        FROM tb_rn 
        WHERE rnDia = 2
    ),
    tb_life_cycle AS (
        SELECT 
            t1.*,
            t2.qtdeDiasPenultimaTransacao,
            CASE
                WHEN qtdeDiasPrimTransacao <= 7 THEN '01-curioso'
                WHEN qtdeDiasUltTransacao <= 7 AND (qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao) <= 14 THEN '02-fiel'
                WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-turista'
                WHEN qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '04-desencantada'
                WHEN qtdeDiasUltTransacao > 28 THEN '05-zumbi'
                WHEN qtdeDiasUltTransacao <= 7 AND (qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao) BETWEEN 15 AND 27 THEN '02-reconquistado'
                WHEN qtdeDiasUltTransacao <= 7 AND (qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao) >= 28 THEN '03-reborn'
            END AS descLifeCycle
        FROM tb_idade AS t1
        LEFT JOIN tb_penultima_ativacao AS t2
        ON t1.IdCliente = t2.IdCliente
    ),
    tb_freq_valor AS (
        SELECT
            IdCliente,
            count(DISTINCT substr(DtCriacao,1,10)) AS qtdeFrequencia,  
            sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
            sum(abs(QtdePontos)) AS qtdePontosAbs
        FROM transacoes
        WHERE DtCriacao < '{date}'
        AND DtCriacao >= date('{date}', '-28 day')
        GROUP BY IdCliente
        ORDER BY DtCriacao DESC
    ),
    tb_cluster AS (
        SELECT
            *,
            CASE
                WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN '12.Hyper'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22.Eficiente'
                WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11.Indeciso'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN '21.Esforçado'
                WHEN qtdeFrequencia < 4 THEN '00.Lurker'
                WHEN qtdeFrequencia < 10 THEN '01.Preguiçoso'
                WHEN qtdeFrequencia >= 10 THEN '20.Potencial'
            END AS cluster

        FROM tb_freq_valor
    )

SELECT
    date('{date}', '-1 day') AS dtRef,
    t1.*,
    t2.qtdeFrequencia,
    t2.qtdePontosPos,
    t2.cluster
    
FROM tb_life_cycle AS t1
LEFT JOIN tb_cluster AS t2
ON t1.IdCliente = t2.IdCliente
