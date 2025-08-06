---
title: Datalog and Relational Programming
---

# {{ $frontmatter.title }}

GDL (Game Description Language) is fundamentally a 
[datalog](https://wikipedia.org/wiki/Datalog) with some special relations
that provide the sequencing and state management of game playing.
Rather than model the state machine of games directly, as one might typically
do in a procedural language, GDL models the rules of which moves are allowed
(given the current game state, as represented by "relations").

This has multiple benefits, and doesn't prevent clients from building a state
machine that simulates following the rules.  What it provides most of all is a
modularity that would be difficult to achieve with procedural or functional
languages.

This article lays the groundwork for Datalog, its syntax and some terminology
from Automated Reasoning.  If you're already familiar with Logic Programming
you can skim or go directly to the next article.  If this is your first
encounter with logic programming languages, it is different enough from what
is popularly considered programming that non-programmers and experienced
programmers are on equal footing when learning it.

[toc]
