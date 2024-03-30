/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;
import java.io.*;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }

%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	    break;
	/* If necessary, add code for other states here, e.g:
	*/
    case COMMENT:
        yybegin(YYINITIAL);
        return new Symbol(TokenConstants.ERROR, "EOF in comment");

    case STRING:
        yybegin(YYINITIAL);
        return new Symbol(TokenConstants.ERROR, "EOF in string constant");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%{
      StringBuffer string = new StringBuffer();
      private int nestedCommentCount = 1;
%}

%class CoolLexer
%cup
Digit = [0-9]
Letter = [a-zA-Z]
WhiteSpace = [\t \n\r\f\13]+
NonNewlineWS = [\t \r\f\13]+
%state COMMENT
%state COMMENT2
%state STRING
%state STRING2

a= [aA]
b= [bB]
c= [cC]
d= [dD]
e= [eE]
f= [fF]
g= [gG]
h= [hH]
i= [iI]
j= [jJ]
k= [kK]
l= [lL]
m= [mM]
n= [nN]
o= [oO]
p= [pP]
q= [qQ]
r= [rR]
s= [sS]
t= [tT]
u= [uU]
v= [vV]
w= [wW]
x= [xX]
y= [yY]
z= [zZ]
%%



<YYINITIAL>"(*"  {
    nestedCommentCount=1;
    yybegin(COMMENT);
    //System.out.println("BCO");
}

<COMMENT>"*)" {
                            if (nestedCommentCount-- == 1) {
                                yybegin(YYINITIAL);
                               // System.out.println("BCE");
                            }
                            //System.out.println("BNCE");
                                 
}
<COMMENT>. {
                                {  
                                }
}
<COMMENT>\n {
    curr_lineno +=1;
}

<COMMENT>{NonNewlineWS} {
                                { 
                                }
}
<COMMENT>"(*" {
    //System.out.println("BNCO");
                                nestedCommentCount++;

}

<COMMENT2>.* {
                                {
                                    yybegin(YYINITIAL);
                                }
}

<YYINITIAL>"--"     {  yybegin(COMMENT2);   }

<YYINITIAL>\"                       { string.setLength(0); yybegin(STRING); }
<YYINITIAL>\'.\'                       {    string.setLength(0);
                                            String a = yytext();
                                            if (a.length() != 3) {
                                                return new Symbol(TokenConstants.ERROR);
                                            }
                                            return new Symbol(TokenConstants.STR_CONST, 
                                        AbstractTable.stringtable.addString(String.valueOf(a.charAt(1))));
                                            

                                        }
<STRING2>.                       { return new Symbol(TokenConstants.STR_CONST, 
                                        AbstractTable.stringtable.addString(string.toString())); }
<STRING>\"                          { 
                                        yybegin(YYINITIAL);  
                                        return new Symbol(TokenConstants.STR_CONST, 
                                        AbstractTable.stringtable.addString(string.toString()));

                                    }
<STRING>\\\t                         { string.append( '\t' ); }
<STRING>\\\n                { string.append( '\n' ); curr_lineno +=1; }
<STRING>"\n"                { string.append( '\n' ); }
<STRING>"\t"                { string.append( '\t' ); }
<STRING>"\f"                { string.append( '\f' ); }
<STRING>"\b"                { string.append( '\b' ); }
<STRING>\\\r               { string.append( '\r' ); }
<STRING>\\\"               { string.append( '\"' ); }
<STRING>\\.                          {
    string.append(String.valueOf(yytext().charAt(1)) );
}
<STRING>\n {
    curr_lineno +=1;
    yybegin(YYINITIAL);
    return new Symbol(TokenConstants.ERROR, "Unterminated string constant");

}
<STRING>\\$ {}
<STRING>\\                {
    string.append( '\\'); }
<STRING>[^\n\r\"\\]+                { 
    string.append( yytext() );}
<STRING>[^ ] {
    System.err.println("Unexpected did not match" + yytext());
}

<YYINITIAL>{NonNewlineWS} {
                                {
                                }
}

<YYINITIAL>\n {
    curr_lineno+=1;
}

<YYINITIAL>{c}{l}{a}{s}{s} {
    return new Symbol(TokenConstants.CLASS);
}

<YYINITIAL>"inherits" {return new Symbol(TokenConstants.INHERITS);}
<YYINITIAL>"*)"
{   /* unmatched "*)" */
    return new Symbol(TokenConstants.ERROR, new String("Unmatched *)")); }
