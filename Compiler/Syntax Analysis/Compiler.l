%{			

	#include "compiler.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>

	void token_print(int token_id);
	void int_print(int token_id, int base);
	void float_print(int token_id, int base);
	int BinToInt(char *str);
	int HexToInt(char *str);
	float BinToFloat(char* str);
	float HexToFloat(char* str);
	
	
	void yyerror(const char* err);


	char str_buf[256];

	int error_counter = 0;                         
%}



%option noyywrap 
%option case-insensitive
%option yylineno


%x STRING 
%x SLCOMMENT



LETTER              [a-zA-Z]                                   				 
DIGIT               [0-9]                                                  
BINDIGIT            [01]                                                  
OCTDIGIT            [0-7]                                               
HEXDIGIT            [0-9A-F]                                          
ALPHANUM            [a-zA-Z0-9]                                          
ALPHANUM_           (a-zA-Z0-9_)                                      

ID                  (_?[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9])|[a-zA-Z]
ICONSTHEX           (0H)[1-9A-F][0-9A-Z]*
ICONSTBIN			(0B)[1][0-1]*
ICONSTDEC			([1-9][0-9]*)
RCONSTHEX			(0H)([1-9a-fA-F][a-fA-F0-9]*)?\.(0*[1-9a-fA-F]+[0-9a-fA-F]*|0)
RCONSTBIN			(0B)(1[0-1]*)?\.(0*1+[0-1]*|0)
RCONSTDEC			((0|[1-9][0-9]*)?[\.](0*[1-9]+[0-9]*|0))|([1-9][0-9]*E[+-]?(0|[1-9][0-9]*))
CCONST              ('[a-zA-Z0-9]')|('[!@#$%^&*() \\']')|('\\[nftrbv]') 

%%



"PROGRAM"           { token_print(T_PROGRAM); return T_PROGRAM; }
"CONST"             { token_print(T_CONST); return T_CONST; }
"TYPE"              { token_print(T_TYPE); return T_TYPE;   }        
"ARRAY"             { token_print(T_ARRAY); return T_ARRAY; }
"SET"               { token_print(T_SET);  return T_SET; }
"OF"                { token_print(T_OF); return T_OF;} 
"RECORD"            { token_print(T_RECORD); return T_RECORD; }
"VAR"               { token_print(T_VAR); return T_VAR; }
"FORWARD"           { token_print(T_FORWARD); return T_FORWARD; }
"FUNCTION"          { token_print(T_FUNCTION); return T_FUNCTION; }
"PROCEDURE"         { token_print(T_PROCEDURE); return T_PROCEDURE; }
"INTEGER"           { token_print(T_INTEGER); return T_INTEGER; }
"REAL"              { token_print(T_REAL); return T_REAL; }
"BOOLEAN"           { token_print(T_BOOLEAN); return T_BOOLEAN; }
"CHAR"              { token_print(T_CHAR); return T_CHAR; }
"BEGIN"             { token_print(T_BEGIN); return T_BEGIN; }   
"END"               { token_print(T_END); return T_END; }
"IF"                { token_print(T_IF); return T_IF; }
"THEN"              { token_print(T_THEN); return T_THEN; }
"ELSE"              { token_print(T_ELSE); return T_ELSE; }
"WHILE"             { token_print(T_WHILE); return T_WHILE; }
"DO"                { token_print(T_DO); return T_DO; }
"FOR"               { token_print(T_FOR); return T_FOR; }
"DOWNTO"            { token_print(T_DOWNTO); return T_DOWNTO; }
"TO"                { token_print(T_TO); return T_TO; }   
"WITH"              { token_print(T_WITH); return T_WITH; }
"READ"              { token_print(T_READ); return T_READ; }
"WRITE"             { token_print(T_WRITE); return T_WRITE; }
                                 


"TRUE"|"FALSE"      { token_print(T_BCONST); return T_BCONST; }

">"|">="|"<"|"<="|"<>"              {token_print(T_RELOP); return T_RELOP; }             
"+"|"-"                             {token_print(T_ADDOP); return T_ADDOP; }                
"OR"                                {token_print(T_OROP); return T_OROP; }
"*"|"/"|"DIV"|"MOD"|"AND"         	{token_print(T_MUDTIVANDOP); return T_MUDTIVANDOP; }
"NOT"                               {token_print(T_NOTOP); return T_NOTOP; }
"IN"                                {token_print(T_INOP); return T_INOP; }


{ICONSTHEX}			{ int_print(T_ICONST, 16); return T_ICONST; }
{ICONSTBIN}			{ int_print(T_ICONST, 2); return T_ICONST; }
{ICONSTDEC}			{ int_print(T_ICONST, 10); return T_ICONST; }
{RCONSTHEX}			{ float_print(T_RCONST, 16); return T_RCONST; }
{RCONSTBIN}			{ float_print(T_RCONST, 2); return T_RCONST; }
{RCONSTDEC}			{ float_print(T_RCONST, 10); return T_RCONST; }
{CCONST}			{ token_print(T_CCONST); return T_CCONST; }
{ID}			    { token_print(T_ID); return T_ID; }

\"						{strcpy(str_buf, ""); BEGIN(STRING); }   
<STRING>\"				{ BEGIN(INITIAL);
                                if(strcmp(str_buf,"") ==0 ){    /* Checking if string is empty */
                                    yyerror("Found empty string"); 
                                   } else {
                                    printf("[LINE %d] Found String: (%s) with Token Number (%d).\n", yylineno, str_buf, T_STRING); return T_STRING;}
                                }    
                                             
