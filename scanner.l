%{
#include <stdio.h>
#include <string.h>
int lineCount = 0;
int sourceStart = 0;
int tokenStart = 0;
int lineLength;
char curString[2000];
char tempString[2000];
int pragmaSourceFlag = 1;
int pragmaTokenFlag = 1;
int commentFlag = 0;
%}
key	"void"|"int"|"double"|"bool"|"char"|"null"|"for"|"while"|"do"|"if"|"else"|"switch"|"return"|"break"|"continue"|"const"|"true"|"false"|"struct"|"case"|"default"
keyFunc "fclose"|"clearerr"|"feof"|"ferror"|"fflush"|"fgetpos"|"fopen"|"fread"|"freopen"|"fseek"|"fsetpos"|"ftell"|"fwrite"|"remove"|"rename"|"rewind"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"|"fprintf"|"printf"|"sprintf"|"vfprintf"|"vprintf"|"vsprintf"|"fscanf"|"scanf"|"sscanf"|"fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"|"perror"
op	(\+|\*|-|\/|\%|\+\+|--|<|<=|>|>=|==|!=|=|\&\&|\|\||!|\&)
punc	(:|;|,|\.|\[|\]|\(|\)|\{|\})
double ([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)
integer ([0]|[1-9][0-9]*)
char	('.'|'\\n'|'\\t')
%x	COMMENT
%x	PARSE
%%
.*\n	{
		lineCount++;
		
		if(strcmp(yytext, "#pragma source off\n") == 0){
			pragmaSourceFlag = 0;
			sourceStart = 1;
		}else if(strcmp(yytext, "#pragma source on\n") == 0){
			pragmaSourceFlag = 1;
			sourceStart = 1;
		}
		
		if(strcmp(yytext, "#pragma token off\n") == 0){
			pragmaTokenFlag = 0;
			tokenStart = 1;
		}else if(strcmp(yytext, "#pragma token on\n") == 0){
			pragmaTokenFlag = 1;
			tokenStart = 1;
		}
		
		strcpy(curString, yytext);
		yyless(0);
		if(commentFlag != 1){
			BEGIN PARSE;
		}else if(commentFlag == 1){
			BEGIN COMMENT;
		}
		
		}
<COMMENT>\*\/	{
					if(commentFlag != 1){
						//printf("commentFlag != 1\n");
						REJECT;
					}else{
						commentFlag = 0;
						//printf("comment end\n");
						BEGIN PARSE;
					}
				}
<COMMENT>\n	{
				if(pragmaSourceFlag == 1){
					printf("%d:%s",lineCount , curString);
				}
				BEGIN 0;
			}
<COMMENT>.	{}

			
<PARSE>\n	{
				if(pragmaSourceFlag == 1){
					printf("%d:%s",lineCount , curString);
				}
				
				BEGIN 0;
				
			}
<PARSE>"#pragma source off"
<PARSE>"#pragma source on"
<PARSE>"#pragma token off"
<PARSE>"#pragma token on"
<PARSE>\/\/.*	{}
<PARSE>\/\*.*\*\/	{}
<PARSE>\/\*	{
				commentFlag = 1;
				//printf("comment start\n");
				BEGIN COMMENT;
			}
<PARSE>" "
<PARSE>\t
<PARSE>{key}|{keyFunc}	{
						if(pragmaTokenFlag == 1)
							printf("#key:%s\n",yytext);}
<PARSE>{op}	{
			if(pragmaTokenFlag == 1)
				printf("#op:%s\n",yytext);}
<PARSE>{punc}	{
				if(pragmaTokenFlag == 1)
					printf("#punc:%s\n",yytext);}
<PARSE>[a-zA-Z_][a-zA-Z_0-9]*	{
								if(pragmaTokenFlag == 1)
									printf("#id:%s\n",yytext);}
<PARSE>[0][0-9]+	{
					fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>[0-9]+[a-zA-Z]	{
						fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>{integer}	{
					if(pragmaTokenFlag == 1)
						printf("#integer:%s\n",yytext);}
<PARSE>{double}	{
				if(pragmaTokenFlag == 1)
					printf("#double:%s\n",yytext);}
<PARSE>([0-9]+|{double})[Ee][+-]?[0-9]+	{
										if(pragmaTokenFlag == 1)
											printf("#sci:%s\n",yytext);}
<PARSE>{char}	{
				if(pragmaTokenFlag == 1)
					printf("#char:%s\n",yytext);}
<PARSE>\"([^\n"]|\\\")*\"	{
					if(pragmaTokenFlag == 1){
						strncpy(tempString, yytext + 1, yyleng - 2);
						tempString[yyleng - 2] = '\0';
						printf("#string:%s\n",tempString);}
					}
<PARSE>'.*'	{
			fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}
<PARSE>.	{
			fprintf(stderr, "Error at line %d: %s\n",lineCount, yytext);exit(1);}	






%%
int main(void){
	yylex();
	return 0;
}

int yywrap(){
	return 1;
}