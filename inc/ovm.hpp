#pragma once

#include <assert.h>
#include <stdio.h>

#include <iostream>
#include <sstream>
using namespace std;

struct Object {
  /// scalar: object name, string/number value,..
  string value;

  /// @name constructor
  Object(string V);
  virtual ~Object();

  /// @name dump/stringify
  /// full text tree dump
  string dump(int depth = 0, string prefix = "");
  /// `<T:V>` header
  string head(string prefix);
  /// tree padding
  string pad(int depth = 0);
  /// type/class tag
  virtual string tag();
  /// stringified value (differ for numbers)
  virtual string val();
};

struct Primitive : Object {
  Primitive(string V);
};

struct Sym : Primitive {
  Sym(string V);
};

extern int yylex();
extern char* yytext;
extern int yylineno;
extern FILE* yyin;
extern void yyerror(string msg);
extern int yyparse();
#include "vm.parser.hpp"
#define TOKEN(C, X)           \
  {                           \
    yylval.o = new C(yytext); \
    return X;                 \
  }
