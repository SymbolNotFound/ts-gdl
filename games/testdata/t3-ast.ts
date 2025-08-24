// MIT License
// 
// Copyright (c) 2024 Symbol Not Found
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 
// github:SymbolNotFound/ts-gdl/games/tesdata/t3-ast.ts

class Role {
  constructor(name: string) {}
}

type Fact =
  | SymName
  | LiteralRelation

class Rule {
  constructor(head: Value, ...body: Value[]) {}
}

class NextRule {
  constructor(head: Relation, ...body: Value[]) {}
}

class Relation {
  constructor(name: string, ...args: Value[]) {}
}

type Literal =
  | number
  | string
  | SymName
  | LiteralRelation

class LiteralRelation {
  constructor(name: string, ...args: Literal[]) {}
}

type Value =
  | Variable
  | Literal
  | Relation

type SymName = string

class Variable {
  constructor(name: string) {}
}

const t3_ast = {
  roles: [new Role("x"), new Role("o")],
  const: [
    new LiteralRelation("coord", 1),
    new LiteralRelation("coord", 2),
    new LiteralRelation("coord", 3),
    new Rule(
      new Relation("iscell", new Variable("m"), new Variable("n")),
      new Relation("coord", new Variable("m")),
      new Relation("coord", new Variable("n")))
  ],
  init: [
    new LiteralRelation("control", "x" as SymName)
  ],
  next: [
    new NextRule(
      new Relation("cell", new Variable("m"), new Variable("n"), "x" as SymName),
      new Relation("does", "x" as SymName, new Relation("mark", new Variable("m"), new Variable("n")))
    ),
    new NextRule(
      new Relation("cell", new Variable("m"), new Variable("n"), "o" as SymName),
      new Relation("does", "o" as SymName, new Relation("mark", new Variable("m"), new Variable("n")))
    )
  ],

}
