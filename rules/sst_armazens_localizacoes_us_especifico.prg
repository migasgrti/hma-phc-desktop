* Regra de gravacao da tabela STOBS para o utilizador 287.
* A expressao deve estar configurada no PHC como "A expressao e um programa".

LOCAL cCursorOriginal, cSql, cRef, cCampoArmazem, cCampoDescricao
LOCAL nAreaAnterior, nIndice, nArmazensAlterados, nIndiceArmazemAlterado
LOCAL nDescricoesAlteradas, nIndiceDescricaoAlterada, nOcorrencias621
LOCAL lTemOriginal, lSqlExecutado
LOCAL xArmazemAtual, xArmazemOriginal, xDescricaoAtual, xDescricaoOriginal
LOCAL cArmazemAtual, cArmazemOriginal, cDescricaoAtual, cDescricaoOriginal

IF NOT INLIST(m.ch_userno, 287, 156)
    RETURN .T.
ENDIF

m.cCursorOriginal = "crStobsOriginal287"
m.nAreaAnterior = SELECT()

IF USED(m.cCursorOriginal)
    USE IN (m.cCursorOriginal)
ENDIF

SELECT st
SELECT stobs

* A referencia e protegida contra plicas antes de ser usada na instrucao SQL.
m.cRef = STRTRAN(ALLTRIM(st.ref), "'", "''")
m.cSql = "SELECT TOP 1 u_armaz1, u_armaz2, u_armaz3, " + ;
    "u_armaz4, u_armaz5, u_armaz6, " + ;
    "u_arminf1, u_arminf2, u_arminf3, " + ;
    "u_arminf4, u_arminf5, u_arminf6 " + ;
    "FROM stobs WHERE ref='" + m.cRef  + "'"

m.lSqlExecutado = u_sqlexec(m.cSql, m.cCursorOriginal)

IF NOT m.lSqlExecutado OR NOT USED(m.cCursorOriginal)
    IF USED(m.cCursorOriginal)
        USE IN (m.cCursorOriginal)
    ENDIF
    SELECT (m.nAreaAnterior)
    mensagem("Não foi possivel validar os armazens na base de dados. A gravacao foi cancelada.")
    RETURN .F.
ENDIF

SELECT (m.cCursorOriginal)
GO TOP
m.lTemOriginal = NOT EOF()

m.nArmazensAlterados = 0
m.nIndiceArmazemAlterado = 0
m.nDescricoesAlteradas = 0
m.nIndiceDescricaoAlterada = 0
m.nOcorrencias621 = 0

FOR m.nIndice = 1 TO 6
    m.cCampoArmazem = "u_armaz" + TRANSFORM(m.nIndice)
    m.cCampoDescricao = "u_arminf" + TRANSFORM(m.nIndice)

    m.xArmazemAtual = EVALUATE("stobs." + m.cCampoArmazem)
    m.xDescricaoAtual = EVALUATE("stobs." + m.cCampoDescricao)

    IF m.lTemOriginal
        m.xArmazemOriginal = EVALUATE(m.cCursorOriginal + "." + m.cCampoArmazem)
        m.xDescricaoOriginal = EVALUATE(m.cCursorOriginal + "." + m.cCampoDescricao)
    ELSE
        * Num registo novo, os valores persistidos equivalem a campos vazios.
        m.xArmazemOriginal = 0
        IF VARTYPE(m.xDescricaoAtual) $ "CM"
            m.xDescricaoOriginal = SPACE(LEN(m.xDescricaoAtual))
        ELSE
            m.xDescricaoOriginal = ""
        ENDIF
    ENDIF

    * O tipo retornado pelo cursor do ecrÃ£ pode ser diferente do cursor SQL.
    * A normalizacao evita comparar diretamente valores Character e Numeric.
    m.cArmazemAtual = ""
    IF VARTYPE(m.xArmazemAtual) <> "X"
        m.cArmazemAtual = ALLTRIM(TRANSFORM(m.xArmazemAtual))
    ENDIF

    m.cArmazemOriginal = ""
    IF VARTYPE(m.xArmazemOriginal) <> "X"
        m.cArmazemOriginal = ALLTRIM(TRANSFORM(m.xArmazemOriginal))
    ENDIF

    m.cDescricaoAtual = ""
    IF VARTYPE(m.xDescricaoAtual) <> "X"
        m.cDescricaoAtual = TRANSFORM(m.xDescricaoAtual)
    ENDIF

    m.cDescricaoOriginal = ""
    IF VARTYPE(m.xDescricaoOriginal) <> "X"
        m.cDescricaoOriginal = TRANSFORM(m.xDescricaoOriginal)
    ENDIF

    IF m.cArmazemAtual == "621"
        m.nOcorrencias621 = m.nOcorrencias621 + 1
    ENDIF

    IF NOT (m.cArmazemAtual == m.cArmazemOriginal)
        m.nArmazensAlterados = m.nArmazensAlterados + 1
        m.nIndiceArmazemAlterado = m.nIndice

        IF NOT (m.cArmazemAtual == "621") AND ;
                NOT (m.cArmazemOriginal == "621" AND EMPTY(m.cArmazemAtual))
            USE IN (m.cCursorOriginal)
            SELECT (m.nAreaAnterior)
            mensagem("Não pode alterar o Armazem " + ASTR(m.nIndice) + ;
                ". Você só pode gravar o valor 621 ou retirar um valor 621 existente, deixando o campo vazio.")
            RETURN .F.
        ENDIF
    ENDIF

    IF NOT (m.cDescricaoAtual == m.cDescricaoOriginal)
        m.nDescricoesAlteradas = m.nDescricoesAlteradas + 1
        m.nIndiceDescricaoAlterada = m.nIndice
    ENDIF
ENDFOR

IF m.nArmazensAlterados > 1
    USE IN (m.cCursorOriginal)
    SELECT (m.nAreaAnterior)
    mensagem("Não pode alterar mais do que um campo de armazem. Você só pode gravar o valor 621 num unico campo.")
    RETURN .F.
ENDIF

IF m.nOcorrencias621 > 1
    USE IN (m.cCursorOriginal)
    SELECT (m.nAreaAnterior)
    mensagem("O valor 621 so pode existir num dos campos Armazém 1 a Armazém 6.")
    RETURN .F.
ENDIF

IF m.nDescricoesAlteradas > 1
    USE IN (m.cCursorOriginal)
    SELECT (m.nAreaAnterior)
    mensagem("Não pode alterar mais do que um campo de descrição de armazem. So pode alterar a descrição correspondente ao armazem onde gravou ou retirou o valor 621.")
    RETURN .F.
ENDIF

IF m.nDescricoesAlteradas = 1 AND ;
        (m.nArmazensAlterados <> 1 OR ;
        m.nIndiceDescricaoAlterada <> m.nIndiceArmazemAlterado)
    m.cCampoDescricao = "u_arminf" + TRANSFORM(m.nIndiceDescricaoAlterada)
    USE IN (m.cCursorOriginal)
    SELECT (m.nAreaAnterior)
    mensagem("Não pode alterar a descrição do Armazem " + TRANSFORM(m.nIndiceDescricaoAlterada) + ;
        ". So pode alterar a descrição correspondente ao campo de armazem onde gravou ou retirou o valor 621.")
    RETURN .F.
ENDIF

USE IN (m.cCursorOriginal)
SELECT (m.nAreaAnterior)

RETURN .T.
