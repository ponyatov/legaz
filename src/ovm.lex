%{
    #include "ovm.hpp"
%}

%option yylineno noyywrap

%%
#.*             {}                  // line comment
[ \t\r\n]+      {}                  // drop spaces
[^ \t\r\n]+     TOKEN(Sym,SYM)
