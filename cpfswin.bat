:: MIT License
:: Copyright (c) 2025 Diego Ferracini Bando - CPF Script for Windows
:: See LICENSE file for more details.
@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET "CPFSWIN_VER=1.00"

SET "PARAM_GENERATE=/G"
SET "FLAG_GEN_PUNCTUATION=/P"
SET "FLAG_GEN_UF=/E"
SET "FLAG_GEN_SAVE_FILE=/W"
SET "FLAG_GEN_CLIPBOARD=/C"
SET "FLAG_GEN_INVALID=/X"
SET "FLAG_GEN_USING_MASK=/M"
SET "PARAM_VALIDATION=/V"
SET "FLAG_VAL_DETAILS=/D"
SET "FLAG_VAL_SHOW_ONLY_VALID_CPF=/S"
SET "FLAG_VAL_IGNORE_FORMAT=/Z"
SET "FLAG_VAL_READ_FILE=/R"

SET "PROC_MODE="
SET "ENABLE_PUNCTUATION=false"
SET "COPY_OUTPUT_TO_CLIPBOARD=false"
SET "COPY_OUTPUT=false"
SET "GEN_USING_MASK=false"
SET "OUTPUT_DEST_PATH="
SET "CPF_GEN_COUNT="
SET "CPF_LIST="
SET "CPF_UF_NUM="
SET "CPF_STR_OUTPUT="
SET "SHOW_ONLY_VALID_CPF=false"
SET "SHOW_DETAILS=false"
SET "GEN_INVALID_CPF_ONLY=false"
SET "IGNORE_FORMAT=false"
SET "READ_FILE=false"
SET "INPUT_PATH="
SET "OUTPUT_CPF_COUNT="
SET "MASKED_CPF="
SET "MASK_LEN=0"
SET "SEQ_INDEX=0"
SET "MAX_SEQ_NUM=1"

:: Insere quebras de linha em strings.
(set LF=^
%=%
)

:START
IF "%~1"=="" (
  CALL :HELP
  exit /b 0
)

:CMD_ARG
IF "%~1"=="" GOTO :CMD_PROC
IF /i "%~1"=="%PARAM_GENERATE%" (
  IF NOT "%PROC_MODE%"=="" CALL :ECHO_SYNTAX_ERR_OPT_COMB & exit /b 1
  SET "PROC_MODE=gen"
) ELSE IF /i "%~1"=="%FLAG_GEN_PUNCTUATION%" (
  SET "ENABLE_PUNCTUATION=true"
) ELSE IF /i "%~1"=="%FLAG_GEN_UF%" (
  IF "%~2"=="" CALL :ECHO_SYNTAX_ERR_MISSING_ARG %FLAG_GEN_UF% & exit /b 1
  CALL :SET_CPF_UF "%~2" || exit /b 1
  SHIFT
) ELSE IF /i "%~1"=="%FLAG_GEN_SAVE_FILE%" (
  IF "%~2"=="" CALL :ECHO_SYNTAX_ERR_MISSING_ARG %FLAG_GEN_UF% & exit /b 1
  SET "COPY_OUTPUT=true"
  SET "OUTPUT_DEST_PATH=%~2"
  SHIFT
) ELSE IF /i "%~1"=="%FLAG_GEN_CLIPBOARD%" (
  SET "COPY_OUTPUT=true"
  SET "COPY_OUTPUT_TO_CLIPBOARD=true"
) ELSE IF /i "%~1"=="%FLAG_GEN_INVALID%" (
  SET "GEN_INVALID_CPF_ONLY=true"
) ELSE IF /i "%~1"=="%FLAG_GEN_USING_MASK%" (
  IF "%~2"=="" CALL :ECHO_SYNTAX_ERR_MISSING_ARG %FLAG_GEN_USING_MASK% & exit /b 1
  SET "GEN_USING_MASK=true"
  SET "MASK_STR=%~2"
  SHIFT
) ELSE IF /i "%~1"=="%PARAM_VALIDATION%" (
  IF NOT "%PROC_MODE%"=="" CALL :ECHO_SYNTAX_ERR_OPT_COMB & exit /b 1
  SET "PROC_MODE=val"
) ELSE IF /i "%~1"=="%FLAG_VAL_DETAILS%" (
  SET "SHOW_DETAILS=true"
) ELSE IF /i "%~1"=="%FLAG_VAL_SHOW_ONLY_VALID_CPF%" (
  SET "SHOW_ONLY_VALID_CPF=true"
) ELSE IF /i "%~1"=="%FLAG_VAL_IGNORE_FORMAT%" (
  SET "IGNORE_FORMAT=true"
) ELSE IF /i "%~1"=="%FLAG_VAL_READ_FILE%" (
  SET "READ_FILE=true"
  SET "INPUT_PATH=%~2"
  SHIFT
) ELSE IF "%PROC_MODE%"=="gen" (
  IF NOT "%CPF_GEN_COUNT%"=="" CALL :ECHO_SYNTAX_ERR_ARG_COMB & exit /b 1
  FOR /F "delims=0123456789" %%N IN ("%~1") DO CALL :ECHO_SYNTAX_ERR_ARG "%~1" & exit /b 1
  SET /a "CPF_GEN_COUNT=%~1"
) ELSE IF "%PROC_MODE%"=="val" (
  SET "CPF_LIST=!CPF_LIST! %~1"
) ELSE (
  CALL :ECHO_SYNTAX_ERR_PARAM "%~1"
  exit /b 1
)
SHIFT
GOTO :CMD_ARG

