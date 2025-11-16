-- Dentre os clientes de janeiro, quantos assistiram o curso de SQL

WITH
    tb_clientes_jan AS (
        SELECT DISTINCT IdCliente
        FROM transacoes
        WHERE 
            substr(DtCriacao,1,10) >= '2025-01-01' 
            AND substr(DtCriacao,1,10) < '2025-02-01' 
    ),
    tb_clientes_curso AS (
        SELECT DISTINCT IdCliente 
        FROM transacoes
        WHERE 
            substr(DtCriacao,1,10) >= '2025-08-25' 
            AND substr(DtCriacao,1,10) < '2025-08-30'
    )

SELECT 
    count(t1.IdCliente) AS IdClientesJan,
    count(t2.IdCliente) AS IdClientesCurso,
    -- cast(count(t2.IdCliente) AS FLOAT) / count(t1.IdCliente)
    1.0 * count(t2.IdCliente) / count(t1.IdCliente) 
FROM tb_clientes_jan AS t1
    LEFT JOIN tb_clientes_curso AS t2
    ON t1.IdCliente = t2.IdCliente
