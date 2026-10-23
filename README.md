Portal Chess
A proposed chess variant featuring dynamic portals

Project status: Concept proposal — seeking programmers, testers, and collaborators
Proposed implementation language: MATLAB
Project type: Experimental chess variant
Repository name: portal-chess
Table of Contents
- Introduction
- Objectives
- Standard Chess Components
- Portal Generation and Placement
- Standard Piece Movement
- Portal Activation and Teleportation
- King Safety and Check
- Game Endings and Additional Rules
- Suggested Turn Sequence
- Questions for Community Review
- Development Roadmap
- How to Contribute
- Declaration of OpenAI Use
- Project Status and Disclaimer
- Conclusion
  Introduction
  Portal Chess is a proposed chess variant that retains the traditional 8×8 chessboard and standard chess pieces while introducing two dynamically relocating portals. These portals create an additional tactical possibility: a piece that lands on a portal square may teleport to another unoccupied square on the board.
The objective is to explore whether dynamic teleportation can encourage creative combinations, unexpected positional changes, and new tactical decisions while preserving the fundamental objective of chess: checkmate the opponent's king.

This repository presents the proposed rules and invites programmers, chess enthusiasts, researchers, and game developers to implement, evaluate, test, and improve the concept.

Important: The rules and mechanics described here are a proposal. A MATLAB prototype may have been drafted with AI assistance, but it has not been verified through execution in MATLAB. The game should not be considered fully implemented, tested, or competitively balanced.
Objectives
Portal Chess aims to:
1. Introduce a dynamic spatial mechanic into traditional chess.
2. Encourage players to consider alternative tactical and positional possibilities.
3. Preserve the recognizable movement rules of standard chess pieces.
4. Maintain king safety, check, checkmate, and the fundamental objective of chess.
5. Provide a programming challenge involving legal moves, teleportation, changing board states, and game-state validation.
6. Encourage collaborative development of a playable implementation and, potentially, an AI opponent.
   Standard Chess Components
   Portal Chess uses the following components:
   - An 8×8 chessboard.
   - Six standard chess piece types: king, queen, rook, bishop, knight, and pawn.
   - Two opposing players, White and Black.
   - Standard chess piece movement and capture rules, subject to the additional portal mechanic.
   - Two portals positioned on the board.
     The initial piece arrangement follows standard chess unless a future implementation introduces an explicitly documented alternative.
     Portal Generation and Placement
     Number of portals
     The game uses exactly two portals at any given time.
     Initial generation
     At the beginning of a game, the two portals are placed on randomly selected board squares in opposite halves of the board.
For the initial implementation, the portals should be placed on distinct squares that are not occupied by chess pieces when generated.

The implementation should define the board's two halves consistently and document the random-generation method.
Portal relocation
The two portal locations change after every five individual player moves, also called plies.

A ply is one move made by either White or Black. Therefore, five plies do not necessarily correspond to five complete turns by both players.

For example:
- Ply 1: White moves.
- Ply 2: Black moves.
- Ply 3: White moves.
- Ply 4: Black moves.
- Ply 5: White moves.
  After the fifth ply has been completed, the portals are relocated before the next player's move.
The same cycle repeats throughout the game.

Portal relocation must not count as an additional chess move.
Relocation constraints
When relocating the portals:
- The two portals must occupy distinct squares.
- Their placement must satisfy the opposite-halves requirement.
- A newly generated portal should not be placed on a square occupied by a chess piece at the time of relocation.
- The relocation procedure must not move, capture, or otherwise alter any chess piece.
  If a relocation attempt produces an invalid placement, the program should generate another valid placement.
  Standard Piece Movement
  All chess pieces retain their ordinary movement patterns.
- King: Moves one square in any direction.
- Queen: Moves any number of unobstructed squares horizontally, vertically, or diagonally.
- Rook: Moves any number of unobstructed squares horizontally or vertically.
- Bishop: Moves any number of unobstructed squares diagonally.
- Knight: Moves in an L-shaped pattern and may jump over intervening pieces.
- Pawn: Moves and captures according to standard pawn rules, including its initial two-square advance when legal.
Portal-specific pawn restriction (proposed rule): A pawn may teleport only to a square within its own side's first four ranks, measured from that pawn's starting side of the board:
- White pawns may teleport only to ranks 2, 3, or 4.
- Black pawns may teleport only to ranks 5, 6, or 7.
This restriction applies only to the teleport destination. It does not change ordinary pawn movement, captures, or the normal rules for reaching a portal square. If a pawn lands on a portal square but has no permitted empty destination, it may remain on the portal square if the resulting position is otherwise legal. The restriction does not apply to other piece types.

