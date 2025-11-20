%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

void comenzar();
void terminar();
void asignar(const char *id);
void leer_id(const char *id);
void escribir_exp();
void procesar_cte(int v);
void procesar_id(const char *id);
void procesar_op(char op);

int yylineno = 1;

#define MAX_SIMBOLOS 1024
static char *simbolos[MAX_SIMBOLOS];
static int cant_simbolos = 0;

int esta_definida(const char *id) {
    for (int i = 0; i < cant_simbolos; i++)
        if (strcmp(simbolos[i], id) == 0) return 1;
    return 0;
}

void registrar_simbolo(const char *id) {
    if (!esta_definida(id) && cant_simbolos < MAX_SIMBOLOS)
        simbolos[cant_simbolos++] = strdup(id);
}

void error_longitud(const char *id) {
    if (strlen(id) > 32)
        fprintf(stderr,
                "ERROR semantico en linea %d: identificador '%s' supera los 32 caracteres\n",
                yylineno, id);
}

void error_uso(const char *id) {
    if (!esta_definida(id))
        fprintf(stderr,
                "ERROR semantico en linea %d: identificador '%s' usado sin haber sido definido\n",
                yylineno, id);
}
%}

%union {
    int   num;
    char  op;
    char *str;
}

%token INICIO FIN LEER ESCRIBIR
%token ASIGNACION
%token PYCOMA
%token PARENIZQUIERDO PARENDERECHO
%token SUMA RESTA
%token COMA
%token FDT

%token <str> ID
%token <num> CONSTANTE

%type <op> operadorAditivo

%%

objetivo
    : programa FDT          { terminar(); }
    ;

programa
    : INICIO                { comenzar(); }
      listaSentencias
      FIN
    ;

listaSentencias
    :
    | listaSentencias sentencia
    ;

sentencia
    : ID ASIGNACION expresion PYCOMA
        { error_longitud($1); registrar_simbolo($1); asignar($1); free($1); }
    | LEER PARENIZQUIERDO listaIdentificadores PARENDERECHO PYCOMA
    | ESCRIBIR PARENIZQUIERDO listaExpresiones PARENDERECHO PYCOMA
    | error PYCOMA
        {
            fprintf(stderr,
                    "ERROR sintactico en linea %d: sentencia invalida\n",
                    yylineno);
            yyerrok;
        }
    ;

listaIdentificadores
    : ID
        { error_longitud($1); registrar_simbolo($1); leer_id($1); free($1); }
    | listaIdentificadores COMA ID
        { error_longitud($3); registrar_simbolo($3); leer_id($3); free($3); }
    ;

listaExpresiones
    : expresion
        { escribir_exp(); }
    | listaExpresiones COMA expresion
        { escribir_exp(); }
    ;

expresion
    : primaria
    | expresion operadorAditivo primaria
    ;

primaria
    : ID
        { error_longitud($1); error_uso($1); procesar_id($1); free($1); }
    | CONSTANTE
        { procesar_cte($1); }
    | PARENIZQUIERDO expresion PARENDERECHO
    ;

operadorAditivo
    : SUMA     { $$ = '+'; procesar_op('+'); }
    | RESTA    { $$ = '-'; procesar_op('-'); }
    ;

%%

void yyerror(const char *s) {}

static int cant_asign = 0;
static int cant_lect  = 0;
static int cant_escr  = 0;

void comenzar() {
    printf("Comienza el programa MICRO\n");
}

void terminar() {
    printf("\nFin del analisis.\n");
    printf("Asignaciones: %d\n", cant_asign);
    printf("Lecturas:     %d\n", cant_lect);
    printf("Escrituras:   %d\n", cant_escr);
}

void asignar(const char *id) {
    cant_asign++;
    printf("[semantica] Asignacion a '%s'\n", id);
}

void leer_id(const char *id) {
    cant_lect++;
    printf("[semantica] Leer identificador '%s'\n", id);
}

void escribir_exp() {
    cant_escr++;
    printf("[semantica] Escribir expresion\n");
}

void procesar_cte(int v) {
    printf("[semantica] Constante %d\n", v);
}

void procesar_id(const char *id) {
    printf("[semantica] Uso de identificador '%s'\n", id);
}

void procesar_op(char op) {
    printf("[semantica] Operador '%c'\n", op);
}

int main(int argc, char **argv) {
    extern FILE *yyin;

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("No se pudo abrir el archivo de entrada");
            return 1;
        }
    }

    yyparse();
    return 0;
}