:CMD_PROC
IF "%CPF_GEN_COUNT%"=="" IF /i "%GEN_USING_MASK%"=="false" SET /a "CPF_GEN_COUNT=1"
IF "%PROC_MODE%"=="gen" (
  IF NOT "%OUTPUT_DEST_PATH%"=="" IF EXIST %OUTPUT_DEST_PATH%\NUL CALL :ECHO_INVALID_OUTPUT_PATH "!OUTPUT_DEST_PATH!" & exit /b 1
  CALL :CMD_CPF_GEN
) ELSE IF "%PROC_MODE%"=="val" (
  IF /i NOT "%READ_FILE%"=="false" (
    IF "%INPUT_PATH%"=="" CALL :ECHO_NO_INPUT_PATH                           & exit /b 1
    IF EXIST %INPUT_PATH%\NUL CALL :ECHO_INVALID_INPUT_PATH "!INPUT_PATH!"   & exit /b 1
    IF NOT EXIST "%INPUT_PATH%" CALL :ECHO_INVALID_INPUT_PATH "!INPUT_PATH!" & exit /b 1
    FOR /f "tokens=*" %%A in (%INPUT_PATH%) DO (
      IF "!CPF_LIST!"=="" (
        SET "CPF_LIST=%%A"
      ) ELSE (
        SET "CPF_LIST=!CPF_LIST!!LF!%%A"
      )
    )
  )
  CALL :CMD_CPF_LIST_VALIDATION CPF_LIST
) ELSE (
  CALL :ECHO_NO_VALID_OPTION
  exit /b 1
)
GOTO:END

:CMD_CPF_GEN
IF "%CPF_GEN_COUNT%"=="0" CALL :ECHO_INVALID_CPF_COUNT & exit /b 1
CALL :CREATE_OUTPUT_FILES
IF /i "%GEN_USING_MASK%"=="true" (
  CALL :CMD_SEQ_CPF_GEN
) ELSE (
  FOR /L %%I IN (1, 1, %CPF_GEN_COUNT%) DO (
    CALL :GEN_CPF_RAND
    CALL :GEN_DV
    CALL :BUILD_CPF_STRING
    CALL :PROC_OUTPUT %%I
  )
)
CALL :COMMIT_OUTPUT_FILES
CALL :COPY_TO_CLIPBOARD
exit /b 0

:CREATE_OUTPUT_FILES
CALL :CALC_OUTPUT_CPF_COUNT
IF NOT "%OUTPUT_DEST_PATH%"=="" type nul >!OUTPUT_DEST_PATH!
IF /i "%COPY_OUTPUT_TO_CLIPBOARD%"=="true" type nul >cpfswin.tmp
GOTO:EOF

:COMMIT_OUTPUT_FILES
IF /i "%COPY_OUTPUT_TO_CLIPBOARD%"=="true" (
  (<NUL set /p="!CPF_STR_OUTPUT!") >> cpfswin.tmp
)
IF NOT "%OUTPUT_DEST_PATH%"=="" (
  (<NUL set /p="!CPF_STR_OUTPUT!") >> !OUTPUT_DEST_PATH!
)
GOTO:EOF

