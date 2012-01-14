factor(T, A, D) :-
    eat('(', A, B), expr(T, B, C), eat(')', C, D).