A piece must first make a legal chess move to reach a portal square. Teleportation does not permit a piece to disregard its normal movement rules when entering the portal.

Ordinary captures remain possible. A piece may capture an opposing piece by making a legal chess move onto its occupied square, including a portal square if the position permits it.
Portal Activation and Teleportation
Activation condition
A portal becomes available for use when a chess piece completes a legal move and lands on a square occupied by one of the two portals.

A piece does not activate a portal merely because it passes over or moves adjacent to its square.
Optional teleportation
After landing on a portal square, the player may choose between:
1. Remain: Keep the piece on the portal square.
2. Teleport: Move the piece to another eligible, unoccupied square on the board.
   Teleportation is optional. Landing on a portal does not automatically force a piece to teleport.
   Destination requirements
   A teleportation destination must be empty at the time the destination is selected.
The destination must also satisfy any piece-specific restriction. In particular, a pawn may teleport only to White ranks 2–4 or Black ranks 5–7, as applicable. This restriction is measured using the board's standard rank numbering (White's home rank is rank 1; Black's home rank is rank 8).

Consequently:
- A piece cannot teleport directly onto an opposing piece to capture it.
- A piece cannot teleport onto a friendly piece.
- A non-pawn may select any otherwise eligible empty square, regardless of its distance from the portal.
- A pawn may select any empty square within its permitted destination ranks, regardless of its distance from the portal.
- Teleportation does not count as a separate turn or ply.
  The destination selection is an additional action associated with the current move, not an independent move that allows another piece to move.
  Capture restrictions
  Teleportation itself cannot capture a piece.
Captures must occur through ordinary legal chess movement. A piece that captures an opponent through a normal move may subsequently use a portal if the resulting position satisfies the portal rules.
No repeated teleportation during one move
For the proposed initial rules, a piece may teleport at most once during a single move. Arriving at another portal square as a teleportation destination does not trigger a second teleport during that same move.

This restriction avoids an ambiguous chain of teleportation and provides a clear rule for programmers to implement.
King Safety and Check
King safety is a fundamental requirement of Portal Chess.

A move is legal only if the player's king is not left in check after the complete move, including any optional teleportation.
Moving the king
A king may not remain on or teleport to a square where it would be in check.

A teleportation destination must therefore be evaluated for king safety before the move is accepted.
Moving other pieces
A player cannot use a portal to make a move that leaves their own king in check.

If teleportation would expose the player's king to check, that teleportation choice must be rejected. If remaining on the portal square is legal, the player may choose that alternative.
Giving check
A player may give check through an ordinary legal move or by teleporting a piece to a position from which it legally attacks the opposing king.

The game must calculate attacks using the final board position and the ordinary movement and attack rules, rather than assuming that a teleportation automatically constitutes a check.
Checkmate
Checkmate occurs when a king is in check and its player has no legal response.

The implementation must consider all legal responses, including ordinary moves and permitted portal choices.
Stalemate
Stalemate occurs when a player is not in check but has no legal move.

The program must account for the availability of portal-related choices when determining whether a legal move exists.
Game Endings and Additional Rules
The primary objective remains checkmate.

The implementation should also support, or clearly document the status of, standard chess endings and special rules.

For the initial version, developers should explicitly determine and test:
- Castling and whether it follows standard chess restrictions.
- En passant and its interaction with the portal mechanic.
- Pawn promotion, including the choice of promoted piece.
- Stalemate.
- Draws by repetition and the fifty-move rule.
- Resignation and other agreed game-ending conditions.
  Unless a special rule is deliberately changed and documented, the default intention is to preserve standard chess rules wherever they do not conflict with the portal mechanic.