:COPY_TO_CLIPBOARD
IF /i "%COPY_OUTPUT_TO_CLIPBOARD%"=="true" IF EXIST cpfswin.tmp (
  clip < cpfswin.tmp
  del cpfswin.tmp
)
GOTO:EOF

:CALC_OUTPUT_CPF_COUNT
IF /i "%GEN_USING_MASK%"=="true" (
  CALL :STRLEN MASK_STR CPF_LENGTH
  SET /a "CPF_LENGTH=!CPF_LENGTH! + 2"
) ELSE IF /i "%ENABLE_PUNCTUATION%"=="true" (
  SET "CPF_LENGTH=14"
) ELSE (
  SET "CPF_LENGTH=11"
)
SET /a "OUTPUT_CPF_COUNT=8191 / (!CPF_LENGTH! + 1) - 2"
GOTO:EOF

:CMD_CPF_LIST_VALIDATION
SET /a "C_RET=0"
SET "LIST=!%~1!"
IF "!LIST!"=="" IF /i "%READ_FILE%"=="false" (
  CALL :ECHO_MISSING_CPF_INPUT & exit /b 1
)
IF NOT "!LIST!"=="" (
  FOR %%C IN (!LIST!) DO CALL :IS_CPF_VALID %%C || SET /a "C_RET=1"
)
exit /b !C_RET!

:SET_CPF_UF
SET "UF_STR=%~1"
2>NUL CALL :CASE_%UF_STR%
IF ERRORLEVEL 1 CALL :DEFAULT_UF_CASE & exit /b 1
exit /b 0
:CASE_DF
:CASE_GO
:CASE_MS
:CASE_MT
:CASE_TO
  SET "CPF_UF_NUM=1"
  GOTO END_UF_CASE
:CASE_AC
:CASE_AM
:CASE_AP
:CASE_PA
:CASE_RO
:CASE_RR
  SET "CPF_UF_NUM=2"
  GOTO END_UF_CASE
:CASE_CE
:CASE_MA
:CASE_PI
  SET "CPF_UF_NUM=3"
  GOTO END_UF_CASE
:CASE_AL
:CASE_PB
:CASE_PE
:CASE_RN
  SET "CPF_UF_NUM=4"
  GOTO END_UF_CASE
:CASE_BA
:CASE_SE
  SET "CPF_UF_NUM=5"
  GOTO END_UF_CASE
:CASE_MG
  SET "CPF_UF_NUM=6"
  GOTO END_UF_CASE
:CASE_ES
:CASE_RJ
  SET "CPF_UF_NUM=7"
  GOTO END_UF_CASE
:CASE_SP
  SET "CPF_UF_NUM=8"
  GOTO END_UF_CASE
:CASE_PR
:CASE_SC
  SET "CPF_UF_NUM=9"
  GOTO END_UF_CASE
:CASE_RS
  SET "CPF_UF_NUM=0"
  GOTO END_UF_CASE
:DEFAULT_UF_CASE
  CALL :ECHO_E "Sigla de estado brasileiro invalida: '%UF_STR%'"
  exit /b 1
:END_UF_CASE
  VER > NUL
  GOTO :EOF

:IS_CPF_VALID
SET "INPUT=%~1"
SET "INPUT_LEN=0"
SET "CPF_E_NUM="
SET "CPF_E_LEN=0"
SET "FORMAT_STATUS=Invalido"
SET "DV_STATUS=Falha"
SET "CPF_STATUS=Invalido"
CALL :STRLEN INPUT INPUT_LEN
FOR /l %%i IN (0,1,%INPUT_LEN%) DO (
  SET "CHAR=!INPUT:~%%i,1!"
  IF "!CHAR!" GEQ "0" IF "!CHAR!" LEQ "9" (
    SET "CPF_E_NUM=!CPF_E_NUM!!CHAR!"
    SET /a "CPF_E_LEN=!CPF_E_LEN!+1"
  )
)
CALL :CALC_CPF "%CPF_E_NUM%" && SET "DV_STATUS=OK"
IF /i "%IGNORE_FORMAT%"=="true" (
  IF "!DV_STATUS!"=="OK" SET "CPF_STATUS=Valido"
) ELSE (
  IF /i "!CPF_E_LEN!"=="11" CALL :IS_NUMBER !INPUT! && SET "FORMAT_STATUS=OK (apenas numeros)" || IF /i "!INPUT_LEN!"=="14" CALL :IS_CPF_FORMAT !INPUT! && SET "FORMAT_STATUS=OK"
  IF NOT "!FORMAT_STATUS!"=="Invalido" IF "!DV_STATUS!"=="OK" SET "CPF_STATUS=Valido"
)
IF /i "%SHOW_ONLY_VALID_CPF%"=="true" IF /i "%CPF_STATUS%"=="Invalido" exit /b 1
IF /i "%SHOW_DETAILS%"=="true" (
  CALL :PRINT_CPF_DETAILS
) ELSE (
  IF /i "%CPF_STATUS%"=="Invalido" (
    CALL :ECHO_INVALID_CPF "%INPUT%"
  ) ELSE (
    ECHO CPF valido: !CPF_NUM!
  )
)
IF /i "%CPF_STATUS%"=="Invalido" exit /b 1
exit /b 0

