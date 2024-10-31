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
# ebnf.ne: a Nearley parser for an extended version of Backus-Naur Form.

# Enable this to compile to TypeScript instead of Javascript
# @preprocessor typescript

@{% 
const moo = require("moo")

let lexer = moo.compile({
  SPACING: {
    match: /\s+/,
    lineBreaks: true
  },
  COMMENT: {
    match: /\(\*(?:[^*]+|\*+[^)])*\*+\)/,
    lineBreaks: true
  },
  // Production definition
  "::=": "::=",
  // Alternative
  "|": "|",
  // Factors
  "?": "?", "*": "*", "+": "+",
  // List-element and Record-attribute separators
  ":": ":", ",": ",", ".": ".",
  // Postprocessing
  "=>": "=>",
  "\\": "\\",
  "...": "...",
  // Grouping of terms and postproc structure
  "(": "(", ")": ")",
  "[": "[", "]": "]",
  "{": "{", "}": "}",
  // Only positive integers (including zero) are used in this grammar.
  NUMBER: {
    match: /(?:0|[1-9][0-9]*)/,
    value: s => Number(s)
  },
  // String only recognizes double-quotation marks.  These are trimmed off when
  // expressed as the token's `value`.
  STRING: {
    match: /"(?:[^\n\\"]|\\["\\ntbfr])*"/,
    value: s => JSON.parse(s).slice(1, -1)
  },
  CHARCLASS: /\[(?:\\.|[^\\\n])+?\]/,
  PATTERN: /\/(?:\\.|[^\\\n])+?\/m?/,
  // Identifier (nonterminal) names are any that begin with a letter and contain
  // only '_'+alphanumeric, excluding those that would be recognized as keywords.
  WORD: {
    match: /[A-Z_a-z][A-Z_a-z0-9]*/,
    type: moo.keywords({
      KEYWORD: [
        "except",
        "include",
        "keyword"
      ]
    })
  }
})

%}
@lexer lexer

# Start state, consumes leading & trailing spaces so other rules don't have to.
input -> _ grammar _ {% s => ({
  "rules": s[1],
  "start": s[1][0]["name"]
}) %}

# The grammar is a sequence of productions, with spacing & comments between.
grammar -> production
# Note: there should be at least some spacing between productions.
grammar -> grammar __ production {% s => [ ...s[0], ...s[1], s[2] ] %}

# optional space
_ -> __:?

# at-least-one space and/or comment
__ -> __:? %SPACING {% s => expand(s[0]) %}
    | __:? %COMMENT {% s => append(s[0], {"ast": "Comment", "text": s[1]}) %}

@{%
function expand(arr) {
  if (arr == null || arr === undefined) {
    return []
  }
  if (arr.hasOwnProperty("length") && arr > 0) {
    return [ ...arr ]
  }
  return []
}

function append(arr, item) {
  var result = expand(arr)
  result.push(item)
  return result
}
%}

# Patterns for tokenization.  String literals and character classes may also
# get processed as token-specific matchers but they will already get recognized
# by the normal rule_body production definition.
production -> %WORD _ "::=" _ pattern_body {%
  s => ({ "ast": "EarleyRule", "name": s[0], "choices": [ s[4] ]})
%}

pattern_body -> %PATTERN {%
  s => ({ "ast": "Choice", "symbols": [{
    "ast": "PatternMatcher",
    "pattern": s[0],
    "arrange": { "ast": "ItemProjection", "ref": "0" }
    }]
  })
%}
pattern_body -> %PATTERN _ "=>" _ postproc_ref {%
  s => ({ "ast": "Choice", "symbols": [{
    "ast": "PatternMatcher",
    "pattern": s[0],
    "arrange": s[4]
    }]
  })
%}

# Production rules are a sequence of one or more choices.
production -> %WORD _ "::=" _ rule_body {%
  s => ({ "ast": "EarleyRule", "name": s[0], "choices": s[4] })
%}

# Choices are separated by the pipe `|` character.
rule_body -> parse_choice
  | rule_body _ "|" _ parse_choice {% s => [...s[0], s[4]] %}