<YYINITIAL>":" {
    return new Symbol(TokenConstants.COLON);
}

<YYINITIAL>"=>"			{ /* Sample lexical rule for "=>" arrow.
                                     Further lexical rules should be defined
                                     here, after the last %% separator */
                                  return new Symbol(TokenConstants.DARROW); }
<YYINITIAL>"("    { return  new Symbol(TokenConstants.LPAREN); }  
<YYINITIAL>")"    { return  new Symbol(TokenConstants.RPAREN); }
<YYINITIAL>"{"    { return  new Symbol(TokenConstants.LBRACE); }  
<YYINITIAL>"}"    { return  new Symbol(TokenConstants.RBRACE); }

<YYINITIAL>"*"    { return  new Symbol(TokenConstants.MULT); }
<YYINITIAL>{p}{o}{o}{l}    { return  new Symbol(TokenConstants.POOL); }
<YYINITIAL>{c}{a}{s}{e}    { return  new Symbol(TokenConstants.CASE); }
<YYINITIAL>";"    { return  new Symbol(TokenConstants.SEMI); }
<YYINITIAL>"-"    { return  new Symbol(TokenConstants.MINUS); }
<YYINITIAL>{n}{o}{t}    { return  new Symbol(TokenConstants.NOT); }
<YYINITIAL>{i}{n}    { return  new Symbol(TokenConstants.IN); }
<YYINITIAL>","    { return  new Symbol(TokenConstants.COMMA); }
<YYINITIAL>{f}{i}    { return  new Symbol(TokenConstants.FI); }
<YYINITIAL>"/"    { return  new Symbol(TokenConstants.DIV); }
<YYINITIAL>"+"    { return  new Symbol(TokenConstants.PLUS); }
<YYINITIAL>"<-"    { return  new Symbol(TokenConstants.ASSIGN); }
<YYINITIAL>"<="    { return  new Symbol(TokenConstants.LE); }
<YYINITIAL>"<"    { return  new Symbol(TokenConstants.LT); }
<YYINITIAL>"@"    { return  new Symbol(TokenConstants.AT); }
<YYINITIAL>{i}{f}    { return  new Symbol(TokenConstants.IF); }
<YYINITIAL>"."    { return  new Symbol(TokenConstants.DOT); }
<YYINITIAL>{n}{e}{w}    { return  new Symbol(TokenConstants.NEW); }
<YYINITIAL>"="    { return  new Symbol(TokenConstants.EQ); }
<YYINITIAL>":"    { return  new Symbol(TokenConstants.COLON); }
<YYINITIAL>{t}{h}{e}{n}    { return  new Symbol(TokenConstants.THEN); }
<YYINITIAL>"~"    { return  new Symbol(TokenConstants.NEG); }
<YYINITIAL>{e}{l}{s}{e}    { return  new Symbol(TokenConstants.ELSE); }
<YYINITIAL>{w}{h}{i}{l}{e}    { return  new Symbol(TokenConstants.WHILE); }
<YYINITIAL>{l}{e}{t}    { return  new Symbol(TokenConstants.LET); }
<YYINITIAL>e{s}{a}{c}    { return  new Symbol(TokenConstants.ESAC); }
<YYINITIAL>{i}{s}{v}{o}{i}{d}    { return  new Symbol(TokenConstants.ISVOID); }
<YYINITIAL>{l}{o}{o}{p}    { return  new Symbol(TokenConstants.LOOP); }
<YYINITIAL>of    { return  new Symbol(TokenConstants.OF); }

<YYINITIAL>t{r}{u}{e}    { return  new Symbol(TokenConstants.BOOL_CONST, AbstractTable.idtable.addString("true")); }
<YYINITIAL>f{a}{l}{s}{e}    { return  new Symbol(TokenConstants.BOOL_CONST, AbstractTable.idtable.addString("false")); }

<YYINITIAL>{Digit}+ { return  new Symbol(TokenConstants.INT_CONST, AbstractTable.idtable.addInt(Integer.valueOf(yytext()))); }

<YYINITIAL>[A-Z]({Digit}|{Letter}|_)*   { return  new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext())); }
<YYINITIAL>[a-z]({Digit}|{Letter}|_)*   { return  new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }

<YYINITIAL>.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                     //System.err.println("LEXER BUG - UNMATCHED: " + yytext()); 
                                    return new Symbol(TokenConstants.ERROR, new String(yytext())); 
                                  
                                  }