:IS_NUMBER
FOR /f "delims=0123456789" %%a IN ("%~1") DO exit /b 1
exit /b 0

:CALC_CPF
SET CPF_NUM=%~1
SET /a "CPF_I=%CPF_E_LEN%-3"
FOR /L %%x IN (0,1,%CPF_I%) DO (
  SET /a "CPF[%%x]=!CPF_NUM:~%%x,1!"
)
CALL :GEN_DV
CALL :BUILD_CPF_STRING
FOR /L %%x IN (0,1,10) DO (
  IF NOT "!CPF[%%x]!"=="!CPF_NUM:~%%x,1!" exit /b 1
)

exit /b 0

:IS_CPF_FORMAT
IF NOT "%INPUT:~3,1%"  == "."  exit /b 1
IF NOT "%INPUT:~7,1%"  == "."  exit /b 1
IF NOT "%INPUT:~11,1%" == "-"  exit /b 1
exit /b 0

:STRLEN
SETLOCAL DisableDelayedExpansion
SET STRLEN=0
IF DEFINED %~1 FOR /f "delims=:" %%N IN (
  '"(cmd /v:on /c echo(!%~1!&echo()|findstr /o ^^"'
) DO SET /a "STRLEN=%%N-3"
ENDLOCAL & SET %~2=%STRLEN%
GOTO:EOF

:GEN_CPF_RAND
FOR /L %%x IN (0,1,7) DO (
  SET /a "CPF[%%x]=!RANDOM! %% 10"
)
IF "%CPF_UF_NUM%"=="" (
  SET /a "CPF[8]=!RANDOM! %% 10"
) ELSE (
  SET /a "CPF[8]=%CPF_UF_NUM% %% 10"
)
GOTO:EOF

:GEN_DV
SET /a "COUNTER=0"
SET /a "SUM=0"
SET "CPF_STR="
FOR /l %%x in (10, -1, 2) DO (
  SET /a "SUM+=CPF[!COUNTER!] * %%x"
  SET /a "COUNTER+=1"
)
SET /a "REMAINDER=%SUM% %% 11"
SET /a "CPF[9]=0"
IF %REMAINDER% GEQ 2 (
  SET /a "CPF[9]=11 - %REMAINDER%"
)
SET /a "COUNTER=0"
SET /a "SUM=0"
FOR /l %%x in (11, -1, 2) DO (
  SET /a "SUM+=CPF[!COUNTER!] * %%x"
  SET /a "COUNTER+=1"
)
SET /a "REMAINDER=%SUM% %% 11"
SET /a "CPF[10]=0"
IF %REMAINDER% GEQ 2 (
  SET /a "CPF[10]=11 - %REMAINDER%"
)
SET "DV[0]=%CPF[9]%"
SET "DV[1]=%CPF[10]%"
IF /i "%GEN_INVALID_CPF_ONLY%"=="true" (
  SET /a "FAKE_D=!RANDOM! %% 9"
  IF "!FAKE_D!" LSS "%CPF[9]%" (
    SET "CPF[9]=!FAKE_D!"
  ) ELSE (
    SET /a "CPF[9]=!FAKE_D! + 1"
  )
  SET /a "FAKE_D=!RANDOM! %% 9"
  IF "!FAKE_D!" LSS "%CPF[10]%" (
    SET "CPF[10]=!FAKE_D!"
  ) ELSE (
    SET /a "CPF[10]=!FAKE_D! + 1"
  )
)
GOTO:EOF

