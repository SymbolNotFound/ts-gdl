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
# gdl-hrf.ne: grammar definition for Human-Readable Format of GDL.

@{%
import "astgdl.js";
%}

@{%
// Tokenizer definition provided via https://github.com/no-context/moo
const moo = require('moo');

let lexer = moo.compile({
  SPACE: {
    match: /\s+/,
    lineBreaks: true
  },
  COMMENT: {
    // Human-readable format GDL typically uses `%` for comments.
    match: /%+([^\n]*)/,
    value: s => s.substring(1).trim()
  },
  L_INFER: ":-",
  DYN_COND: "::",
  DYN_EFFECT: "==>",
  "|": "|",
  "&": "&",
  "~": "~",
  "#": "#",
  "(": "(", ")": ")",
  ",": ",",
  NUMBER: {
    // Tokenizing only as far as the integers
    match: /(0|-?[1-9][0-9]*)/,
    value: s => Number(s)
  },
  STRING: {
    match: /"(?:\\["bfnrt\/\\]|\\u[a-fA-F0-9]{4}|[^"\n])*"/,
    value: s => JSON.parse(s).slice(1, -1)
  },
  VAR: {
    match: /_|(\?[a-zA-Z]|[A-Z])[0-9A-Z_a-z]*/,
    value: s => (s[0] == "?") ? s.substring(1) : s
  },
  NAME: {
    match: /[a-z][0-9A-Z_a-z]*/,
    type: moo.keywords({
      KEYWORD: [
          'role',
          'base',
          'input',
          'init',
          'true',
          'does',
          'legal', 
          'goal',
          'terminal', 
          'not',
          'or',
          'distinct',
          // sent by Game Manager during play
          'start',
          'ready',
          'play',
          'stop',
          'done',
          // introduced in GDL-II
          'sees',
          'random',
      ]
  })}
});
%} # end of lexer definition

@lexer lexer

# Enable this to compile to TypeScript instead of JavaScript
# @preprocessor typescript

#-----------.
# SENTENCES |
#==========='

# Valid input is one or more sentences.  Typically a valid game will require
# several sentences to be complete and playable -- it must provide complete
# definitions for `role`, `input`, `base`, and `init`.

input -> rulesheet

rulesheet -> _ sentences _ {% s => s[1] %}

# Multiple sentences.  Note, left-recursion is faster for Earley.
sentences -> sentence
sentences -> sentences _ sentence {% s => [ ...s[0], s[2] ] %}

# A sentence is a relation (non-negated) or one of the special relations,
# or an inference, including inferences with other special GDL relations.
sentence ->
    role_defn {% id %}
  | init_rule {% id %}
  | base_rule {% id %}
  | inference {% id %}
  | relation  {% id %}

# A set of relation constants with associated arity.
relation ->
    logical_relation {% id %}
  | legal_relation   {% id %}
  | goal_relation    {% id %}
  | functionapply    {% id %}


#-----------.
# INFERENCE |
#==========='

# An inference consists of a head (the conclusion) and its body (premises),
# zero or more propositions which &'ed together determine the head's truth.
inference -> head_relation _ %L_INFER _ conjunction {%
    s => new Rule(':-', s[0], s[4], s[0].start, s[4][len(s[4])-1].end)
%}

# Only certain game-independent relations will be in the head of an inference.
head_relation ->
    input_relation {% id %}
  | next_relation  {% id %}
  | base_rule      {% id %}
  | functionapply  {% id %}

# A conjunction joins terms in a logical and operation.
conjunction -> body_relation {% id %}
conjunction -> conjunction _ "&" _ body_relation {%
    s => new BinaryOp('&', s[0], s[4], s[0].start, s[4].end)
%}

# Only certain game-independent relations will be in the body of an inference.
body_relation ->
    does_relation    {% id %}
  | role_var         {% id %}
  | logical_relation {% id %}
  | functionapply    {% id %}

#--------------.
# PLAYER ROLES |
#=============='

# `role(a)` means that `a` is a role in the game.  It is a complete sentence.
role_defn -> "role" _ "(" _ name _ ")" {%
    s => new Role(s[4].name, start(s[0]), end(s[6]))
%}

# `role(?p)` is a relation binding the variable `?p` to a valid role.  It is
# used to constrain variables to a role type and with `distinct` to separate
# acting roles from their opponents or their pieces from their opponents'.
# It typically appears within relations in the body (premises) of an inference.
role_var -> "role" _ "(" _ var _ ")" {%
    s => new RoleVar(s[5].name, start(s[0]), end(s[7]))
%}

#-------.
# FACTS |
#======='

# `base(p)` means that `p` is a base proposition in the game's knowledge base.
# This describes the domain but does not assert the existence of any relations.
# It may be part of an inference to further constrain its proposition's terms.
base_rule -> "base" _ "(" _ term _ ")" {%
    s => new BaseRule(s[4], start(s[0]), end(s[6]))
%}

