#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'


User Function RLTP()

	private oReport	:= NIL
	private oSection	:= NIL
	private cPerg		:="TRCLI"
	Private cAlias := GetNextAlias()

	ValidPerg()
	Pergunte(cPerg,.T.)
	ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	
	oReport:=TReport():New("RLTP","RESUMO DE VENDA POR CLIENTE",cPerg,{|oReport| PrintReport(oReport)},"RESUMO DE VENDA POR CLIENTE")
	oReport:SetLeftMargin(1)
	oReport:SetLineHeight(41)
	oReport:nFontBody := 9
	oReport:lParamPage := .F.
	oReport:SetLandscape(.F.)
	oReport:oPage:SetPageNumber(1)


	oSection:= TRSection():New()(oReport,"PEDIDOS DE VENDA",{"SA1","SC6"})

	TRCell():New(oSection, 	"A1_COD",       cAlias,,,6,.T.)
	TRCell():New(oSection, 	"A1_NOME",      cAlias,,,30,.T.,,,,,,,,,,.T.)
	TRCell():New(oSection, 	"A1_LOJA",      cAlias)
	TRCell():New(oSection,	"C5_NUM",		cAlias,"Pedidos",,,,,"CENTER",,,.T., ,,,,)
	TRCell():New(oSection, 	"C6_QTDVEN",     cAlias,"Produtos Vendidos",,,,,"CENTER",,"LEFT",,,,,,)
	TRCell():New(oSection, 	"C6_VALOR",     cAlias,,,,,,"LEFT",,"LEFT",,,,,,)	
	TRCell():New(oSection, 	"MEDIA PRODUTO",       	cAlias,,"@E 9,999,999,999,999.99",,,{|| ((cAlias)->C6_VALOR / (cAlias)->C6_QTDVEN)  })


	//TRCell():New(oSection, "C6_TICKT_X",       cAlias,,,12,.T.,{|| ((cAlias)->C6_VALOR / (cAlias)->C5_NUM)  })



	TRFunction():NeW(oSection:Cell("C6_VALOR"),,"SUM",,"Todos os PEDIDOS: ",,,.F.)
	


Return

Static Function PrintReport(oReport)

	oSection:BeginQuery()
	BeginSql Alias cAlias

	SELECT A1_COD,A1_NOME,A1_LOJA,COUNT(C5_NUM) C5_NUM,SUM(C6_QTDVEN) C6_QTDVEN,SUM(C6_VALOR) C6_VALOR
	FROM %table:SA1% SA1
	
	INNER JOIN %table:SC5% SC5 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI
	INNER JOIN %table:SC6% SC6 ON C5_NUM = C6_NUM

	WHERE SC5.%notdel% AND SA1.%notdel% AND  
    A1_COD BETWEEN %exp:(MV_PAR01)% AND %exp:(MV_PAR02)% AND
	C5_EMISSAO BETWEEN %exp:(MV_PAR05)% AND %exp:(MV_PAR06)% 
	GROUP BY A1_COD,A1_NOME,A1_LOJA

	EndSql


	


	oSection:EndQuery()
	oSection:Print()
	(cAlias)->(DbCloseArea())

Return


Static Function ValidPerg() // FUNÇÃO PARA VERIFICAR SE AS PERGUNTAS EXISTEM

	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j

	aadd( aRegs, { cPerg,"01","Cliente de ?","Cliente de ?","Cliente de ?","mv_ch1","C", 6,0,0,"G","","mv_par01","","","mv_par01"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"          } )
	aadd( aRegs, { cPerg,"02","Cliente ate ?","Cliente ate ?","Cliente ate ?","mv_ch2","C", 6,0,0,"G","","mv_par02","","","mv_par02"," ","",""," ","","","","","","","","","","","","","","","","","","SA1"       } )
    aadd( aRegs, { cPerg,"03","Produto de ?","Produto de ?","Produto de ?","mv_ch3","C", 15,0,0,"G","","mv_par03","","","mv_par03"," ","",""," ","","","","","","","","","","","","","","","","","","SB1"       } )
    aadd( aRegs, { cPerg,"04","Produto ate ?","Produto ate ?","Produto ate ?","mv_ch4","C", 15,0,0,"G","","mv_par04","","","mv_par04"," ","",""," ","","","","","","","","","","","","","","","","","","SB1"       } )
	aadd( aRegs, { cPerg,"05","Emissao de ?","Emissao de ?","Emissao de ?","mv_ch5","D", 11,0,0,"G","","mv_par04","","","mv_par04"," ","",""," ","","","","","","","","","","","","","","","","","",""       } )
	aadd( aRegs, { cPerg,"06","Emissao ate ?","Emissao ate ?","Emissao ate ?","mv_ch6","D", 11,0,0,"G","","mv_par04","","","mv_par04"," ","",""," ","","","","","","","","","","","","","","","","","",""       } )

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
