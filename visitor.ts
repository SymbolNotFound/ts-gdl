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
// github:SymbolNotFound/ts-gdl/visitor.ts

import * as ast from './ast'

export interface Visitor {
  visit(rules: ast.Rulebook)
  visit_sentence(_: ast.Sentence)
  visit_symbol(_: ast.Symbol)
  visit_relation(_: ast.Relation)
  visit_fact(_: ast.Fact)
  visit_rule(_: ast.Rule)
  visit_funcall(_: ast.FunCall)
  visit_atom(_: ast.Atom)
  visit_literal(_: ast.Literal)
  visit_role(_: ast.RoleDef)
  visit_interval(_: ast.Interval)
  visit_foreach(_: ast.ForEach)
}