# `init(p)` means that the proposition `p` is true in the initial state.  There
# must not be any free variables in the relation within `init`.
init_rule -> "init" _ "(" _ term _ ")" {%
    s => new InitRule(s[4], start(s[0]), end(s[6]))
%}

#---------.
# ACTIONS |
#========='

# `input(r, a)` means that `a` is an action for role `r`.
input_relation -> "input" _ "(" _ name _ "," _ functionapply _ ")" {%
    s => new ActionInput(s[4], s[8], start(s[0]), end(s[10]))
%}

# `legal(r, a)` means it is legal for role `r` to play `a` in the current state.
# It must be defined in terms of input `true` relation(s).
legal_relation -> "legal" _ "(" _ name _ "," _ functionapply _ ")" {%
    s => new ActionLegal(s[4], s[8], start(s[0]), end(s[10]))
%}

# `does(r, a)` means that player `r` performs action `a` in the current state.
does_relation -> "does" _ "(" _ name _ "," _ functionapply _ ")" {%
    s => new ActionDone(s[4], s[8], start(s[0]), end(s[10]))
%}

# `next(p)` means that the proposition `p` is true in the next state.
# This will typically appear in the head of an inference and must depend on
# `true` and `does` relations in its premises.
next_relation -> "next" _ "(" _ functionapply _ ")" {%
    s => new ActionNext(s[4], start(s[0]), end(s[6]))
%}

#------------.
# COMPARISON |
#============'

logical_relation ->
    true_function {% id %}
  | not_function  {% id %}
  | or_function   {% id %}
  | distinct_op   {% id %}

# `true(p)` means that the proposition `p` is true in the current state.
true_function -> "true" _ "(" _ functionapply _ ")" {%
    s => new UnaryOp('true', s[4], start(s[0]), end(s[6]))
%}

# `not(p)` evaluates to true if proposition is not in KB, false if it is.
not_function -> "not" _ "(" _ term _ ")" {%
    s => new UnaryOp('not', s[4], start(s[0]), end(s[6]))
%}
# Alternate representation of logical negation.
not_function -> "~" term {%
    s => new UnaryOp('not', s[1], start(s[0]), s[1].end)
%}

# `or(a, b, ...)` evaluates to true if any of its parameters return true.
or_function -> "or" _ "(" _ relation _ "," _ terms _ ")" {%
    s => new Relation('or', [s[4], ...s[8]], start(s[0]), end(s[8]))
%}

# Distinct (`#`) evaluates to true if `a` and `b` are syntactically inequal.
distinct_op -> term _ "#" _ term {%
    s => new BinaryOp('distinct', s[0], s[4], s[0].start, s[4].end)
%}
# Distinct may also be formatted as a function application.
distinct_op -> "distinct" _ "(" _ term _ "," _ terms _ ")" {%
    s => new Relation('distinct', [s[4], ...s[8]], start(s[4]), end(s[10]))
%}

#------------.
# RESOLUTION |
#============'

# Terminal is just another object but it has a very important meaning in GDL.
# It indicates that the current state is one which ends the game.
terminal -> "terminal" {%
    s => new Relation('terminal', [], start(s[0]), end(s[0]))
%}

# `goal(r, u)` means that the current state has utility `u` for player `r`. 
# The inference it is a part of must have premises defined in terms of `true`.
goal_relation -> "goal" _ "(" _ name _ "," _ %NUMBER _ ")" {%
    s => new Goal(s[4], s[8], start(s[0]), end(s[10]))
%}

#---------.
# GENERAL |
#========='

# optional space
_ -> null 
   | %SPACE  {% s => null %}
   | _ %COMMENT %SPACE? {% s => ({ comment: [...s[0], s[1]] }) %}

# A symbol is when quoted terms are avoided, 
sym_name -> %NAME {% s => s[0].value %}

# A name may be a quoted string or an unquoted symbolic name (function_name).
name -> sym_name {% id %}
name -> %STRING {% s => s[0].value %}

# A variable has its own namespace and represents a substitution for an atom.
var -> %VAR {%
    s => new Variable(s[0].value, start(s[0]), end(s[0]))
%}

# Some productions expect either a var or a name but only a single term.
var_or_name -> var {% id %} | name {% id %}

#---------.
# GENERAL |
#========='

# Valid terms include objects, variables and function applications.
term ->
    object           {% id %}
  | variable         {% id %}
  | logical_relation {% id %}
  | functionapply    {% id %}

# An object constant is any relation that has arity 0.
object -> %NAME {% s => new Relation(s[0], [], start(s[0]), end(s[0])) %}

# The reserved keyword `terminal` is also a valid object.
object -> terminal {% id %}

# A variable is any symbol that starts with a capital letter.
variable -> %VAR {% s => new Variable(s[0].value, start(s[0]), end(s[0])) %}

# A relation that has arity greater =>= 1.
functionapply -> %NAME _ "(" _ terms _ ")" {%
    s => new Relation(s[0], s[4], s[0].start, end(s[6]))
%}

# Multiple terms may be joined with commas.
terms -> term
  | terms _ "," _ term {% s => [ ...s[0], s[4] ] %}
