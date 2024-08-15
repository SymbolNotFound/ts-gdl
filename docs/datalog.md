---
title: Datalog - Logic Programming
author: Kevin Damm
---

# Logic Programming

The process of applying mathematical logic to computation as a model composed
of declarative statements is
[Logic Programming](https://en.wikipedia.org/wiki/Logic_programming).  These
declarative statements are "rules" and represent knowledge about the domain.
They may be relations, (constant) objects, or functions.  They may contain
additional relations as parameters or variables which, after unifying with other
rules, represent additional rules or relations.

Because these rules are declarative, not procedural, the process of interpreting
them is up to the engine doing the goal search.  There are three distinct ways
to do this, each belonging to a family of logic programming languages.

 - **Prolog**: probably the most well-known of the logic programming families,
   it performs a top-down search, assisted with backtracking and shaped by `!`,
   a "cut" operator that informs the search when not to backtrack further. 
   It is quite popular for use in theorem-proving problems.
   
 - **datalog**: popular in the study of relational databases and more generally
   in data integration and program analysis, it is characterized by a bottom-up
   search instead of Prolog's top-down approach.  This means that some problems
   which will lead to an infinite loop in Prolog are actually solvable with
   datalog, but problems having negated clauses in them can pose a challenge.

 - **ASP**: Answer Set Programming is based on the "stable model" semantics of
   logic programming and many answer set solvers are an enhancement of the DPLL
   algorithm (originally intended for solving CNF-SAT, the satisfiability of
   propositional logic in conjunctive normal form).  It will always terminate
   (unlike Prolog) and is usually applied to difficult (NP-Hard) search problems.

The following will focus on datalog because it's the language family that GDL
was modeled on, but the overall process of *unification* which the majority of
this essay is focused on, has the same semantics across the languages.


## Relations

...TODO


## Goals

...TODO


## Variables

...TODO


## Unification

...TODO

### Vars with Anything

...TODO


### Relations with Relations

...TODO


### Clauses with Clauses

...TODO


### Constant with Itself

...TODO


## Data Types

...TODO


## Knowledge Base

...TODO


## Goal Proving

...TODO

