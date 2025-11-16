WITH 
    tb_cliente_primero_dia AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-25'
    ),
    tb_cliente_ultimo_dia AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE substr(DtCriacao,1,10) = '2025-08-29'
    ),
    tb_join AS (
        SELECT
            t1.IdCliente AS Primeiro,
            t2.IdCliente AS Ultimo
        FROM tb_cliente_primero_dia AS t1
            LEFT JOIN tb_cliente_ultimo_dia AS t2
            ON t1.IdCliente = t2.IdCliente       
    )

SELECT
    count(Primeiro) AS Primeiro,
    count(Ultimo) AS Ultimo,
    (CAST(count(Ultimo) AS FLOAT) / count(Primeiro)) AS Prop

FROM tb_join




