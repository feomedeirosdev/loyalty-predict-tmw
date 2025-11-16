-- Dentre os clientes de janeiro, quantos assistiram o curso de SQL

WITH
    tb_clientes_jan AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE 
            substr(DtCriacao,1,10) >= '2025-01-01' 
            AND substr(DtCriacao,1,10) < '2025-02-01' 
    )

-- SELECT * FROM tb_clientes_jan

SELECT
    -- count(DISTINCT t1.IdCliente),
    count(DISTINCT t2.IdCliente)

FROM
    tb_clientes_jan AS t1
    LEFT JOIN transacoes AS t2 ON t1.IdCliente = t2.IdCliente
 
WHERE 
    substr(t2.DtCriacao,1,10) >= '2025-08-25'
    AND substr(t2.DtCriacao,1,10) < '2025-08-30'
