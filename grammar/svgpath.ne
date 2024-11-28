# Copyright (c) 2024 Symbol Not Found L.L.C.
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
# svgpath.ne: grammar definition for "d" attribute of SVG <path>

@{%
// Tokenizer via https://github.com/no-context/moo
const moo = require('moo');

let lexer = moo.compile({
  SPACE: {
    match: /\s+/,
    lineBreaks: true
  },
  ",": ",",
  "+": "+",
  "-": "-",
  NUMBER: {
    match: /(0|[+-]?[1-9][0-9]*)([.][0-9]*)?/,
    value: s => Number(s)
  },
  FLAG: /0|1/,
  IDENT: {
    match: /[a-zA-Z]/,
    type: moo.keywords({
      KEYWORD: [
        'M', 'Z', 'L', 'H', 'V', 'C', 'S', 'Q', 'T', 'A',
        'm', 'z', 'l', 'h', 'v', 'c', 's', 'q', 't', 'a'
      ]
    })
  }
})
%}
@lexer lexer

svg_path -> %SPACE:? moveto:? (moveto drawto_cmd:*):?

drawto_cmd ->
    moveto
  | closepath
  | lineto
  | horizontal_lineto
  | vertical_lineto
  | curveto
  | smooth_curveto
  | quadratic_bezier_curveto
  | smooth_quadratic_bezier_curveto
  | elliptical_arc

moveto -> ("M" | "m") %SPACE:? coordinate_pair_sequence

closepath -> "Z" | "z"

lineto -> ("L" | "l") %SPACE:? coordinate_pair_sequence

horizontal_lineto -> ("H" | "h") %SPACE:? coordinate_sequence

vertical_lineto -> ("V" | "v") %SPACE:? coordinate_sequence

curveto -> ("C" | "c") %SPACE:? curveto_coordinate_sequence

curveto_coordinate_sequence -> coordinate_pair_triplet
curveto_coordinate_sequence -> curveto_coordinate_sequence comma_space:? coordinate_pair_triplet

smooth_curveto -> ("S" | "s") %SPACE:? smooth_curveto_coordinates

smooth_curveto_coordinates -> coordinate_pair_doublet
smooth_curveto_coordinates -> smooth_curveto_coordinates comma_space:? coordinate_pair_doublet

quadratic_bezier_curveto -> ("Q" | "q") %SPACE:? quadratic_bezier_curveto_coordinates

quadratic_bezier_curveto_coordinates -> coordinate_pair_doublet
quadratic_bezier_curveto_coordinates -> quadratic_bezier_curveto_coordinates comma_space:? coordinate_pair_doublet

smooth_quadratic_bezier_curveto -> ("T" | "t") %SPACE:? coordinate_pair_sequence

elliptical_arc -> ("A" | "a") %SPACE:? elliptical_arc_argument_sequence

elliptical_arc_argument_sequence -> elliptical_arc_argument
elliptical_arc_argument_sequence -> elliptical_arc_argument_sequence comma_space:? elliptical_arc_argument

elliptical_arc_argument -> %NUMBER comma_space:? %NUMBER comma_space:? %NUMBER comma_space:?
elliptical_arc_argument -> %FLAG comma_space:? %FLAG comma_space:? coordinate_pair

coordinate_pair_doublet -> coordinate_pair comma_space:? coordinate_pair

coordinate_pair_triplet -> coordinate_pair comma_space:? coordinate_pair comma_space:? coordinate_pair

coordinate_pair_sequence -> coordinate_pair
coordinate_pair_sequence -> coordinate_pair_sequence comma_space:? coordinate_pair

coordinate_sequence -> coordinate
coordinate_sequence -> coordinate_sequence comma_space:? coordinate

coordinate_pair -> coordinate
coordinate_pair -> coordinate_pair comma_space:? coordinate

coordinate -> sign:? %NUMBER

comma_space -> %SPACE ",":? %SPACE:?
comma_space -> "," %SPACE:?