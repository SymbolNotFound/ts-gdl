# ts-gdl v0.1

TypeScript implementation of GDL (Games Description Language) 
in both KIF (Knowledge Interchange Format) and HRF (Human-Readable
Format).  The former is based on s-expressions, with `?` prefixed
to any symbol intended as a variable.  The latter looks
more like Prolog or Datalog with the `:-` arrow and uppercase letters
indicating variables.

## Features

[ ] Parses GDL formatted as KIF
[x] Parses GDL formatted as HRF
[ ] Initializes database from GDL rulesheet
[ ] Infers available actions from current database
[ ] Updates database from (simultaneous) player actions
[ ] Evaluates database for whether play has terminated
[ ] Evaluates database for goal payout to players
[ ] Renders and simulates gameplay in a Vue component

This is still a work in progress, check back soon!

## Using as a Library

...


## Using as a Vue component

...


## Writing GDL games

see documentation (source can be found in `/docs`)

...

