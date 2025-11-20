typedef union {
    int   num;
    char  op;
    char *str;
} YYSTYPE;
#define	INICIO	257
#define	FIN	258
#define	LEER	259
#define	ESCRIBIR	260
#define	ASIGNACION	261
#define	PYCOMA	262
#define	PARENIZQUIERDO	263
#define	PARENDERECHO	264
#define	SUMA	265
#define	RESTA	266
#define	COMA	267
#define	FDT	268
#define	ID	269
#define	CONSTANTE	270


extern YYSTYPE yylval;