:BUILD_CPF_STRING
IF /i "%ENABLE_PUNCTUATION%"=="true" (
  SET "CPF_STR=%CPF[0]%%CPF[1]%%CPF[2]%.%CPF[3]%%CPF[4]%%CPF[5]%.%CPF[6]%%CPF[7]%%CPF[8]%-%CPF[9]%%CPF[10]%"
) ELSE IF /i "%GEN_USING_MASK%"=="true" (
  SET "CPF_STR=!MASKED_CPF!%CPF[9]%%CPF[10]%"
) ELSE (
  SET "CPF_STR=%CPF[0]%%CPF[1]%%CPF[2]%%CPF[3]%%CPF[4]%%CPF[5]%%CPF[6]%%CPF[7]%%CPF[8]%%CPF[9]%%CPF[10]%"
)
GOTO:EOF

:PROC_OUTPUT
IF /i "%COPY_OUTPUT%"=="true" (
  SET /a "OUTPUT_INDEX=%~1 %% !OUTPUT_CPF_COUNT!"
  IF "!CPF_STR_OUTPUT!"=="" (
    SET CPF_STR_OUTPUT=!CPF_STR!
  ) ELSE IF !OUTPUT_INDEX! EQU 0 (
    SET "CPF_STR_OUTPUT=!CPF_STR_OUTPUT!!LF!!CPF_STR!!LF!"
    CALL :COMMIT_OUTPUT_FILES
    SET "CPF_STR_OUTPUT="
  ) ELSE (
    SET CPF_STR_OUTPUT=!CPF_STR_OUTPUT!!LF!!CPF_STR!
  )
) ELSE (
  CALL :PRINT_CPF
)
GOTO:EOF

:CMD_SEQ_CPF_GEN
CALL :STRLEN MASK_STR MASK_LEN
CALL :GET_SEQ_INFO || exit /b 1
CALL :GEN_SEQ_CPF  || exit /b 1
exit /b 0

:GEN_SEQ_CPF
CALL :GET_SEQ_NUM
FOR /L %%x IN (0,1,7) DO (
  SET /a "CPF[%%x]=!GENERATED_CPF_NUM:~%%x,1!"
)
IF "%CPF_UF_NUM%"=="" (
  SET /a "CPF[8]=!GENERATED_CPF_NUM:~8,1!"
) ELSE (
  SET /a "CPF[8]=%CPF_UF_NUM% %% 10"
)
CALL :GEN_DV
CALL :BUILD_CPF_STRING
CALL :PROC_OUTPUT %SEQ_INDEX%
IF "%SEQ_INDEX%" EQU "%CPF_GEN_COUNT%" exit /b 0
IF "%SEQ_INDEX%" NEQ "%MAX_SEQ_NUM%" GOTO :GEN_SEQ_CPF
exit /b 0

:GET_SEQ_INFO
SET "VAR_NUM_COUNT=0"
SET "DIGIT_COUNT=0"
SET "APPEND_POS="
SET "AUX_MASK_STR="
FOR /L %%i IN (0,1,%MASK_LEN%) DO (
  SET "CHAR=!MASK_STR:~%%i,1!"
  IF /I "!CHAR!"=="#" IF !DIGIT_COUNT! EQU 8 IF NOT "%CPF_UF_NUM%"=="" (
    SET /a "APPEND_POS=%%i+1"
    SET "AUX_MASK_STR=!MASK_STR:~0,%%i!%CPF_UF_NUM%"
    SET /a "DIGIT_COUNT+=1"
    SET "CHAR="
  )
  IF /I "!CHAR!"=="#" (
    SET /a "VAR_NUM_COUNT+=1"
    SET /a "DIGIT_COUNT+=1"
    SET /a "MAX_SEQ_NUM=!MAX_SEQ_NUM! * 10"
  ) ELSE IF "!CHAR!" GEQ "0" IF "!CHAR!" LEQ "9" (
    SET /a "DIGIT_COUNT+=1"
  )
)
IF NOT "%AUX_MASK_STR%"=="" SET "MASK_STR=!AUX_MASK_STR!!MASK_STR:~%APPEND_POS%!"
IF !DIGIT_COUNT! NEQ 9 CALL :ECHO_INVALID_MASK_D_LENGTH & exit /b 1
exit /b 0

