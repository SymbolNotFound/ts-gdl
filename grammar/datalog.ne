# Copyright (c) 2024 Symbol Not Found
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
# gdl-hrf.ne: grammar definition for Human-Readable Format of GDL.


@preprocessor typescript

@{%
const moo = require('moo');

let lexer = moo.compile({
  SPACE: {
    match: /\s+/,
    lineBreaks: true
  },
  COMMENT: {
    match: /%([^\n]*)/
  },
  NUMBER: {
    // Tokenizing only as far as the integers
    match: /(0|-?[1-9][0-9]*)/,
    value: s => Number(s)
  },
  STRING: {
    match: /"(?:\\["bfnrt\/\\]|\\u[a-fA-F0-9]{4}|[^"\n])*"/,
    value: s => JSON.parse(s).slice(1, -1)
  },
  VARIABLE: {
    match: /_|(\?[a-zA-Z]|[A-Z])[0-9A-Z_a-z]*/,
    value: s => (s[0] == "?") ? s.substring(1) : s
  },
  INFER: ":-",
  ENDRULE: ".",
  COMMA: ",",
  "(": "(", ")": ")",
  NAME: {
    match: /[a-z][0-9A-Z_a-z]*/,
    type: moo.keywords(
      Object.fromEntries([
        'true',
        'false',
      ]))}
})

%}

@lexer lexer


program -> program _ rule {%
  s => [ ...s[0], s[2] ]
%}
program -> rule {% id %}

rule -> atom _ %INFER _ atom_list _ %ENDRULE {%
  s => ({ "head": s[0], "body": s[4] })
%}

atom -> %SYMBOL _ "(" _ term_list _ ")" {%
  s => ({ "name": s[0], "args": s[4] })
%}

atom_list -> null
atom_list -> atom
atom_list -> atom_list _ %COMMA _ atom {% s => [ ...s[0], s[4] ] %}

term -> %NUMBER {% s => ({ "number": s[0] }) %}
term -> %STRING {% s => ({ "string": s[0] }) %}
term -> %VARIABLE {% s => ({ "var": s[0] }) %}

term_list -> null
term_list -> term
term_list -> term_list _ %COMMA _ term {% s => [ ...s[0], s[4] ] %}


# optional space
_ -> null 
   | %SPACE  {% s => null %}
   | _ %COMMENT %SPACE? {% s => ({ comment: [...s[0], s[1]] }) %}
