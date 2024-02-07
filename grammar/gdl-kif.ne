# Copyright (c) 2023 Symbol Not Found L.L.C.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# gdl-kif.ne: grammar definition for prefix-notation format of GDL.


@{%
import "astutil.js";
%}

# Enable this to compile to TypeScript instead of JavaScript
# @preprocessor typescript

@{%
// Tokenizer definition provided via https://github.com/no-context/moo
const moo = require('moo');

let lexer = moo.compile({
  SPACE: {
    match: /\s+/,
    lineBreaks: true
  },
  COMMENT: {
    match: /;+([^\n]*)/,
    value: s => s.substring(1).trim()
  },
  L_INFER: '<=',
  '?': '?',
  "(": "(",  ")": ")",
  NUMBER: {
    match: /([0-9]+)/,
    value: s => Number(s)
  },
  STRING: {
    match: /"(?:\\["bfnrt\/\\]|\\u[a-fA-F0-9]{4}|[^"\\\n])*"/,
    value: s => JSON.parse(s).slice(1, -1)
  },
  IDENT: {
    match: /_|[a-zA-Z]+/,
    type: moo.keywords({
      KEYWORD: [
          'role', 'base', 'input',
          'init', 'terminal', 'goal',
          'next', 'legal', 'does',
          'distinct', 'true', 'or', 'and', 'not'
          // sent by Game Manager during play
          'start',
          'ready',
          'play',
          'stop',
          'done',
          // introduced in GDL-II
          'sees', 'random'
          // introduced in GDL-III
          'knows'
      ]
  })}
});
%} # end of lexer definition

@lexer lexer

#-----------+
# SENTENCES |
#===========*

# First production rule is the default production for the parser.
input -> _ sentence+ _ {% id %}

# This production rule handles multiple sentences surrounded by optional space.
sentence+ -> sentence

# continuation if there are multiple sentences
sentence+ -> sentence+ _ sentence {% d => [ ...d[0], d[2] ] %}

sentence ->
    role_defn {% id %}
  | init_rule {% id %}
  | base_rule {% id %}
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
      type: "infer",
      head: d[4],
      body: d[6],
      start: startOfToken(d[0]),
      end: end(d[8])
    })
%}

# Only certain game-independent relations will be in the head of an inference.
head_relation ->
    input_relation {% id %}
  | next_relation  {% id %}
  | base_rule      {% id %}
  | relation+      {% id %}

# Only certain game-independent relations will be in the body of an inference.
body_relation ->
    does_relation {% id %}
  | role_reln     {% id %}
  | relation+     {% id %}

relation+ -> relation {% id %} 
relation+ -> relation+ _ relation {% 
  d => [...d[0], d[2]]
%}

relation ->
    logical_relation {% id %}
  | legality_rule    {% id %}
  | goal_function    {% id %}
  | ground_term      {% id %}

#--------------+
# PLAYER ROLES |
#==============*

# Role definition, a role relation appearing at the global scope.
role_defn -> "(" _ "role" __ name _ ")" {%
  d => ({
    type: "role_def",
    name: d[4],
    start: start(d[0]),
    end: end(d[6])
  })
%}

# A role relation can refer to a ground term or a variable. 
role_reln -> "(" _ "role" __ var _ ")" {%
  d => ({
    type: "role_rel",
    name: roleName(d[4]),
    start: start(d[0]),
    end: end(d[6])
  })
%}

#-------+
# FACTS |
#=======*

# A base rule indicates a term or relation of the domain without asserting its
# presence in the knowledge base.  It helps the solver determine the limits of
# knowledge, but typically these base rules could be inferred by the game rules.
base_rule -> "(" _ "base" __ relation _ ")" {%
  d => ({
    type: "base",
    body: d[4],
    start: start(d[0]),
    end: end(d[6])
  })
%}

# An init rule defines a relation that holds true at the start of the game.
init_rule -> "(" _ "init" __ ground_relation _ ")" {%
  d => ({
    type: "init",
    body: d[4],
    start: start(d[0]),
    end: end(d[6])
  })
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

#-----------------+
# GROUND RELATION |
#=================*

# Grounded relations are composed entirely of ground terms and other ground
# relations.  This is enforced at the syntax level here in the parser.
ground_relation -> "(" _ name (__ ground_term+ {% d => d[1] %}):? _ ")" {%
  d => ({
    type: "relation",
    grounded: true,
    relation: d[2],
    parameters: d[3],
    start: start(d[0]),
    end: end(d[5])
  })
%}

# Produces a list of terms, all of which do not contain any free variables.
ground_term+ ->
    ground_term+ __ ground_term {%
        d => [...d[0], d[2]]
    %}
  | ground_term _ {% d => [d[1]] %}

# A ground term is one that is non-variable.  If it contains a relation in the
# term then that relation and its members are also ground.
ground_term ->
    %NUMBER         {% id %}
  | name            {% id %}
  | terminal        {% id %}
  | ground_relation {% id %}

#---------+
# GENERAL |
#=========*

# Variables are indicated by a `?` prefix.
var -> "?" name {%
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
