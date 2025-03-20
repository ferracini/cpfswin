
# cpfswin.bat - CPF Script for Windows

## Descrição

O script `cpfswin.bat` permite gerar números de CPFs válidos ou inválidos, validar uma lista de CPFs, e realizar diversas operações relacionadas, como a geração de CPFs com formatação específica ou a validação com detalhes adicionais.

## Modo de uso

```bash
cpfswin.bat <OPCAO> [ARGUMENTOS] [FLAGS] [ARGUMENTOS]
```

### Opções:

- `/G [QTDE_CPF]`  
  Gera números de CPFs.

- `/V <CPF_1> ... <CPF_N>`  
  Valida uma lista de N números de CPFs.

### Flags para `/G`:

- `/P`  
  Adiciona pontuação ao CPF gerado (formato: `xxx.xxx.xxx-xx`).

- `/X`  
  Gera CPFs com dígitos verificadores inválidos.

- `/E <SIGLA_ESTADO>`  
  Gera CPFs para um estado específico de uma região fiscal.  
  Exemplo: `/E SP` para gerar CPFs de São Paulo.

- `/M <MASCARA>`  
  Gera CPFs sequenciais seguindo um formato especificado por uma máscara contendo 9 dígitos.  
  Exemplo: `/M "053.42#.76#-"` onde `#` representa um dígito variável.

- `/W <CAMINHO>`  
  Escreve os CPFs gerados em um arquivo no caminho especificado.

- `/C`  
  Copia os CPFs gerados para a área de transferência.

### Flags para `/V`:

- `/D`  
  Exibe detalhes sobre a validação do CPF.

- `/S`  
  Exibe apenas CPFs válidos.

- `/R <CAMINHO>`  
  Lê um arquivo especificado para validar CPFs separados por linhas.

- `/Z`  
  Ignora a formatação do CPF durante a validação.

## Exemplos de uso

1. **Gerar CPFs**  
   Gera 10 números aleatórios de CPFs válidos:
   ```bash
   cpfswin.bat /G 10
   ```

2. **Gerar CPFs com formatação**  
   Gera 5 números aleatórios de CPF válidos com pontuação e salva em um arquivo:
   ```bash
   cpfswin.bat /G 5 /P /W "cpfs.txt"
   ```
3. **Gerar CPFs sequenciais**  
   Gera CPFs sequenciais utilizando a máscra `017.89#.76#-` :
   ```bash
   cpfswin.bat /G /M 017.89#.76#-
   ```

4. **Gerar CPFs inválidos**  
   Gera 3 CPFs com dígitos verificadores inválidos:
   ```bash
   cpfswin.bat /G 3 /X
   ```

5. **Validar CPFs**  
   Valida uma lista de CPFs e exibe detalhes sobre a validação:
   ```bash
   cpfswin.bat /V 12345678900 23456789012 /D
   ```

6. **Validar CPFs a partir de um arquivo**  
   Valida CPFs de um arquivo `cpfs.txt` e exibe apenas os válidos:
   ```bash
   cpfswin.bat /V /R "cpfs.txt" /S
   ```

## Licença

Este projeto é licenciado sob a [MIT License](LICENSE).
