/* database.pp */

uses(mike, compiler, sun) :- .


needs(compiler, 128) :- .

greater(X, Y) :- plus(Y, W, X).


/* The queries from Chapter 2, with small changes for picoProlog syntax: */

answer(PROGRAM, MEMORY) :-
    uses(PERSON, PROGRAM, sun),
    needs(PROGRAM, MEMORY).

