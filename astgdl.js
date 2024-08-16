// Copyright (c) 2023 Symbol Not Found
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 
// github:SymbolNotFound/ts-gdl/astgdl.js

// Represents AST nodes
class AstNode {
  constructor(type, start, end) {
    this.type = type;
    this.lexeme = { start, end }
  }
}

// All AST nodes are given start and end positions to locate them lexically.
class Position {
  constructor(line, column) {
    this.line = line
    this.column = column
  }
}

// Returns a {line, col} position object for the beginning of a token.
function start(token) {
  return new Position(token.line, token.col)
}

// Returns a {line, col} position for the end of a token.  NOTE: this assumes
// there are no newlines within the token (such as in space-capturing tokens).
// Albeit unlikely, avoid using this function on tokens that may contain `\n`,
// or modify the production rule to have its final token exist within one line.
function end(token) {
  return new Position(token.line, token.col + token.text.length)
}

// A role definition, its name is always a ground constant symbol or string.
class Role extends AstNode {
  constructor(name, start, end) {
    super('role', start, end)
    this.name = name
  }
}

// A variable that only unifies with the role type.
class RoleVar extends AstNode {
  constructor(varname, start, end) {
    super('rolevar', start, end)
    this.varname = varname
  }
}

// An operator with a single operand.
class UnaryOp extends AstNode {
  constructor(opname, operand, start, end) {
    super(opname, start, end)
    this.operand = operand
  }
}

// An operator with two operands (e.g. logical AND, distinct, etcetera).
class BinaryOp extends AstNode {
  constructor(opname, left, right, start, end) {
    super(opname, start, end)
    this.left = left
    this.right = right
  }
}

// Declares an input as a base relation.
class ActionInput extends AstNode {
  constructor(rolename, action, start, end) {
    super('input', start, end)
    this.role = rolename
    this.action = action
  }
}

// The head of a rule that describes allowed actions for certain players.
class ActionLegal extends AstNode {
  constructor(rolename, action, start, end) {
    super('legal', start, end)
    this.role = rolename
    this.action = action
  }
}

// A body clause may include this as a fact of a certain player's action.
class ActionDone extends AstNode {
  constructor(rolename, action, start, end) {
    super('does', start, end)
    this.role = rolename
    this.action = action
  }
}

// The head of a rule that describes a relation to hold true in the next turn,
// provided that the relations in the body are consistent with the model.
class ActionNext extends AstNode {
  constructor(action, start, end) {
    super('next', start, end)
    this.action = action
  }
}

// A relation may be a function, an object or a multivariate ground fact.
class Relation extends AstNode {
  constructor(name, params, start, end) {
    super('relation', start, end)
    this.name = name
    this.arity = len(params)
    this.params = params
    this.ground = (name[0] >= 'a' && name[0] <= 'z')
  }
}

// A fact is like a function or relation of arity 0.
class Fact extends AstNode {
  constructor(relation, start, end) {
    super('fact', start, end)
    this.relation = relation
  }
}

// A variable, a term which may be replaced with a constant during unification.
class Variable extends AstNode {
  constructor(varname, start, end) {
    super('var', start, end)
    this.varname = varname
  }
}

// A rule implies that `head` is true when `body` is consistent with the model.
class Rule extends AstNode {
  constructor(ruletype, head, body, start, end) {
    super(ruletype, start, end)
    this.head = head
    this.body = body
  }
}

// Defines a domain in terms of facts or relations that may hold true.
class BaseRule extends Rule {
  constructor(head, body, start, end) {
    super('base', head, body, start, end)
  }
}

// Indicates that the relation is true, conditioned on body (if it exists).
class InitRule extends Rule {
  constructor(head, body, start, end) {
    super('init', head, body, start, end)
  }
}

// The special fact indicating that the game has terminated.
class Terminal extends Fact {
  constructor(start, end) {
    super('terminal', start, end)
  }
}

// A special operation on a role and a numeric value from 0 to 100 (inclusive).
// The body of the rule which this relation is the head of will determine that
// this goal evaluates to true.
// Goals should be mutually exclusive for each player.
class Goal extends BinaryOp {
  constructor(name, value, start, end) {
    super('goal', name, value, start, end)
  }
}
