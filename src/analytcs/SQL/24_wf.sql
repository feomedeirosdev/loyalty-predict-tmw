-- Qual é o dia da semana mais ativo de cada usuário?

WITH
    tb_qdte_transacoes_cliente_dia AS (
        SELECT
            IdCliente,
            substr(DtCriacao,1,10) AS dtDia,
            count(DISTINCT IdTransacao) AS qtdeTransacoesClienteDia
        FROM transacoes
        GROUP BY IdCliente, substr(DtCriacao,1,10)
        ORDER BY IdCliente, substr(DtCriacao,1,10)
    ),
    tb_qdte_transacoes_cliente_dia_semana AS (
        SELECT
            IdCliente,
            -- dtDia,
            strftime('%w', dtDia) diaSemNum,
            CASE
                WHEN strftime('%w', dtDia) = "0" THEN 'Dom'
                WHEN strftime('%w', dtDia) = "1" THEN 'Seg'
                WHEN strftime('%w', dtDia) = "2" THEN 'Ter'
                WHEN strftime('%w', dtDia) = "3" THEN 'Qua'
                WHEN strftime('%w', dtDia) = "4" THEN 'Qui'
                WHEN strftime('%w', dtDia) = "5" THEN 'Sex'
                WHEN strftime('%w', dtDia) = "6" THEN 'Sab'
            END AS DiaSemana,
            qtdeTransacoesClienteDia
        FROM tb_qdte_transacoes_cliente_dia
    ),
    tb_sum AS (
        SELECT
            IdCliente,
            DiaSemana,
            diaSemNum,
            sum(qtdeTransacoesClienteDia) AS qtde
        FROM tb_qdte_transacoes_cliente_dia_semana
        GROUP BY IdCliente, DiaSemana
    ),
    tb_rn AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY qtde DESC) AS rn
        FROM tb_sum
    ),
    tb_dia_semana AS (
        SELECT
            IdCliente,
            DiaSemana,
            diaSemNum,
            qtde
        FROM tb_rn 
        -- WHERE rn = 1 
        -- ORDER BY DiaSemNum
    ),
    tb_dia_sem_sum AS (
        SELECT 
            DiaSemana, 
            sum(qtde) AS QdteDiaSemana
        FROM tb_dia_semana
        GROUP BY DiaSemana
        ORDER BY diaSemNum
    )

SELECT * FROM tb_dia_sem_sum
/* SELECT * FROM tb_dia_semana */

