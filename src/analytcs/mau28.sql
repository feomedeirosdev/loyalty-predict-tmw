WITH 
    tb_daily AS (
        SELECT DISTINCT
            date(substr(DtCriacao, 1, 10)) AS DtDia,
            IdCliente
        FROM transacoes
        ORDER BY DtDia
    ), 
    tb_distinct_day AS (
        SELECT DISTINCT DtDia AS DtRef
        FROM tb_daily
    ),
    tb_no_gruped AS (
        SELECT
            t1.DtRef,
            IdCliente,
            t2.DtDia
        FROM 
            tb_distinct_day AS t1
            LEFT JOIN tb_daily AS t2
            ON t2.DtDia <= t1.DtRef
            AND (julianday(t1.DtRef) - julianday(t2.DtDia)) < 28
    ),
    tb_join AS (
        SELECT
            t1.DtRef,
            count(DISTINCT IdCliente) AS MAU28,
            count(DISTINCT t2.DtDia) AS qtdeDias
        FROM 
            tb_distinct_day AS t1
            LEFT JOIN tb_daily AS t2
            ON t2.DtDia <= t1.DtRef
            AND (julianday(t1.DtRef) - julianday(t2.DtDia)) < 28
        GROUP BY t1.DtRef
        ORDER BY t1.DtRef ASC
    )



SELECT * FROM tb_join

/* 
SELECT * FROM tb_daily
SELECT * FROM tb_distinct_day
SELECT * FROM tb_no_gruped
SELECT * FROM tb_join
*/