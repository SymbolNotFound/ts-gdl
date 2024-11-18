# # Copyright (c) 2024 Symbol Not Found
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# tau-prolog.ne: Grammar and Lexer definition for Tau Prolog, from
# "Tau Prolog Grammar specification" by Jos'e A. Riaza and Miguel Riaza.
# 2018 (June 11 revision) from http://tau-prolog.org/files/doc/grammar-specification.pdf

@preprocessor typescipt
@{%
import "tau-prolog.ts"
%}

# The lexer is buit with https://github.com/no-context/moo

@{%
const moo = require('moo');

let terminals = moo.compile({
  SPACING: /\s+/,
  COMMENT: /(?:%.*|\/\*(?:\n|\r|.)*?\*\/)/,
  VARIABLE: /[A-Z_][A-Za-z0-9_]*/,
  
  // This combines operators, names, predicate symbols and `string`s into one
  // token type.  If there are a lot of mistaken branches because of token type
  // testing, perhaps operators should be split out into their own token.
  ATOM: {
    match: /!|,|;|[a-z][0-9a-zA-Z_]*|[#\$\&\*\+\-\.\/\:\<\=\>\?@\^\~\\]+|`(?:[^`]*?(?:\\(?:x?\d+)?\\)*(?:``)*(?:\\`)*)*`/,
    type: moo.keywords(
      Object.fromEntries([
        'is',
        'rem',
        'mod',
      ].map(k => ['kw-'+k, k])))},

  // I usually also split the different types of number up so that the rule->AST
  // transform can do the appropriate string parsing while creating the const.
  NUMBER: /0o[0-7]+|0x[0-9a-f]+|0b[01]+|\d+(?:.\d+)?(?:e[+-]?\d+)?/,
  STRING: /"([^"]|""|\\")*"|'([^']|''|\\')*'/,

  // Brackets and Parentheses.
  "{": "{", "}": "}",
  "[": "[", "]": "]",
  "(": "(", ")": ")",

  // List generation.
  BAR: "|",
  // Metasyntactic.
  DOT: ".",
});
%}

@lexer terminals

## [ initial rule should avoid being recursive ] ##
file -> program
prompt -> program

program -> program _ rule | rule

# A program consists entirely of rules, delimited by the '.' token.
rule -> exprrr1200 %DOT

# Since nearley doesn't really let us build parameterized production rules,
# the expression definition here is not going to be as succinct as in the paper.
#
# I think there may be a way to surgically insert it into the grammar after
# generating the parser and before reset/next on any input.  This much would
# have to be done for an implementation that allows for user-defined operators.

expr_n -> op_fx expr_1
        | op_fy expr_n
#        | expr_1 op_xf
#        | expr_n op_yf
        | expr_1 op_xfx expr_1
        | expr_1 op_xfy expr_n
        | expr_n op_yfx expr_1
        | expr_1

# This rule is an approximation, and would be the surgical insertion point.
# Otherwise, the grammar can only interpret operator nesting up to depth 2.
expr_1 -> op_fx expr_0
        | op_fy expr_1
#        | expr_1 op_xf
#        | expr_1 op_yf
        | expr_0 op_xfx expr_0
        | expr_0 op_xfy expr_1
        | expr_1 op_yfx expr_0
        | expr_0

expr_0 -> %NUMBER | %VARIABLE | %STRING
        | list | term
        | "(" _ exprrr1200 _ ")"
        | "[" _ exprrr1200 _ "]"

# Least operator precedence value is 1200 (1201 for operands on the end).
exprrr1200 -> expr_n


term -> atom _ term_2

term_2 -> "(" _ expr_999 _ term_3
        | lambda

term_3 -> "," _ expr_999 _ term_3
        | ")"

# Another surgical insertion point.
expr_999 -> expr_n


list -> "[" _ list_2

list_2 -> expr_999 _ list_3
        | "]"

list_3 -> "," _ expr_999 _ list_3
        | "|" _ expr_999 _ "]"
        | "]"


op_fx -> ":-" | "?-"                # priority 1200

op_fy -> "\\+"                      # priority 900
       | "-" | "+" | "\\" | "\\\\"  # priority 200

op_xfx -> ":-" | "-->"              # priority 1200
          | "=" | "\\="             # priority 700
          | "==" | "\\=="
          | "@<" | "@=<" | "@>" | "@>=" | "is"
          | "=:=" | "=\\=" | "<" | "=<" | ">" | ">="
          | "=.."                   # priority 700
          | "**" | "\\\\"           # priority 200

op_xfy -> "^" | "\\\\"
op_yfx -> "+" | "-" | "/\\" | "\\/" # priority 500
        | "*" | "/" | "//"          # priority 400
        | "rem" | "mod"
        | "<<" | ">>"               # priority 400

