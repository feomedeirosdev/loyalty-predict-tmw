
WITH
    tb_transacoes AS (
        SELECT
            IdTransacao,
            IdCliente,
            QtdePontos,
            datetime(substr(DtCriacao,1,19)) AS DtCriacaoDT,
            cast(strftime('%H', substr(DtCriacao,1,19)) AS INT) AS dtHora,
            julianday('2025-10-16') - julianday(substr(DtCriacao,1,10)) AS DiffDia
            -- julianday('now') - julianday(substr(DtCriacao,1,10)) AS DiffDia
        FROM transacoes
    ),
    tb_clientes AS (
        SELECT
            idCliente,
            qtdePontos,
            datetime(substr(DtCriacao,1,19)) AS DtCriacaoDT,
            datetime(substr(DtAtualizacao,1,19)) AS DtAtualizacaoDT,
            cast(julianday('2025-10-16') - julianday(substr(DtCriacao,1,10)) AS INT) AS IdadeNaBase
            -- cast(julianday('now') - julianday(substr(DtCriacao,1,10)) AS INT) AS IdadeNaBase
        FROM clientes
    ),
    tb_sumario_transacoes AS (
        SELECT
            IdCliente,
            cast(max(DiffDia) AS INT) AS DtPrimInter,
            cast(min(DiffDia) AS INT) AS DtUltInter,
            count(IdTransacao) AS QtdeTransVida,
            count(CASE WHEN DiffDia <= 56 THEN IdTransacao END) AS QtdeTransD56,
            count(CASE WHEN DiffDia <= 28 THEN IdTransacao END) AS QtdeTransD28,
            count(CASE WHEN DiffDia <= 14 THEN IdTransacao END) AS QtdeTransD14,
            sum(QtdePontos) AS SaldoPts,
            sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
            sum(CASE WHEN qtdePontos > 0 AND DiffDia <= 56 THEN qtdePontos ELSE 0 END) AS qtdePontosPos56,
            sum(CASE WHEN qtdePontos > 0 AND DiffDia <= 28 THEN qtdePontos ELSE 0 END) AS qtdePontosPos28,
            sum(CASE WHEN qtdePontos > 0 AND DiffDia <= 14 THEN qtdePontos ELSE 0 END) AS qtdePontosPos14,
            sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegVida,
            sum(CASE WHEN qtdePontos < 0 AND DiffDia <= 56 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg56,
            sum(CASE WHEN qtdePontos < 0 AND DiffDia <= 28 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg28,
            sum(CASE WHEN qtdePontos < 0 AND DiffDia <= 14 THEN qtdePontos ELSE 0 END) AS qtdePontosNeg14
        FROM tb_transacoes
        GROUP BY IdCliente
    ),
    tb_join AS (
        SELECT 
            t1.*,
            t2.IdadeNaBase
        FROM
            tb_sumario_transacoes AS t1
            LEFT JOIN tb_clientes AS t2 
            ON t1.IdCliente = t2.idCliente
    ),
    tb_transacao_produto AS (
        SELECT
            t1.*,
            t3.DescNomeProduto,
            t3.DescCategoriaProduto
        FROM
            tb_transacoes AS t1
            LEFT JOIN transacao_produto AS t2 
            ON t1.IdTransacao = t2.IdTransacao
            LEFT JOIN produtos AS t3 
            ON t2.IdProduto = t3.IdProduto
    ),
    tb_cliente_produto AS (
        SELECT
            IdCliente,
            DescNomeProduto,
            count(IdTransacao) AS qtdeVida,
            count(CASE WHEN DiffDia <= 56 THEN IdTransacao END) AS qtde56,
            count(CASE WHEN DiffDia <= 28 THEN IdTransacao END) AS qtde28,
            count(CASE WHEN DiffDia <= 14 THEN IdTransacao END) AS qtde14
        FROM tb_transacao_produto
        GROUP BY IdCliente, DescNomeProduto
    ),
    tb_cliente_produto_rn AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtdeVida DESC) AS rnVida,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtde56 DESC) AS rn56,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtde28 DESC) AS rn28,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtde14 DESC) AS rn14
        FROM tb_cliente_produto
    ),
    tb_join_2 AS (
        SELECT 
            t1.*,
            t2.IdadeNaBase,
            t3.DescNomeProduto AS ProdutoVida,
            t4.DescNomeProduto AS Produto56,
            t5.DescNomeProduto AS Produto28,
            t6.DescNomeProduto AS Produto14
        FROM
            tb_sumario_transacoes AS t1
            LEFT JOIN tb_clientes AS t2
            ON t1.IdCliente = t2.idCliente
            LEFT JOIN tb_cliente_produto_rn AS t3
            ON t1.IdCliente = t3.IdCliente
            AND t3.rnVida = 1
            LEFT JOIN tb_cliente_produto_rn AS t4
            ON t1.IdCliente = t4.IdCliente
            AND t4.rn56 = 1
            LEFT JOIN tb_cliente_produto_rn AS t5
            ON t1.IdCliente = t5.IdCliente
            AND t5.rn28 = 1
            LEFT JOIN tb_cliente_produto_rn AS t6
            ON t1.IdCliente = t6.IdCliente
            AND t6.rn14 = 1
    ),
    tb_cliente_dia AS (
        SELECT
            IdCliente,
            strftime('%w', substr(DtCriacaoDT,1,10)) AS dtDia,
            count(*) AS qtdTransacao
        FROM tb_transacoes
        WHERE DiffDia <= 28
        GROUP BY 1, 2
    ),
    tb_cliente_dia_rn AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtdTransacao DESC) AS rnDia
        FROM tb_cliente_dia
    ),
    tb_join_3 AS (
        SELECT 
            t1.*,
            t2.IdadeNaBase,
            t3.DescNomeProduto AS ProdutoVida,
            t4.DescNomeProduto AS Produto56,
            t5.DescNomeProduto AS Produto28,
            t6.DescNomeProduto AS Produto14,
            COALESCE(t8.dtDia, -1) AS diaVavorito
        FROM
            tb_sumario_transacoes AS t1

            LEFT JOIN tb_clientes AS t2
            ON t1.IdCliente = t2.idCliente

            LEFT JOIN tb_cliente_produto_rn AS t3
            ON t1.IdCliente = t3.IdCliente
            AND t3.rnVida = 1

            LEFT JOIN tb_cliente_produto_rn AS t4
            ON t1.IdCliente = t4.IdCliente
            AND t4.rn56 = 1

            LEFT JOIN tb_cliente_produto_rn AS t5
            ON t1.IdCliente = t5.IdCliente
            AND t5.rn28 = 1

            LEFT JOIN tb_cliente_produto_rn AS t6
            ON t1.IdCliente = t6.IdCliente
            AND t6.rn14 = 1

            LEFT JOIN tb_cliente_dia_rn AS t8
            ON t1.IdCliente = t8.IdCliente
            AND t8.rnDia = 1
    ),
    tb_cliente_periodo AS (
        SELECT
            IdCliente,
            CASE 
                WHEN (dtHora >= '0' AND dtHora < '6') THEN 'madrugada'
                WHEN (dtHora >= '6' AND dtHora < '12') THEN 'manhã'
                WHEN (dtHora >= '12' AND dtHora < '18') THEN 'tarde'
                WHEN (dtHora >= '18' AND dtHora < '24') THEN 'noite'
                ELSE 'sem informação'
            END AS periodo,
            count(IdTransacao) AS qtdeTransacao
        FROM tb_transacoes
        WHERE DiffDia <= 28
        GROUP BY 1, 2
    ),
    tb_cliente_periodo_rn AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtdeTransacao DESC) AS rnPeriodo
        FROM tb_cliente_periodo
    ),
    tb_cliente_periodo_pred AS (
        SELECT
            IdCliente,
            periodo,
            qtdeTransacao
        FROM tb_cliente_periodo_rn
        WHERE rnPeriodo = 1
    ),
    tb_join_4 AS (
        SELECT 
            t1.*,
            t2.IdadeNaBase,
            t3.DescNomeProduto AS ProdutoVida,
            t4.DescNomeProduto AS Produto56,
            t5.DescNomeProduto AS Produto28,
            t6.DescNomeProduto AS Produto14,
            COALESCE(t8.dtDia, -1) AS diaFavorito,
            COALESCE(t9.periodo, 'sem informação') AS periodo
        FROM
            tb_sumario_transacoes AS t1

            LEFT JOIN tb_clientes AS t2
            ON t1.IdCliente = t2.idCliente

            LEFT JOIN tb_cliente_produto_rn AS t3
            ON t1.IdCliente = t3.IdCliente
            AND t3.rnVida = 1

            LEFT JOIN tb_cliente_produto_rn AS t4
            ON t1.IdCliente = t4.IdCliente
            AND t4.rn56 = 1

            LEFT JOIN tb_cliente_produto_rn AS t5
            ON t1.IdCliente = t5.IdCliente
            AND t5.rn28 = 1

            LEFT JOIN tb_cliente_produto_rn AS t6
            ON t1.IdCliente = t6.IdCliente
            AND t6.rn14 = 1

            LEFT JOIN tb_cliente_dia_rn AS t8
            ON t1.IdCliente = t8.IdCliente
            AND t8.rnDia = 1

            LEFT JOIN tb_cliente_periodo_rn AS t9
            ON t1.IdCliente = t9.IdCliente
            AND t9.rnPeriodo = 1
    )

SELECT
    *,
    round((((1. * QtdeTransD28) / QtdeTransVida) * 100), 2) AS Engage28

FROM tb_join_4 LIMIT 10




/* 
SELECT * FROM tb_transacoes
SELECT * FROM tb_clientes
SELECT * FROM tb_sumario_transacoes
SELECT * FROM tb_join
SELECT * FROM tb_transacao_produto
SELECT * FROM tb_cliente_produto
SELECT * FROM tb_cliente_produto_rn 
SELECT * FROM tb_join_2 
SELECT * FROM tb_cliente_dia
SELECT * FROM tb_cliente_dia_rn
SELECT * FROM tb_join_3
SELECT * FROM tb_cliente_periodo
SELECT * FROM tb_cliente_periodo_rn
SELECT * FROM tb_join_4
*/











