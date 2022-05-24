#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} TRNOTCLI
    (Relatorio de pedido de Venda de clientes e os produtos)
    
    @author Marcio Gonzaga
    @since 18/04/2022
    @version 1.1
    @see (Tabelas Usadas  SC5 SC6 SB1  
	https://tdn.totvs.com/display/framework/Embedded+SQL
	https://tdn.totvs.com/pages/viewpage.action?pageId=415715475

    /*/

User Function TRPECLI() //FUNÇÃO PRINCIPAL

private oReport         := NIL 		//Objeto 
private oSection1       := NIL 		//Objeto 
private oSection2       := NIL 		//Objeto  
private cPerg           :="TRCLI"	//Pergunta que foi criada na SX1

ValidPerg() 					//Função para verificar se a pergunta existe se não existir vai criar 

Pergunte(cPerg,.T.) 			// Chama as perguntas

ReportDef()						//Chama a Função de Definição do Relatorio
oReport:PrintDialog()			// Chama a Função PrintDialog Passando os parametros do oReport 

Return 

Static Function ReportDef()		//Função que ira definir a Estrutura do Relatorio


// Chamando a função TREPORT e Adicionando as informações dentro do Oreport
// Depois chama denovo o Objeto com os parametros da Função PrintReport(asQuery)

oReport:=TReport():New("TRPECLI","Pedido de Venda por cliente",cPerg,{|oReport|PrintReport(oReport)},"Pedido Venda - Cliente")

oReport:SetLandscape(.T.) 		// Função para Definir o papel como Paisagem 
//oReport:cFontBody := 'Courier New'
oReport:nFontBody := 9 // TAMANHO DA FONTE
oReport:SetLeftMargin(1) // MARGEM A ESQUERDA 
oReport:ShowParamPage()			// Para não sair a tela de Paramêtros
oReport:lParamPage := .F.		// Para não sair a tela de Paramêtros
oReport:SetLineHeight(41)		// ALtura da Linha


//1 SESÃO 
//Função para Criar o Cabeçalho 
oSection1:=TRSection():New(oReport,"CLIENTE","SA1") 

// Função para Adicionar as Celular da Query no relatorio
TRCell():New(oSection1, "A1_COD",           "SA1")
TRCell():New(oSection1, "A1_NOME",          "SA1")
TRCell():New(oSection1, "A1_LOJA",          "SA1")
TRCell():New(oSection1, "A1_CGC",           "SA1")


// 2 Seção
//O Section 2 Chamando a Função de TRCell e  adicionando as informações na Section 2 
// que estara junto com a Section 1 

oSection2:=TRSection():New(oSection1,"-------------",{"SC5","SB1","SC6"})


TRCell():New(oSection2, "C5_NUM",           "SC5","Pedido",,,,,,,,,,,,,.T.)
TRCell():New(oSection2, "C5_EMISSAO",       "SC5")
TRCell():New(oSection2, "C6_PRODUTO",       "SC6")
TRCell():New(oSection2, "B1_DESC",          "SB1")
TRCell():New(oSection2, "C6_QTDVEN",        "SC6")
TRCell():New(oSection2, "C6_PRCVEN",        "SC6")
TRCell():New(oSection2, "C6_VALOR",         "SC6")


//SOMADORES

TRFunction():NeW(oSection2:Cell("C5_NUM"),,"COUNT",,"Quantidade de Pedido de Venda: ") // QUANTIDADE DE PEDIDOS DE VENDA
TRFunction():NeW(oSection2:Cell("C6_VALOR"),,"SUM") //SOMA O VALOR TOTAL 

Return 



Static Function PrintReport(oReport) //FUNÇAO PARA DEFINIR AS QUERYS 


cAlias := GetNextAlias() // CRIA O ALIAS AUTOMATICAMENTE
oSection1:BeginQuery()
BeginSql Alias cAlias // INICIA A QUERY 


    SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC,C5_NUM,C6_PRODUTO,B1_DESC,C6_QTDVEN,C6_PRCVEN,C6_VALOR,C5_EMISSAO 
    FROM %table:SA1% SA1

    INNER JOIN %table:SC5% SC5 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI
    INNER JOIN %table:SC6% SC6 ON C5_NUM = C6_NUM
    INNER JOIN %table:SB1% SB1 ON B1_COD = C6_PRODUTO

    WHERE SC5.%notdel% AND SA1.%notdel% AND SC6.%notdel% AND
    A1_COD BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% AND
    B1_COD BETWEEN %exp:(MV_PAR03)% AND %exp:(MV_PAR04)% AND
	C5_EMISSAO BETWEEN %exp:(MV_PAR05)% AND %exp:(MV_PAR06)% 
	ORDER BY A1_COD

EndSql

oSection1:EndQuery() // FINAL DA QUERY 
oSection2:SetParentQuery() //INFORMA QUE A SECTION2 E PARENTE DA SECTION 1 

// OS PARAMETROS DE PARENTESCO 
oSection2:SetParentFilter({|cCliPed| (cAlias)-> A1_COD+(cAlias)->A1_LOJA = cCliPed},{||(cAlias)->A1_COD+(cAlias)->A1_LOJA})

oSection1:Print() // IMPRIMI AS INFORMAÇÕES 

(cAlias)->(DbCloseArea()) // ENCERRA O ALIAS 

return 


Static Function ValidPerg() // FUNÇÃO PARA VERIFICAR SE AS PERGUNTAS EXISTEM

	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j

	aadd( aRegs, { cPerg,"01","Cliente de ?","Cliente de ?","Cliente de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"          } )
	aadd( aRegs, { cPerg,"02","Cliente ate ?","Cliente ate ?","Cliente ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"       } )
    aadd( aRegs, { cPerg,"03","Produto de ?","Produto de ?","Produto de ?","mv_ch3","C", 15,0,0,"G","","mv_par03","","","mv_par03"," ","",""," ","","","","","","","","","","","","","","","","","","SB1"       } )
    aadd( aRegs, { cPerg,"04","Produto ate ?","Produto ate ?","Produto ate ?","mv_ch4","C", 15,0,0,"G","","mv_par04","","","mv_par04"," ","",""," ","","","","","","","","","","","","","","","","","","SB1"       } )

	DbselectArea('SX1')
	SX1->(DBSETORDER(1))
	For i:= 1 To Len(aRegs)
		If ! SX1->(DBSEEK( AvKey(cPerg,"X1_GRUPO") +aRegs[i,2]) )
			Reclock('SX1', .T.)
			FOR j:= 1 to SX1->( FCOUNT() )
				IF j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				ENDIF
			Next j
			SX1->(MsUnlock())
		Endif
	Next i 
	RestArea(aArea) 
Return(cPerg)

