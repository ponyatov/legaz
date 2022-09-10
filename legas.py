import os, sys

class Object:
    def __init__(self, V):
        self.type = self.tag()
        self.value = V
        self.slot = {}
        self.nest = []

    ## @name dump/stringify

    def __repr__(self): return self.dump()

    def dump(self, cycle=[], depth=0, prefix=''):
        # head
        def pad(depth): return '\n' + '\t' * depth
        ret = pad(depth) + self.head(prefix)
        # subtree
        return ret

    def head(self, prefix=''):
        gid = f' @{id(self):x}'
        return f'{prefix}<{self.tag()}:{self.val()}>{gid}'

    def tag(self): return self.__class__.__name__.lower()
    def val(self): return f'{self.value}'

    ## @name operator

    def __getitem__(self, key):
        if isinstance(key, str): return self.slot[key]
        raise TypeError(['__getitem__', type(key), key])

class Primitive(Object): pass

class Sym(Primitive):
    def exec(self, env): return env[self.val()]

class Container(Object): pass

class Map(Container): pass

class Active(Object): pass

class Cmd(Active):
    def __init__(self, F):
        assert callable(F)
        super().__init__(F.__name__)

class Env(Active, Map): pass

glob = Env('FORTH')

import ply.lex as lex

tokens = ['sym']

t_ignore = '[ \t\r]+'

def t_nl(t):
    r'\n+'
    t.lineno += len(t.value)

def t_comment(t):
    '\#.*'
    pass

def t_sym(t):
    r'[^ \t\r\n]+'
    return Sym(t.value)

def t_error(t): raise SyntaxError(t)

lexer = lex.lex()

if __name__ == '__main__':
    for i in sys.argv[1:]:
        with open(i) as src:
            lexer.input(src.read())
            while True:
                token = lexer.token()
                if not token: break
                print(token.exec(glob))
