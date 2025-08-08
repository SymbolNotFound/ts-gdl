# ts-gdl v0.1

TypeScript implementation of GDL (Games Description Language) 
in both KIF (Knowledge Interchange Format) and HRF (Human-Readable
Format).  The former is based on s-expressions, with `?` prefixed
to any symbol intended as a variable.  The latter looks
more like Prolog or Datalog with the `:-` arrow and uppercase letters
indicating variables.

The parser for the HRF variant has some additional syntax sugar, including
ranges (`1..3`), foreach (`X <- 1..10`) and implicit turn sequencing
(`turn`).

Although numbers and their successors are provided in ranges, this isn't 
extended to Constraint Logic Programming over integers or finite domains, as
that would put it significantly beyond the scope of a datalog.  For that
functionality, I am building GEL (Goal Expression Language) which is a superset
of GDL-II and will most likely reuse significant portions of this project.
Stay tuned for more!

## Features

[x] Parses GDL formatted as KIF
[x] Parses GDL formatted as HRF
[ ] Initializes database from GDL rulesheet
[ ] Infers available actions from current database
[ ] Updates database from simultaneous player actions
[ ] Evaluates database for whether play has terminated
[ ] Evaluates database for goal payout to players
[ ] Renders and simulates gameplay in a Vue component

## Using the parser to produce ASTs

...


## Using the library to host and simulate games

...


## Writing GDL games

See [documentation](https://ts-gdl.kevindamm.com/)
(source can be found in `/docs`)

...