A future implementation should state which of these rules are fully supported rather than implying that they work automatically.
Suggested Turn Sequence
A normal turn should follow this general sequence:
1. Determine whose turn it is.
2. Generate and display the legal chess moves.
3. The player selects a legal move.
4. Apply the normal move and any ordinary capture.
5. If the piece lands on a portal square, offer the player the option to remain or teleport.
6. If teleportation is selected, verify that the destination is empty and that the resulting position is legal.
7. Finalize the complete move.
8. Update the move counter.
9. If the fifth ply in the current relocation cycle has been completed, relocate both portals according to the placement rules.
10. Evaluate check, checkmate, stalemate, and other relevant game conditions.
11. Begin the next player's turn if the game has not ended.
    Developers should document and test the exact ordering of game-state validation and portal relocation, particularly where relocation affects available moves or king safety.
    Questions for Community Review
    The following questions are intentionally open to technical and gameplay discussion:
12. Is relocation after every five plies the most suitable interval?
13. Should portal positions be generated entirely randomly or according to a constrained algorithm?
14. How should portal relocation be handled if a particular arrangement creates unusual tactical consequences?
15. What is the best way to validate king safety when a move has both a normal-move stage and an optional teleportation stage?
16. Should castling and en passant be included in the first playable version?
17. Would the variant benefit from a dedicated AI opponent?
18. Which time controls would make the game enjoyable without creating excessive decision overhead?
19. How can the rules be tested for exploits, repetition, balance, and unintended behavior?
    These questions are intended to help contributors improve the implementation and the rules through transparent discussion and testing.
    Suggested Development Roadmap
    Rules and design
    - Review the written rules.
    - Identify ambiguous situations.
    - Establish a formal definition of legal moves and portal relocation.
    - Document any agreed revisions.
      Playable prototype
    - Implement the chessboard and standard pieces.
    - Implement ordinary legal moves and captures.
    - Implement portal generation and relocation.
    - Implement optional teleportation to eligible empty squares.
    - Validate king safety and game-ending conditions.
      Testing and validation
    - Create unit tests for movement and captures.
    - Test portal activation and relocation timing.
    - Test illegal teleportation destinations, including pawn destinations outside the permitted ranks.
    - Test that White pawns can teleport only to ranks 2–4 and Black pawns only to ranks 5–7.
    - Test what happens when a pawn lands on a portal but has no permitted empty teleport destination.
    - Compare restricted and unrestricted pawn teleportation through playtesting and recorded game outcomes.
    - Test checks, checkmate, and stalemate.
    - Compare game-state results against independently reviewed test positions.
    - Record known bugs and unsupported rules.
      Improvements
    - Improve the user interface.
    - Add move history and notation.
    - Add AI opponents.
    - Explore online multiplayer and competitive play.
    - Conduct playtesting and collect feedback.
      These are proposed development stages, not claims that the features have already been implemented.
      How to Contribute
      Contributions are welcome from MATLAB programmers, chess-engine developers, game designers, testers, and interested chess players.
Potential contributions include:
- Implementing the rules.
- Reviewing the specification for ambiguities.
- Finding edge cases and possible exploits.
- Developing automated tests.
- Improving the interface.
- Building an AI opponent.
- Comparing the concept with existing chess variants.
  Please describe the feature or issue, explain the expected behavior, and include a reproducible test case when reporting a bug.
  Declaration of OpenAI Use
  OpenAI's ChatGPT was used as an AI-assisted tool during the preparation and organization of this project documentation and the articulation of the proposed game mechanics.
The project creator is responsible for reviewing the rules, determining the intended mechanics, and deciding which proposals to publish. AI assistance should not be interpreted as independent verification of the game's originality, correctness, fairness, or technical feasibility.

Any prototype code drafted with AI assistance must be independently reviewed and tested by its implementers before it is considered reliable.

OpenAI and ChatGPT are not presented as sponsors, developers, endorsers, or validators of Portal Chess. This declaration is intended to provide transparency about the use of AI assistance.
Project Status and Disclaimer
Portal Chess is an experimental concept offered for community discussion and collaborative development.

The published rules describe intended behavior; they do not establish that a complete, bug-free implementation exists. The initial code, if supplied, should be treated as unverified until it has been executed and tested in the intended environment.

The project welcomes constructive criticism, alternative implementations, and evidence-based revisions to the proposed rules.
Conclusion
Portal Chess explores the possibility of introducing dynamic portals into a familiar chess environment. Its central mechanic combines conventional chess movement with optional teleportation and periodic portal relocation.

The purpose of this repository is to make the proposal available for technical review, implementation, and experimentation. Community feedback will help determine whether the mechanic produces a coherent, enjoyable, and strategically interesting chess variant.

The next step is collaborative development and testing.

