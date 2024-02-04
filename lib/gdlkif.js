// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }

import "astutil.js";


// Tokenizer definition provided via https://github.com/no-context/moo
const moo = require('moo')

let lexer = moo.compile({
  SPACE: {
    match: /\s+/,
    lineBreaks: true
  },
  COMMENT: {
    match: /;+([^\n]*)/,
    value: s => s.substring(1).trim()
  },
  '(': '(',
  ')': ')',
  L_INFER: '<=',
  '?': '?',
  NUMBER: {
    match: /(0|-?[1-9][0-9]*)/,
    value: s => Number(s)
  },
  STRING: {
    match: /"(?:\\["bfnrt\/\\]|\\u[a-fA-F0-9]{4}|[^"\\\n])*"/,
    value: s => JSON.parse(s).slice(1, -1)
  },
  IDENT: {
    match: /[a-zA-Z]+/,
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
  })},
})
var grammar = {
    Lexer: lexer,
    ParserRules: [
    {"name": "input", "symbols": ["_", "sentence+", "_"], "postprocess": id},
    {"name": "sentence+", "symbols": ["sentence"], "postprocess": d => [d[0]]},
    {"name": "sentence+", "symbols": ["sentence+", "_", "sentence"], "postprocess": d => [ ...d[0], d[2] ]},
    {"name": "sentence", "symbols": ["role_defn"], "postprocess": id},
    {"name": "sentence", "symbols": ["init_rule"], "postprocess": id},
    {"name": "sentence", "symbols": ["base_rule"], "postprocess": id},
    {"name": "sentence", "symbols": ["inference"], "postprocess": id},
    {"name": "sentence", "symbols": ["relation"], "postprocess": id},
    {"name": "inference$ebnf$1", "symbols": []},
    {"name": "inference$ebnf$1$subexpression$1", "symbols": ["__", "body_relation"]},
    {"name": "inference$ebnf$1", "symbols": ["inference$ebnf$1", "inference$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "inference", "symbols": [{"literal":"("}, "_", (lexer.has("L_INFER") ? {type: "L_INFER"} : L_INFER), "__", "head_relation", "inference$ebnf$1", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "infer",
          head: d[4],
          body: d[5],
          start: startOfToken(d[0]),
          end: end(d[7])
        })
        },
    {"name": "head_relation", "symbols": ["input_relation"], "postprocess": id},
    {"name": "head_relation", "symbols": ["next_relation"], "postprocess": id},
    {"name": "head_relation", "symbols": ["base_rule"], "postprocess": id},
    {"name": "head_relation", "symbols": ["relation+"], "postprocess": id},
    {"name": "body_relation", "symbols": ["does_relation"], "postprocess": id},
    {"name": "body_relation", "symbols": ["role_reln"], "postprocess": id},
    {"name": "body_relation", "symbols": ["relation+"], "postprocess": id},
    {"name": "relation+", "symbols": ["relation"], "postprocess": id},
    {"name": "relation+", "symbols": ["relation+", "_", "relation"], "postprocess":  
        d => [...d[0], d[2]]
        },
    {"name": "relation", "symbols": ["logical_relation"], "postprocess": id},
    {"name": "relation", "symbols": ["legality_rule"], "postprocess": id},
    {"name": "relation", "symbols": ["goal_function"], "postprocess": id},
    {"name": "relation", "symbols": ["ground_term"], "postprocess": id},
    {"name": "role_defn", "symbols": [{"literal":"("}, "_", {"literal":"role"}, "__", "name", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "role_def",
          name: d[4],
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "role_reln", "symbols": [{"literal":"("}, "_", {"literal":"role"}, "__", "var", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "role_rel",
          name: roleName(d[4]),
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "base_rule", "symbols": [{"literal":"("}, "_", {"literal":"base"}, "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "base",
          body: d[4],
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "init_rule", "symbols": [{"literal":"("}, "_", {"literal":"init"}, "__", "ground_relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "init",
          body: d[4],
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "input_relation", "symbols": [{"literal":"("}, "_", {"literal":"input"}, "__", "var_or_name", "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "input",
          role: roleName(d[4]),
          action: d[6],
          start: start(d[0]),
          end: end(d[8])
        })
        },
    {"name": "legality_rule", "symbols": [{"literal":"("}, "_", {"literal":"legal"}, "__", "var_or_name", "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "legal",
          role: roleName(d[4]),
          action: d[6],
          start: start(d[0]),
          end: end(d[8])
        })
        },
    {"name": "does_relation", "symbols": [{"literal":"("}, "_", {"literal":"does"}, "__", "var_or_name", "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "does",
          role: roleName(d[4]),
          action: d[6],
          start: start(d[0]),
          end: end(d[8])
        })
        },
    {"name": "next_relation", "symbols": [{"literal":"("}, "_", {"literal":"next"}, "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "next",
          body: d[4],
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "logical_relation$ebnf$1$subexpression$1", "symbols": ["relation", "_"]},
    {"name": "logical_relation$ebnf$1", "symbols": ["logical_relation$ebnf$1$subexpression$1"]},
    {"name": "logical_relation$ebnf$1$subexpression$2", "symbols": ["relation", "_"]},
    {"name": "logical_relation$ebnf$1", "symbols": ["logical_relation$ebnf$1", "logical_relation$ebnf$1$subexpression$2"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "logical_relation", "symbols": [{"literal":"("}, "_", "logical_nary_op", "__", "relation", "_", "logical_relation$ebnf$1", {"literal":")"}], "postprocess": 
        d => ({
          type: d[2],
          body: d[4],
          start: start(d[0]),
          end: end(d[8])
        })
        },
    {"name": "logical_relation", "symbols": [{"literal":"("}, "_", "logical_unary_op", "__", "relation", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: d[2],
          body: d[4],
          start: start(d[0]),
          end: end(d[6])
        })
        },
    {"name": "logical_nary_op$subexpression$1", "symbols": [{"literal":"distinct"}]},
    {"name": "logical_nary_op$subexpression$1", "symbols": [{"literal":"or"}]},
    {"name": "logical_nary_op$subexpression$1", "symbols": [{"literal":"and"}]},
    {"name": "logical_nary_op", "symbols": ["logical_nary_op$subexpression$1"], "postprocess": id},
    {"name": "logical_unary_op$subexpression$1", "symbols": [{"literal":"true"}]},
    {"name": "logical_unary_op$subexpression$1", "symbols": [{"literal":"not"}]},
    {"name": "logical_unary_op", "symbols": ["logical_unary_op$subexpression$1"], "postprocess": id},
    {"name": "terminal", "symbols": [{"literal":"terminal"}], "postprocess": id},
    {"name": "goal_function", "symbols": [{"literal":"("}, "_", {"literal":"goal"}, "__", "var_or_name", "__", (lexer.has("NUMBER") ? {type: "NUMBER"} : NUMBER), "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "goal",
          role: roleName(d[4]),
          value: d[6],
          start: start(d[0]),
          end: end(d[8])
        })
        },
    {"name": "ground_relation$ebnf$1$subexpression$1", "symbols": ["__", "ground_term+"], "postprocess": d => d[1]},
    {"name": "ground_relation$ebnf$1", "symbols": ["ground_relation$ebnf$1$subexpression$1"], "postprocess": id},
    {"name": "ground_relation$ebnf$1", "symbols": [], "postprocess": function(d) {return null;}},
    {"name": "ground_relation", "symbols": [{"literal":"("}, "_", "name", "ground_relation$ebnf$1", "_", {"literal":")"}], "postprocess": 
        d => ({
          type: "relation",
          grounded: true,
          relation: d[2],
          parameters: d[3],
          start: start(d[0]),
          end: end(d[5])
        })
        },
    {"name": "ground_term+", "symbols": ["ground_term+", "__", "ground_term"], "postprocess": 
        d => [...d[0], d[2]]
            },
    {"name": "ground_term+", "symbols": ["ground_term", "_"], "postprocess": d => [d[1]]},
    {"name": "ground_term", "symbols": [(lexer.has("NUMBER") ? {type: "NUMBER"} : NUMBER)], "postprocess": id},
    {"name": "ground_term", "symbols": ["name"], "postprocess": id},
    {"name": "ground_term", "symbols": ["terminal"], "postprocess": id},
    {"name": "ground_term", "symbols": ["ground_relation"], "postprocess": id},
    {"name": "var", "symbols": [{"literal":"?"}, "name"], "postprocess": 
        d => ({
          type: "variable",
          name: d[1],
          start: start(d[0]),
          end: d[1].end
        })
        },
    {"name": "var_or_name", "symbols": ["var"], "postprocess": id},
    {"name": "var_or_name", "symbols": ["name"], "postprocess": id},
    {"name": "name", "symbols": [(lexer.has("IDENT") ? {type: "IDENT"} : IDENT)], "postprocess": 
        d => newName(d[0].value, start(d[0]), end(d[0]))
        },
    {"name": "name", "symbols": [(lexer.has("STRING") ? {type: "STRING"} : STRING)], "postprocess": 
        d => newName(d[0].value, start(d[0]), end(d[0]))
        },
    {"name": "_$ebnf$1", "symbols": [(lexer.has("SPACE") ? {type: "SPACE"} : SPACE)], "postprocess": id},
    {"name": "_$ebnf$1", "symbols": [], "postprocess": function(d) {return null;}},
    {"name": "_", "symbols": ["_$ebnf$1"], "postprocess": d => null},
    {"name": "__", "symbols": [(lexer.has("SPACE") ? {type: "SPACE"} : SPACE)], "postprocess": d => null}
]
  , ParserStart: "input"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.grammar = grammar;
}
})();
