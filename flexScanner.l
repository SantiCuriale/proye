/* flexScanner.l - Analizador léxico para MICRO */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "bisonparser.tab.h"

    extern int yylineno;   /* definido en el .y */

    int yywrap(void) { return 1; }
%}

DIGITO        [0-9]
LETRA         [a-zA-Z]
IDENTIFICADOR {LETRA}({LETRA}|{DIGITO})*
constEntera   {DIGITO}({DIGITO})*

%%

"inicio"      { return INICIO; }
"fin"         { return FIN; }
"leer"        { return LEER; }
"escribir"    { return ESCRIBIR; }

":="          { return ASIGNACION; }
";"           { return PYCOMA; }
"("           { return PARENIZQUIERDO; }
")"           { return PARENDERECHO; }
","           { return COMA; }
"+"           { return SUMA; }
"-"           { return RESTA; }


{constEntera} {
                  yylval.num = atoi(yytext);
                  return CONSTANTE;
              }


{IDENTIFICADOR} {
                        yylval.str = strdup(yytext);
                        return ID;
                }



[ \t\r]+      { /* ignorar */ }
\n            { yylineno++; }


.  { fprintf(stderr,"Error lexico en linea %d: caracter invalido '%s'\n",yylineno, yytext); }


<<EOF>>       { return FDT; }

%%
