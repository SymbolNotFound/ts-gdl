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
  NAME: {
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


#-----------+
# SENTENCES |
#===========*

# First production rule is the default production for the parser.
rulesheet -> _ sentence+ _ {% s => s[1] %}

# This production rule handles multiple sentences surrounded by optional space.
sentence+ -> sentence
sentence+ -> sentence+ _ sentence {% d => [ ...d[0], d[2] ] %}

sentence ->
    role_defn {% id %}
  | inference {% id %}
  | relation  {% id %}

#-----------+
# INFERENCE |
#===========*

# This is a kind of right-to-left inference within a stratified and universally
# quantified logic as defined by GDL.  The expression is true when either
# head_expression is true or any body expressions are not true, or both.
inference -> "(" _ %L_INFER __ head_relation (__ body_relation):* _ ")" {%
    d => ({
      infer: d[4],
      when: d[6],
      start: startOfToken(d[0]),
      end: end(d[8])
    })
%}

# Only certain game-independent relations will be in the head of an inference.
head_relation ->
    base_rule      {% id %}
  | init_rule      {% id %}
  | input_relation {% id %}
  | next_relation  {% id %}
  | legal_relation {% id %}
  | goal_relation  {% id %}
  | object         {% id %}
  | functionapply  {% id %}

# Only certain game-independent relations will be in the body of an inference.
body_relation ->
    does_relation {% id %}
  | role_var      {% id %}
  | term          {% id %}

#--------------+
# PLAYER ROLES |
#==============*

# Role definition, a role relation appearing at the global scope.
role_defn -> "(" _ "role" __ name _ ")" {%
    s => new Role(s[4].name, start(s[0]), end(s[6]))
%}

# A role relation can refer to a ground term or a variable. 
role_var -> "(" _ "role" __ var _ ")" {%
    s => new RoleVar(s[4].name, start(s[0]), end(s[6]))
%}

#-------+
# FACTS |
#=======*

# A base rule indicates a term or relation of the domain without asserting its
# presence in the knowledge base.  It helps the solver determine the limits of
# knowledge, but typically these base rules could be inferred by the game rules.
base_rule -> "(" _ "base" __ relation _ ")" {%
    s => new BaseRule(s[4], start(s[0]), end(s[6]))
%}

# An init rule defines a relation that holds true at the start of the game.
init_rule -> "(" _ "init" __ ground_relation _ ")" {%
    s => new InitRule(s[4], start(s[0]), end(s[6]))
%}

#---------+
# ACTIONS |
#=========*

# An input describes a possible player action.  These are referred to by the
# `legal` and `does` relations and typically could be inferred from them.
input_relation -> "(" _ "input" __ var_or_name __ relation _ ")" {%
  d => ({
    type: "input",
    role: roleName(d[4]),
    action: d[6],
    start: start(d[0]),
    end: end(d[8])
  })
%}

# Indicates that it is legal for a player to take the specified action.
legality_rule -> "(" _ "legal" __ var_or_name __ relation _ ")" {%
  d => ({
    type: "legal",
    role: roleName(d[4]),
    action: d[6],
    start: start(d[0]),
    end: end(d[8])
  })
%}

# The indicated player has done the action, either directly or as a result of
# the Game Master choosing a random action for the player to take.  This
# relation will typically appear in the body of an inference for a `next` rule.
does_relation -> "(" _ "does" __ var_or_name __ relation _ ")" {%
  d => ({
    type: "does",
    role: roleName(d[4]),
    action: d[6],
    start: start(d[0]),
    end: end(d[8])
  })
%}

# The indicated relation will hold true in the next state if the next relation
# is itself true (derived by the inference rule it is part of).
next_relation -> "(" _ "next" __ relation _ ")" {%
  d => ({
    type: "next",
    body: d[4],
    start: start(d[0]),
    end: end(d[6])
  })
%}

#------------+
# COMPARISON |
#============*

# N-ary operators must have at least two relations in the body.
logical_relation -> "(" _ logical_nary_op __ relation _ (relation _):+ ")" {%
  d => ({
    type: d[2],
    body: d[4],
    start: start(d[0]),
    end: end(d[8])
  })
%}

# A logical relation may also have unary operation(s) enclosing it.
logical_relation -> "(" _ logical_unary_op __ relation _ ")" {%
  d => ({
    type: d[2],
    body: d[4],
    start: start(d[0]),
    end: end(d[6])
  })
%}

# The available n-ary operators are (syntactically) distinct, along with
# logical "or" (true if any parameter is true) and logical "and" (true iff
# every parameter is true).
logical_nary_op -> ( "distinct" |  "or" | "and" ) {% id %}

# The available unary operators are "true" and "not" using empirical truth and
# "negation-as-failure" (NAF), respectively.
logical_unary_op -> ( "true" | "not" ) {% id %}

#------------+
# RESOLUTION |
#============*

# Special GDL keyword that resolves to true when the game has terminated.
terminal -> "terminal" {% id %}

# Goal relations define the outcome for each player at a terminal game state.
goal_function -> "(" _ "goal" __ var_or_name __ %NUMBER _ ")" {%
  d => ({
    type: "goal",
    role: roleName(d[4]),
    value: d[6],
    start: start(d[0]),
    end: end(d[8])
  })
%}

#---------+
# GENERAL |
#=========*

term ->
    object           {% id %}
  | terminal         {% id %}
  | variable         {% id %}
  | logical_relation {% id %}
  | functionapply    {% id %}

# Variables are indicated by a `?` prefix.
variable -> "?" name {%
  d => ({
    type: "variable",
    name: d[1],
    start: start(d[0]),
    end: d[1].end
  })
%}

# Either a variable or a symbolic name.
var_or_name -> var {% id %} | name {% id %}

# Names may be represented as a symbol or a string, and there are equivalent
# values across those representations so we unify them here.
name -> %IDENT {%
    d => newName(d[0].value, start(d[0]), end(d[0]))
%}
name -> %STRING {%
    d => newName(d[0].value, start(d[0]), end(d[0]))
%}

# Nearley doesn't provide the _ and __ shorthands when using a lexer,
# but they are much more convenient and readable than %SPACE:* or %SPACE
# and during matching it allows us to fold them all into `null` as well.

# optional space
_ -> %SPACE:? {% d => null %}
# mandatory space
__ -> %SPACE {% d => null %}