# Each choice may have a post-processing structural definition,
parse_choice -> rule_expr _ "=>" _ postproc_atom {%
  s => ({ "ast": "Choice", "tokens": s[0], "arrange": s[4] })
%}
# selecting all by default.
parse_choice -> rule_expr {%
  s => ({ "ast": "Choice", "tokens": s[0], 
    "arrange": { "ast": "ItemProjection", "ref": "0" }
  })
%}

# Rules are concatenated atomic values (matchers and sub-expressions).
rule_expr -> rule_atom
  | rule_expr _ rule_atom {%
      s => [ ...s[0], s[2] ]
  %}

rule_atom
  -> rule_matcher {% s => s[0] %}
	| rule_matcher kleene_mod {%
      s => ({ ...s[0], "kleene": s[1] })
  %}
	| "(" _ rule_body _ ")" {%
      s => ({ "ast": "Expr", "tokens": s[2] })
  %}
	| "(" _ rule_body _ ")" _ kleene_mod {%
      s => ({ "ast": "Expr", "tokens": s[2], "kleene": s[6] })
  %}
	| "[" _ rule_body _ "]" {%
      s => ({ "ast": "Expr", "tokens": s[2], "kleene": "?" })
  %}
	| "{" _ rule_body _ "}" {%
      s => ({ "ast": "Expr", "tokens": s[2], "kleene": "*" })
  %}

rule_matcher
  -> %WORD     {% s => ({
      "ast": "RuleMatcher",
      "name": s[0]
  }) %}
  | %STRING    {% s => ({
      "ast": "LiteralMatcher",
      "image": s[0]
  }) %}
  | %CHARCLASS {% s => ({
      "ast": "PatternMatcher",
      "pattern": s[0]
  }) %}

kleene_mod -> [?*+] {% id %}

# Post-processing values at the top level may be a reference
postproc_atom ->
    postproc_prop   {% id %}
  | postproc_ref    {% id %}
  | postproc_list   {% id %}
  | postproc_record {% id %}

postproc_ref -> "\\" %NUMBER {%
  s => ({ "ast": "ItemProjection", "ref": s[1] })
%}

# Property getter for an object at the indicated reference or prop chain.
postproc_prop -> postproc_ref "." %WORD {%
  s => ({
    "ast": "PropertyGetter",
    "ref": s[0],
    "name": s[2]
  })
%}
postproc_prop -> postproc_prop "." %WORD {%
  s => ({
    "ast": "PropertyGetter",
    "ref": s[0],
    "name": s[2]
  })
%}
# Property getter for a list at the indicated reference or prop chain.
postproc_prop -> postproc_ref "." %NUMBER {%
  s => ({
    "ast": "ElementGetter",
    "ref": s[0],
    "index": s[2]
  })
%}
postproc_prop -> postproc_prop "." %NUMBER {%
  s => ({
    "ast": "ElementGetter",
    "ref": s[0],
    "index": s[2]
  })
%}

# Matches may be selected and projected into a list.
postproc_list -> "[" _ postproc_items _ "]" {% s => ({ "proj_list": s[2] }) %}

# There must be at least one element in the list.
postproc_items -> postproc_item
postproc_items -> postproc_items _ "," _ postproc_items {%
  s => [ ...s[0], s[4] ]
%}

postproc_item ->
    postproc_prop      {% id %}
  | postproc_list      {% id %}
  | postproc_record    {% id %}
  | postproc_ref "..." {% s => ({ "ast": "ExpandList", "ref": s[0].ref }) %}
  | postproc_ref       {% id %}


postproc_record -> %WORD "{" _ postproc_keyvals _ ",":? _ "}" {%
  s => ({ "ast": "RecordProjection", "name": s[0], "attrs": s[3] })
%}

postproc_keyvals -> postproc_kv
postproc_keyvals -> postproc_keyvals _ "," _ postproc_kv {%
  s => [ ...s[0], s[4] ]
%}

postproc_kv -> kv_key _ ":" _ kv_value {%
  s => ({ "ast": "KeyValue", "key": s[0], "value": s[4] })
%}
postproc_kv -> postproc_ref "..." {%
  s => ({ "ast": "ExpandRecord", "ref": s[0].ref })
%}

kv_key -> %WORD     {% id %}
  | %STRING         {% id %}
kv_value -> %STRING {% id %}
  | postproc_atom   {% id %}
