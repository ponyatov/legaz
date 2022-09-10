#include "ovm.hpp"

void arg(int argc, char *argv) {  //
  printf("argv[%i] = <%s>\n", argc, argv);
}

int main(int argc, char *argv[]) {
  arg(0, argv[0]);
  for (int i = 1; i < argc; i++) {
    arg(i, argv[i]);
    assert(yyin = fopen(argv[i], "r"));
    yyparse();
    fclose(yyin);
  }
}

#define YYERR "\n\n" << yylineno << ":" << msg << "[" << yytext << "]\n\n"
void yyerror(string msg) {
  cerr << YYERR; // cout << YYERR;
  exit(-1);
}

Object::Object(string V) { value = V; }

Object::~Object() {}

string Object::dump(int depth, string prefix) { return head(prefix); }

string Object::head(string prefix) {
  ostringstream os;
  os << prefix << "<" << tag() << ":" << val() << ">";
  return os.str();
}

#include <cxxabi.h>
string Object::tag() {
  return abi::__cxa_demangle(typeid(*this).name(), 0, 0, nullptr);
}

string Object::val() { return value; }

Primitive::Primitive(string V) : Object(V) {}

Sym::Sym(string V) : Primitive(V) {}
