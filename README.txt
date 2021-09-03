Detailed Description:
    Prolognite is a singleplayer strategy digital board game with AI written in the Prolog NLP programming language. This game is a variation of battleships with armies. The objective is to overwhelm the enemy with the value of army strength according to their and your formation. There are obtacles that have to be avoided while moving your armies on the board. The person with the most armies wins the game.

* Game Mechanics *
PROLOGNITE is a two-player game played on an NN (e.g. 55) board. Both players (white and black) have in their disposal at the beginning of the game N (e.g. five) armies each with a value from 1 to N.

When the game starts, the board is initialized randomly with N (e.g. five) obstacles. After this, the game consists of two phases: Deployment and Destruction. In each phase the players play interchangeably.

In every round of the Deployment phase, each player deploys an army i.e. they select one of their available armies and place it on one available position on the board. The phase is completed when all armies have been deployed.

In every round of the Destruction phase, each player chooses to destroy:
    - Either one obstacle
    - Or one of the opponent’s armies.

An obstacle can be destroyed by an army if and only if:
    - The army is positioned in the same row or in the same column as the obstacle; and
    - There isn’t anything else (obstacle or army) in between them.
    An army can be destroyed by the opponent if and only if:
    - It is threatened by one or more armies of the opponent. An army is threatened if the opponent has one army (on the same row or in the same column) or more armies (all in the same row or in the same column)
    whose sum of values is greater than the value of the army being threatened;
    - There isn’t anything else (obstacle or army) in between the threatening and threatened armies.

If during the Destruction phase one player has nothing left to destroy, the other player continues to play until they also have nothing left to destroy. So the game ends when there is nothing else to be destroyed by any of the players.

The winner is the player whose sum of armies that left on the board is greater than the other’s. Otherwise, it’s a draw.

The following two figures depict an instance of the game for N=5, i.e. a 5x5 board, 5 obstacles and 5 armies, numbered 1-5, for each player.

Destruction:
Note that the X represents the obstacles and opponent’s armies that are being threatened.

Aims:
    - understand the functionality of Prolog predicates and express it in natural language;
    - understand textual descriptions of predicates and design the corresponding Prolog programs;
    - implement recursive predicates on lists consisting of complex terms;
    - implement predicates exploiting the power of higher order built-in predicates;
    - utilise procedural abstraction to decompose a complex predicate description into simpler ones and
    synthesise complex predicates by reusing already defined built-in or user-defined predicates; and
    - develop correct and well-documented programs on specific problems, and test them.

How to run:
    - Use SWI-Prolog (https://www.swi-prolog.org/download/stable) and follow the instructions given from the CLI.