:GET_SEQ_NUM
SET "ZP_STR=000000000%SEQ_INDEX%"
SET "ZP_STR=!ZP_STR:~-%VAR_NUM_COUNT%!"
SET "PAD_COUNT=0"
SET "MASKED_CPF="
SET "GENERATED_CPF_NUM="
FOR /L %%i IN (0,1,%MASK_LEN%) DO (
  SET "CHAR=!MASK_STR:~%%i,1!"    
  IF /I "!CHAR!"=="#" (
    FOR /l %%i IN (!PAD_COUNT!,1,!PAD_COUNT!) DO FOR /f "delims=" %%c IN ("!ZP_STR:~%%i,1!") DO (
      SET "MASKED_CPF=!MASKED_CPF!%%c"
      SET "GENERATED_CPF_NUM=!GENERATED_CPF_NUM!%%c"
    )
    SET /a "PAD_COUNT+=1"
  ) ELSE (
    SET "MASKED_CPF=!MASKED_CPF!!CHAR!"
    IF "!CHAR!" GEQ "0" IF "!CHAR!" LEQ "9" (
      SET "GENERATED_CPF_NUM=!GENERATED_CPF_NUM!!CHAR!"
    )
  )
)
SET /a "SEQ_INDEX+=1"
exit /b 0

:PRINT_CPF_DETAILS
ECHO CPF: %INPUT%
IF /i "%IGNORE_FORMAT%"=="false" CALL :ECHO_NNL " - Formato:               " & CALL :PRINT_FORMAT_STATUS
CALL :ECHO_NNL " - Digitos verificadores: " & CALL :PRINT_DV
CALL :ECHO_NNL " - Regiao fiscal:         " & CALL :PRINT_REGIAO_FISCAL
CALL :ECHO_NNL " - Status:                " & CALL :PRINT_CPF_STATUS
GOTO:EOF

:PRINT_CPF
ECHO !CPF_STR!
GOTO:EOF

:PRINT_FORMAT_STATUS
IF /i "%FORMAT_STATUS%"=="Invalido" ( CALL :ECHO_E "!FORMAT_STATUS!" ) ELSE ( ECHO !FORMAT_STATUS! )
GOTO:EOF

:PRINT_DV
IF /i "%DV_STATUS%"=="Falha" (
  IF "%CPF_E_LEN%" NEQ "11" (
    CALL :ECHO_E "%DV_STATUS%"
  ) ELSE (
    CALL :ECHO_E "%DV_STATUS% (esperado: %DV[0]%%DV[1]%, encontrado: %CPF_NUM:~9,1%%CPF_NUM:~10,1%)"
  )
) ELSE (
  ECHO %DV_STATUS%
)
GOTO:EOF

:PRINT_REGIAO_FISCAL
SET "RF_CHAR_N=%CPF[8]%
IF "%CPF_E_LEN%" NEQ "11" CALL :ECHO_E "Falha" & exit /b 1
2>NUL CALL :CASE_RF%RF_CHAR_N%
IF ERRORLEVEL 1 CALL :DEFAULT_RF_CASE & exit /b 1
exit /b 0
:CASE_RF1
  ECHO DF GO MS MT TO
  GOTO END_RF_CASE
:CASE_RF2
  ECHO AC AM AP PA RO RR
  GOTO END_RF_CASE
:CASE_RF3
  ECHO CE MA PI
  GOTO END_RF_CASE
:CASE_RF4
  ECHO AL PB PE RN
  GOTO END_RF_CASE
:CASE_RF5
  ECHO BA SE
  GOTO END_RF_CASE
:CASE_RF6
  ECHO MG
  GOTO END_RF_CASE
:CASE_RF7
  ECHO ES RJ
  GOTO END_RF_CASE
:CASE_RF8
  ECHO SP
  GOTO END_RF_CASE
:CASE_RF9
  ECHO PR SC
  GOTO END_RF_CASE
:CASE_RF0
  ECHO RS
  GOTO END_RF_CASE
:DEFAULT_RF_CASE
  CALL :ECHO_E "Digito invalido: '%RF_CHAR_N%'"
  exit /b 1
:END_RF_CASE
  VER > NUL
  GOTO :EOF

:PRINT_CPF_STATUS
IF /i "%CPF_STATUS%"=="Invalido" (
  CALL :ECHO_E %CPF_STATUS%
) ELSE (
  ECHO %CPF_STATUS%
)
GOTO:EOF