<STRING>\\(\n|\r\n)     { }                   
<STRING>(\\.|[^"\\]) 	{                       /* Catching  special characters */
                        if(strlen(yytext) == 2) {
								if(strcmp(yytext, "\\n") == 0) {
									strcat(str_buf, "\n");
								} else if (strcmp(yytext, "\\t") == 0 ) {
									strcat(str_buf, "\t");
								} else if (strcmp(yytext, "\\r") == 0) {
									strcat(str_buf, "\r");
								} else if (strcmp(yytext, "\\f") == 0) {
									strcat(str_buf, "\f");
								} else if (strcmp(yytext, "\\b") == 0) {
									strcat(str_buf, "\b");
								} else if (strcmp(yytext, "\\v") == 0) {
									strcat(str_buf, "\v");
								} else {
									strcat(str_buf, &yytext[1]);
								}
							}else {             /* Catching anything else */
								strcat(str_buf, yytext); 
							}
                        }
<STRING>(\n|\r\n)		{ yyerror("New line found without \\ "); }        
<STRING><<EOF>>			{ yyerror("End of string without closing it."); } 
<STRING>.				{ yyerror("Unknown Character."); }                

"{"					    { BEGIN(SLCOMMENT); printf("[LINE %d] Found Comment.\n", yylineno); } 
<SLCOMMENT>(\n|\r\n)	{  }
<SLCOMMENT>"}"		    { BEGIN(INITIAL); printf("[LINE %d] Comment Ended in Line: %d.\n", yylineno, yylineno); } 
<SLCOMMENT>.		    {  } 


 
"("                                 {token_print(T_LPAREN); return T_LPAREN; }
")"                                 {token_print(T_RPAREN); return T_RPAREN; }
";"                                 {token_print(T_SEMI); return T_SEMI; }
"."                                 {token_print(T_DOT); return T_DOT; }
","                                 {token_print(T_COMMA); return T_COMMA; }
"="                                 {token_print(T_EQU); return T_EQU; }
":"                                 {token_print(T_COLON); return T_COLON; }
"["                                 {token_print(T_LBRACK); return T_LBRACK; }
"]"                                 {token_print(T_RBRACK); return T_RBRACK; }
":="                                {token_print(T_ASSIGN); return T_ASSIGN; }
".."                                {token_print(T_DOTDOT); return T_DOTDOT; }

[ \t]					                            {	}						
[\n]|[\r\n]					                        {  } 				
<<EOF>>												{ token_print(T_EOF); return T_EOF; } 
.													{ yyerror("Unrecognised character."); }



%%
int main(int argc, char *argv[]){
	int token;        

	/* Read File */

	if(argc > 1){       
		yyin = fopen(argv[1], "r");
		if (yyin == NULL){
			perror ("[ERROR] Could not open file \'%s\', argv[1]"); 
			return EXIT_FAILURE;
		}
	}        

	
	do{		
		token = yylex(); 
	}while(token != T_EOF);

	
	fclose(yyin);
	yyterminate();
}

void token_print(int token_id) {
	if(token_id == T_BCONST) {
		printf("[LINE %d] Found Boolean (%s) with Token Number (%d).\n", yylineno, yytext, token_id);
	}else {
		printf("[LINE %d] TOKEN \'%s\' (%d)\n", yylineno, yytext, token_id);
	}
}

void float_print(int token_id, int base) {

	float num;
	if(base == 2) {
		num = BinToFloat(yytext);
	} 
	else if(base == 16){
		num = HexToFloat(yytext);
	}
	else {
		num = atoi(yytext);
	}
	printf("[LINE %d] Float Found: %0.3f ,which was in base %d in form (%s) with Token Number (%d).\n", yylineno, num, base, yytext, token_id);
}



void int_print(int token_id, int base) {

	int num;
	if(base == 2) {
		num = BinToInt(yytext);
	}
	else if(base == 16){
		num = HexToInt(yytext);
	}
	else{
		num = atoi(yytext);
	}
	printf("[LINE %d] Integer Found: %d ,which was in base %d in form (%s) with Token Number (%d).\n", yylineno, num, base, yytext, token_id);
	
}



/*---------------------------------------*/

float BinToFloat(char* str){
    float num2 = 0.0;
    int i,length;
    char *charr;
    charr = strchr(str,'.');
    length = strlen(charr)-1;
    num2 = (int)strtol(&str[2],&charr,2);
    for(i=1;i<length;i++){
        num2 += (charr[i] - '0') * (1/pow(2,i));
    }
    return num2;
}

float HexToFloat(char*str){
    float num3 = 0.0;
    int i,length;
    char *charr;
    charr = strchr(str,'.');
    length = strlen(charr)-1;
    num3 = (int)strtol(&str[2],&charr,16);
    for(i=1;i<=length;i++){
        if(charr[i] <= '9')
			num3 += (charr[i] - '0') * (1/pow(16,i));
		else
			num3 += (charr[i] + 10 - 'A') * (1/pow(16,i)); 
	}
    return num3;
}


/*---------------------------------------*/

int BinToInt(char *str){
    return (int) strtol(&str[2], NULL, 2);
}	



int HexToInt(char *str) {
    return (int) strtol(&str[2], NULL, 16);
}


 
void yyerror(const char* err) {
	error_counter++;
	printf("[ERROR - LINE %d] %s\n", yylineno, err);

	if(error_counter == 5) {
		printf("MAXIMUM ERRORS FOUND\n");
		exit(EXIT_FAILURE);
	}

	yyless(1);
}	

