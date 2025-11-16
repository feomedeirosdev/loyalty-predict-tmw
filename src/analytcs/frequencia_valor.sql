WITH
tb_freq_valor AS (
    SELECT
        IdCliente,
        count(DISTINCT substr(DtCriacao,1,10)) AS qtdeFrequencia,  
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
        sum(abs(QtdePontos)) AS qtdePontosAbs
    FROM transacoes
    WHERE DtCriacao < '2025-09-01'
    AND DtCriacao >= date('2025-09-01', '-28 day')
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

SELECT * FROM tb_cluster 