:ECHO_E
ECHO [91m%~1[0m
GOTO:EOF

:ECHO_NNL
<nul set /p="%~1"
GOTO:EOF

:ECHO_SYNTAX_ERR_OPT_COMB
CALL :ECHO_E "Erro de sintaxe: combinacao invalida de opcoes."
GOTO:EOF

:ECHO_SYNTAX_ERR_ARG_COMB
CALL :ECHO_E "Erro de sintaxe: combinacao invalida de argumentos."
GOTO:EOF

:ECHO_SYNTAX_ERR_ARG
CALL :ECHO_E "Erro de sintaxe: argumento invalido: %~1"
GOTO:EOF

:ECHO_SYNTAX_ERR_PARAM
CALL :ECHO_E "Erro de sintaxe: parametro invalido: %~1"
GOTO:EOF

:ECHO_SYNTAX_ERR_MISSING_ARG
CALL :ECHO_E "Erro de sintaxe: a flag '%~1' requer um argumento."
GOTO:EOF

:ECHO_INVALID_CPF_COUNT
CALL :ECHO_E "A quantidade de CPFs informada deve ser maior que zero."
GOTO:EOF

:ECHO_INVALID_CPF
IF /i "%SHOW_ONLY_VALID_CPF%"=="false" CALL :ECHO_E "CPF invalido: %~1"
GOTO:EOF

:ECHO_INVALID_OUTPUT_PATH
CALL :ECHO_E "Caminho do arquivo de saida invalido: %~1"
GOTO:EOF

:ECHO_INVALID_INPUT_PATH
CALL :ECHO_E "Caminho do arquivo de entrada invalido: %~1"
GOTO:EOF

:ECHO_NO_INPUT_PATH
CALL :ECHO_E "Nenhum arquivo para leitura e validacao foi informado."
GOTO:EOF

:ECHO_INVALID_MASK_D_LENGTH
CALL :ECHO_E "A mascara deve conter 9 digitos."
GOTO:EOF

:ECHO_NO_VALID_OPTION
CALL :ECHO_E "Nenhuma opcao valida foi fornecida."
GOTO:EOF

:ECHO_MISSING_CPF_INPUT
CALL :ECHO_E "Nenhum CPF foi informado."
GOTO:EOF

:HELP
ECHO CPF Script for Windows v%CPFSWIN_VER%
ECHO (c) 2025 Diego Ferracini Bando - Free and open source software under the terms of the MIT license.
ECHO(
ECHO Modo de uso:
ECHO   cpfswin.bat ^<OPCAO^> ^[ARGUMENTOS^] ^[FLAGS^] ^[ARGUMENTOS^]
ECHO( 
ECHO Opcoes:
ECHO   %PARAM_GENERATE%     ^[QTDE_CPF^]              Gera numeros de CPFs.
ECHO   %PARAM_VALIDATION%     ^<CPF_1^> ... ^<CPF_N^>     Valida uma lista de N numeros de CPFs.
ECHO(
ECHO Flags para %PARAM_GENERATE%:
ECHO   %FLAG_GEN_PUNCTUATION%                             Adiciona pontuacao ao CPF gerado.
ECHO   %FLAG_GEN_INVALID%                             Gera CPFs com digitos verificadores invalidos.
ECHO   %FLAG_GEN_UF%     ^<SIGLA_ESTADO^>          Gera CPFs para um estado especifico de uma regiao fiscal.
ECHO   %FLAG_GEN_USING_MASK%     ^<MASCARA^>               Gera CPFs sequenciais seguindo um formato especificado por uma mascara contendo 9 digitos,
ECHO                                  onde cada caractere '#' representa um digito variavel. Exemplo: "053.42#.76#-"
ECHO   %FLAG_GEN_SAVE_FILE%     ^<CAMINHO^>               Escreve os CPFs gerados em um arquivo.
ECHO   %FLAG_GEN_CLIPBOARD%                             Copia os CPFs gerados para a area de transferencia.
ECHO(
ECHO Flags para %PARAM_VALIDATION%:
ECHO   %FLAG_VAL_DETAILS%                             Exibe detalhes sobre a validacao.
ECHO   %FLAG_VAL_SHOW_ONLY_VALID_CPF%                             Exibe apenas CPFs validos.
ECHO   %FLAG_VAL_READ_FILE%     ^<CAMINHO^>               Le um arquivo especificado para validar CPFs separados por linhas.
ECHO   %FLAG_VAL_IGNORE_FORMAT%                             Ignora a formatacao do CPF durante a validacao.
exit /b 0

:END
ENDLOCAL