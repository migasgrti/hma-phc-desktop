***************************************************************
** Descrição: Evento para ser executado por botão, pede localização e atualiza na tabela st no campo 
** Framework: 
** Framework ID: 441
**
** Como executar: EVENTOSEXE("SETLOCALST","introduzir",.f.)
**
** Autor: Miguel Guerreiro
** Criado em: "2026-11-23 11:33"
**
** Alterado em: "2026-11-23 11:33"
** Alterado por: Miguel Guerreiro
**
** V. 
** © GoSolutions
***************************************************************

** ------------------------------------------------------------
** VARIAVEIS
** ------------------------------------------------------------
LOCAL SQL, modoDebug, localizacao

** indica se em modo de debug
modoDebug = .f.
m.escolheu = .f.
localizacao = ALLTRIM(st.local)

** VErifica se o utilizador pertence ao perfil 84
IF NOT VerificaAcessoPerfil(84)
  MSG("Não tem permissões para executar esta ação.", 16, "Acesso negado")
  RETURN
ENDIF

** se em modo debug, sai se não for administrador
IF modoDebug AND NOT m.sqlsa
 RETURN
ENDIF

***************************************************************
** ------------------------------------------------------------
** PRINCIPAL
** ------------------------------------------------------------

**IIF(modoDebug, Msg(""), modoDebug=.f.)

localizacao = GETNOME('Insira a localização', st.local, '', '', 1, .F.)

IF NOT m.escolheu
  RETURN
ENDIF

sst.showsave()

SELECT st

REPLACE st.local WITH localizacao

RETURN