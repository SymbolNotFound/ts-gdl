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
# github:SymbolNotFound/ts-gdl/grammar/gdl-kif.ne

@preprocessor typescript

@{%
const ast = require('~~/ast.ts')
const moo = require('moo')

let lexer = moo.compile({
  SPACE: /\s+/,
  ENDLINE: {
    match: /\n+/,
    lineBreaks: true
  },
  L_PAREN: '(',
  R_PAREN: ')',
  INFER: '<=',
  VARNAME: /[A-Z][0-9A-Z_a-z]*/,
  SYMBOL: {
    match: /[a-z][0-9A-Z_a-z]*/,
    type: moo.keywords(
      Object.fromEntries([
        'base',
        'distinct',
        'does',
        'goal',
        'init',
        'input',
        'legal',
        'next',
        'not',
        'or',
        'role',
        'terminal',
        'true',
      ].map(kw => ['kw-'+kw, kw])))}
})
%}
@lexer lexer

