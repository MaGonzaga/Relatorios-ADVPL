


SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC,C5_NUM,C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_PRCVEN,C6_VALOR,CONVERT(VARCHAR,CONVERT(DATE,C5_EMISSAO),103)
FROM SA1990 SA1
INNER JOIN SC5990 SC5 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI
INNER JOIN SC6990 SC6 ON C5_NUM = C6_NUM
INNER JOIN SB1990 SB1 ON B1_COD = C6_PRODUTO AND B1_FILIAL = C6_FILIAL
WHERE SC5.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' 



 








