// Copyright (c) 2025 Symbol Not Found
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// github:SymbolNotFound/ts-gdl/ast.ts

export interface Rulebook {
  sentences: Sentence[]
}

export type Sentence =
    | {type: 'rule', rule: Rule}
    | {type: 'fact', fact: Fact}

export interface Rule {
  head: Fact
  body: Literal[]
}

export type Literal =
    | {type: 'not', arg: Literal}
    | {type: 'or', args: Literal[]}
    | {type: 'distinct', left: Literal, right: Literal}
    | {type: 'symbol', name: Symbol}
    | {type: 'relation', relation: Relation}

export type Fact =
    | {type: 'symbol', name: Symbol}
    | {type: 'relation', relation: Relation}

export interface Relation {
  name: Symbol
  args: Atom[]
}

export type Symbol = string

export type Atom =
    | {type: 'variable', varname: Symbol }
    | {type: 'funcall', fn: FunCall}
    | {type: 'constant', constant: Symbol }

export interface FunCall {
  name: Symbol
  args: Atom[]
}

export interface RoleDef {
  name: Symbol
}

export interface Interval {
  from: number
  until: number
}

export interface ForEach {
  range: Interval
  var: Variable
  body: Literal[]
}

