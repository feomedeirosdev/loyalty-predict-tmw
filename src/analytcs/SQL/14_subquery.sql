-- Lista de transações com o produto "Resgatar Pônei"

SELECT *

FROM transacao_produto AS t1

WHERE t1.IdProduto IN (
    SELECT IdProduto
    FROM produtos
    WHERE
        DescNomeProduto = 'Resgatar Ponei'
        OR DescNomeProduto = 'Lista de presença'
)


