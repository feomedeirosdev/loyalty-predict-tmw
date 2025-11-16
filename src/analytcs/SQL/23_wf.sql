-- Quantidade de usuários cadastrados (absoluto e acumulado) ao longo do tempo

WITH
    tb_qtde_cliente_dia AS (
        SELECT
            substr(DtCriacao,1,10) AS dtDia,
            count(idCliente) qtdeClientesDia
        FROM clientes
        GROUP BY 1
        ORDER BY substr(DtCriacao,1,10)
    ),
    tb_acum AS (
        SELECT
            *,
            sum(qtdeClientesDia) OVER (ORDER BY dtDia) AS qtdeClientesDiaAum
        FROM tb_qtde_cliente_dia
    )

SELECT * FROM tb_acum
WHERE qtdeClientesDiaAum >= 3000
LIMIT 1