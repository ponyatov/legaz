%{
    #include "ovm.hpp"
%}

%defines %union { Object* o; }

%token<o> SYM

%%
syntax  :
        | syntax SYM { cout << $2->dump() << endl; }
