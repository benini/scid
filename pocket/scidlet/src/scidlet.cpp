//////////////////////////////////////////////////////////////////////
//
//  FILE:       scidlet.cpp
//              Scidlet, a WinBoard chess engine
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.4
//
//  Notice:     Copyright (c) 2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

// This program is a WinBoard-compatible wrapper for the simple
// chess engine built into Scid.

#include "engine.h"

#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifndef WIN32
#  include <unistd.h>
#endif

#ifdef WIN32
#  define WIN32_LEAN_AND_MEAN 1
#  include <windows.h>
#  undef WIN32_LEAN_AND_MEAN
#endif

#include "ipc.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// unfinishedCommand
//    Stores a command input line not yet processed.
//
static char unfinishedCommand[512] = {0};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// timeControlT
//   Used to keep track of time conrtol information.
//
struct timeControlT {
    uint movesPerControl;
    uint minutesPerControl;
    uint centiSecondsLeft;
    uint oppCentiSecondsLeft;
    uint incrementSeconds;
    bool fixedTimeControl;
};

enum stateT {
    waiting, thinking, pondering, playing
};

struct modeT {
    bool force;       // Force mode, do not think or ponder.
    bool ponder;      // Ponder a reply during opponent move.
    bool analyze;     // Analyze mode, not implemented yet.
    stateT state;     // Current engine state.
    bool drawOffered; // Opponent has offered a draw since our last move.
    uint drawnScores; // Number of successive drawn scores.
};

struct ponderT {
    simpleMoveT move;   // Ponder move, best expected opponent move.
    simpleMoveT reply;  // Best move in reply to the ponder move.
    int score;          // Score for the reply to the ponder move.
    bool guessed;       // True if the opponent made the ponder move.
};

timeControlT tc;
modeT mode;
ponderT ponder;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setSearchTime
//  Computes and sets the amount of time (in milliseconds) to spend on
//  the next move.
void
setSearchTime (Engine * engine)
{
    int msLeft = tc.centiSecondsLeft * 10;
    int msThisMove = msLeft;

    if (tc.fixedTimeControl) {
        msThisMove = msLeft;
    } else if (tc.movesPerControl > 0) {
        // "XX moves in YY minutes" time control:
        int moveNumber = engine->GetPosition()->GetFullMoveCount();
        int movesToMake = tc.movesPerControl
                        - ((moveNumber-1) % tc.movesPerControl);

        // Keep a bit of time spare:
        if (msLeft < 4000) {
            msLeft /= 2;     // Under 4 seconds left? Just use half of it.
        } else if (msLeft < 20000) {
            msLeft -= 2000;  // Under 20 seconds left? Keep two seconds spare.
        } else {
            msLeft -= 5000;  // Keep five seconds spare.
        }

        msThisMove = msLeft / movesToMake;

    } else if (tc.incrementSeconds > 0) {
        // "Whole game in YY minutes" time control (with increment):

        int msInc = tc.incrementSeconds * 1000;

        // Subtract 0.5s for a safety buffer, but assume at least 0.1s:
        msLeft -= 500;
        if (msLeft < 100) { msLeft = 100; }

        // If time remaining is greater than the increment, use the
        // whole increment plus 1/30th of the remaining time.
        if (msLeft > msInc) {
            msThisMove = msLeft / 30 + msInc;
        } else {
            // Time on clock less is than the increment, so just use
            // some of what is available to try and gain time:
            msThisMove = msLeft * 8 / 10;
        }
    } else {
        // No increment; just use 1/30th of remaining time.
        msThisMove = msLeft / 30;
    }

    // Set the recommended, minimum and maximum search times:
    int msMin = msThisMove / 4;
    int msMax = msThisMove * 4;
    // Make sure the maximum search time will not lose on time:
    int msMaxLimit = tc.centiSecondsLeft * 10;
    if (msMax + 100 > msMaxLimit) { msMax = msMaxLimit - 100; }
    if (tc.fixedTimeControl) { msMin = msThisMove; msMax = msThisMove; }
    engine->SetSearchTime (msMin, msThisMove, msMax);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Configuration options:
//
struct configT {
    uint hashTableMB;     // Transposition table size in megabytes. -> kB
    uint pawnTableMB;     // Pawn hash table size in magabytes. -> kB
    bool pruning;         // Should the engine do futility pruning?
    bool resign;          // Should the engine consider resigning?
    bool draw;            // Should the engine offer and accept draws?
    bool log;             // Should the engine log output?
};

const configT defaultConfig = {
    64,    // hashTableMB -> kB
    16,     // pawnTableMB -> kB
    false, // pruning flag
    false,  // resign flag
    false,  // draw flag
    false  // log flag
};

configT config = defaultConfig;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// readInput
//   Read a line of input and process it.
//   Returns true if the engine should make a reply.
bool
readInput (Engine * engine)
{
    char newCommand [512];
    
    // Get the next command, checking if there is an unfinished one.
    if (unfinishedCommand[0] == 0) {
      get_msg( newCommand, 512 );
      if (newCommand[0] == '\0') return false;
//       printf("readInput get msg %s\n", newCommand);
    } else {
        strCopy (newCommand, unfinishedCommand);
        unfinishedCommand[0] = 0;
    }

    // Split the input line into a command and parameters:
    char command [512];
    strCopy (command, strTrimLeft (newCommand));
    const char * parameters = NULL;
    char * firstSpace = (char *) strFirstChar (command, ' ');
    if (firstSpace == NULL) {
        parameters = "";
    } else {
        *firstSpace = 0;    // Terminate the command string.
        parameters = firstSpace + 1;
    }

    // Ignore empty command lines
    if (strEqual (command, "")) { return false; }

    // set priority command
    if (strEqual (command, "setpriority")) {
      int prio = 252;
      if (sscanf (parameters, "%d", &prio) == 1) {
      }
      lowPrio(prio);
      return false;
    }
    
    // set hash command
    if (strEqual (command, "sethash")) {
      int hash = 0;
      if (sscanf (parameters, "%d", &hash) == 1) {
      }
      engine->SetHashTableKilobytes(hash);
      return false;
    }

    // set analyze mode
    // Set search time and depth to something very large and start search:
    if (strEqual (command, "analyze")) {
      tc.movesPerControl = 0;
      tc.minutesPerControl = 1000;
      tc.centiSecondsLeft = 1000 * 60 * 100;
      tc.incrementSeconds = 1000;
      tc.fixedTimeControl = false;
      engine->SetSearchDepth (50);
      engine->SetPostMode(true);
      setSearchTime(engine);
      mode.force = false;
      mode.analyze = true;
      return true;
    }
    
    // stop analyze mode
    if (strEqual (command, "exit")) {
      tc.movesPerControl = 0;
      tc.minutesPerControl = 0;
      tc.centiSecondsLeft = 0;
      tc.incrementSeconds = 0;
      engine->SetSearchDepth (0);
      setSearchTime(engine);
      mode.analyze = false;
//       engine->SetSearchTime(1);
      return true;
    }
    // When pondering, there are a few commands we can process on the
    // fly but the others must be handled outside of the search.
    if (mode.state == pondering) {
        if (strEqual (command, ".")) {
            // Ignore
        } else if (strEqual (command, "draw")) {
            mode.drawOffered = true;
        } else if (strEqual (command, "hint")) {
            // Ignore
        } else if (strEqual (command, "otim")) {
            int centiSecs;
            if (sscanf (parameters, "%d", &centiSecs) == 1) {
                tc.oppCentiSecondsLeft = centiSecs;
            }
        } else if (strEqual (command, "ping")) {
            send_msg ("pong %s\n", parameters);
        } else if (strEqual (command, "time")) {
            int centiSecs;
            if (sscanf (parameters, "%d", &centiSecs) == 1) {
                tc.centiSecondsLeft = centiSecs;
            }
        } else {
            // See if the pondered move was made and if so, convert
            // the pondering into a real search.
            Position * pos = engine->GetPosition();
            // Temporarily undo the ponder move to get the right
            // position for parsing this command as an opponent move:
            simpleMoveT * ponderMove = &(ponder.move);
            pos->UndoSimpleMove (ponderMove);
            simpleMoveT sm;
            errorT err = pos->ParseMove (&sm, newCommand);
            pos->DoSimpleMove (ponderMove);
            if (err == OK  &&  sm.from == ponder.move.from
                  &&  sm.to == ponder.move.to
                  &&  sm.promote == ponder.move.promote) {
                // The opponent made the ponder move.
                ponder.guessed = true;
                setSearchTime (engine);
                mode.state = thinking;
                return false;
            }

            // Stop pondering so we can process this command.
            strCopy (unfinishedCommand, newCommand);
            return true;
        }
        return false;
    }

    // We are not pondering but may be thinking. Most commands can
    // be processed while thinking, but a few require interruption
    // of the search.

    if (strEqual (command, "?")) {
        // Move now if thinking, otherwise ignore.
        if (mode.state == thinking) { return true; }
    } else if (strEqual (command, ".")) {
        // Ignore
    } else if (strEqual (command, "accepted")) {
        // Ignore protocol accepted/rejected
    } else if (strEqual (command, "bk")) {
        // XBoard protocol wants indented text terminated by a blank line:
        send_msg ("   No book information.\n\n");
    } else if (strEqual (command, "computer")) {
        // Ignore
    } else if (strEqual (command, "draw")) {
        mode.drawOffered = true;
    } else if (strEqual (command, "easy")) {
        mode.ponder = false;
    } else if (strEqual (command, "force")) {
        mode.force = true;
    } else if (strEqual (command, "go")) {
        mode.force = false;
        mode.state = playing;
        return true;
    } else if (strEqual (command, "hard")) {
        mode.ponder = true;
    } else if (strEqual (command, "hint")) {
            // Ignore
    } else if (strEqual (command, "level")) {
        int nmoves, base, inc;
        if (sscanf (parameters, "%d%d%d", &nmoves, &base, &inc) == 3) {
            tc.movesPerControl = nmoves;
            tc.minutesPerControl = base;
            tc.centiSecondsLeft = base * 60 * 100;
            tc.incrementSeconds = inc;
            tc.fixedTimeControl = false;
        }
    } else if (strEqual (command, "modes")) {
      send_msg ("# Force: %d\n", mode.force);
      send_msg ("# Ponder: %d\n", mode.ponder);
    } else if (strEqual (command, "new")) {
        // If we were searching, quit before processing this command:
        if (mode.state == thinking) {
            strCopy (unfinishedCommand, newCommand);
            return true;
        }
        engine->SetPosition(NULL);
        mode.drawOffered = false;
        mode.drawnScores = 0;
    } else if (strEqual (command, "nopost")) {
        engine->SetPostMode(false);
    } else if (strEqual (command, "otim")) {
        int centiSecs;
        if (sscanf (parameters, "%d", &centiSecs) == 1) {
            tc.oppCentiSecondsLeft = centiSecs;
        }
    } else if (strEqual (command, "ping")) {
      send_msg ("pong %s\n", parameters);
    } else if (strEqual (command, "playother")) {
        mode.force = false;
    } else if (strEqual (command, "post")) {
        engine->SetPostMode(true);
//     } else if (strEqual (command, "printboard")) {
//         engine->GetPosition()->DumpBoard (stdout);
    } else if (strEqual (command, "protover")) {
      send_msg ("feature myname=\"Scidlet %s\"\n", SCID_VERSION_STRING);
      send_msg ("feature san=1 analyze=0 time=1 draw=1\n");
      send_msg ("feature ping=1 setboard=1 playother=1 sigint=0\n");
      send_msg ("feature colors=0 done=1\n");
    } else if (strEqual (command, "quit")) {
        exit (0);
    } else if (strEqual (command, "random")) {
        // Ignore
    } else if (strEqual (command, "rejected")) {
        // Ignore protocol accepted/rejected
    } else if (strEqual (command, "remove")) {
        // If we were searching, quit before processing this command:
        if (mode.state == thinking) {
            strCopy (unfinishedCommand, newCommand);
            return true;
        }
        engine->RetractMove();
        engine->RetractMove();
    } else if (strEqual (command, "result")) {
        // Ignore result command
    } else if (strEqual (command, "sd")) {
        uint depth;
        if (sscanf (parameters, "%u", &depth) == 1) {
            engine->SetSearchDepth (depth);
        }
    } else if (strEqual (command, "setboard")) {
        if (mode.state == thinking) {
            strCopy (unfinishedCommand, newCommand);
            return true;
        }
        Position * tmpPos = new Position();
        errorT err = tmpPos->ReadFromFEN (parameters);
        if (err == OK) {
            engine->SetPosition (tmpPos);
        } else {
            if (engine->InXBoardMode()) {
              send_msg ("tellusererror Illegal FEN position.\n");
            } else {
              send_msg ("Illegal FEN position.\n");
            }
        }
        delete tmpPos;
    } else if (strEqual (command, "st")) {
        int seconds;
        if (sscanf (parameters, "%d", &seconds) == 1) {
            tc.centiSecondsLeft = seconds * 100;
            tc.fixedTimeControl = true;
        }
    } else if (strEqual (command, "time")) {
        int centiSecs;
        if (sscanf (parameters, "%d", &centiSecs) == 1) {
            tc.centiSecondsLeft = centiSecs;
        }
    } else if (strEqual (command, "undo")) {
        // If we were searching, quit before processing this command:
        if (mode.state == thinking) {
            strCopy (unfinishedCommand, newCommand);
            return true;
        }
        engine->RetractMove();
    } else if (strEqual (command, "xboard")) {
        engine->SetXBoardMode(true);
        // Print newline to clear the prompt line:
        puts ("");
    } else {
        // Parse a move or unknown command:
        Position * pos = engine->GetPosition();
        simpleMoveT sm;
        errorT err = pos->ParseMove (&sm, newCommand);
        if (err != OK) {
          send_msg ("Error (unknown command): %s\n", newCommand);
            return false;
        }
        // It is a legal move. Do not accept it if the engine is thinking:
        if (mode.state == thinking) {
          send_msg ("Error (move input while thinking): %s\n", newCommand);
            return false;
        }
        engine->PlayMove(&sm);
        return true;
    }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// callback
//   Called periodically from the chess engine to check
//   for user input. Returns true if the search should
//   terminate early.
bool
callback (Engine * engine, void * data)
{
    uiAlive();
//     if (! inputReady()) { return false; }
    return readInput (engine);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// selectPonderMove
//   Selects the best move for the opponent, which will be pondered
//   for a reply while the opponent is thinking.
bool
selectPonderMove (Engine * engine, simpleMoveT * selected)
{
    Position * pos = engine->GetPosition();

    // Do not ponder on the standard starting position:
    if (pos->IsStdStart()) { return false; }

    // Generate the list of opponent moves, make sure it is not empty:
    MoveList mlist;
    pos->GenerateMoves (&mlist);
    if (mlist.Size() == 0) { return false; }

    // Try to find the ponder move from the principal variation:
    bool pvMoveFound = false;
    principalVarT * pv = engine->GetPV();
    if (pv->length >= 2) {
        simpleMoveT * pvMove = &(pv->move[1]);
        int index = mlist.Find (pvMove);
        if (index >= 0) {
            mlist.MoveToFront (index);
            pvMoveFound = true;
        }
    }

    if (!pvMoveFound  &&  mlist.Size() > 1) {
      // Do a very short search to find the move to ponder:
      engine->SetCallbackFunction (NULL, NULL);      // Disable callback.
      engine->SetSearchTime (10);                    // Do a 10 ms search.
      engine->Think (&mlist);
      engine->SetCallbackFunction (callback, NULL);  // Re-enable callback.
    }

    // Find the first move in the list for which there is no opening
    // book reply, and select it as the move to ponder:
    for (uint i=0; i < mlist.Size(); i++) {
        simpleMoveT * sm = mlist.Get(i);
        pos->DoSimpleMove (sm);
        MoveList replyList;
        pos->GenerateMoves (&replyList);
        pos->UndoSimpleMove (sm);
        *selected = *sm;
        return true;
    }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// startPondering
//   Makes the specified move for the opponent, and ponders a reply
//   until interrupted by input.
void
startPondering (Engine * engine, simpleMoveT * ponderMove)
{
    Position * pos = engine->GetPosition();

    if (engine->InPostMode()) {
        char san[20];
        pos->MakeSANString (ponderMove, san, SAN_MATETEST);
        send_msg ("# Pondering: %s\n", san);
    }

    ponder.guessed = false;
    mode.state = pondering;
    ponder.move = *ponderMove;
    engine->PlayMove (ponderMove);
    engine->SetSearchTime (1 << 30);
    MoveList mlist;
    engine->GetPosition()->GenerateMoves (&mlist);
    ponder.score = engine->Think (&mlist);
    ponder.reply = *(mlist.Get(0));
    engine->RetractMove ();
    mode.state = waiting;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// makeReply
//   Given a move list and score, prints and makes the best move
//   and checks for draws etc.
void
makeReply (Engine * engine, MoveList * mlist, int score)
{
//   printf("+++makeReply\n");
    Position * pos = engine->GetPosition();

    if (mlist->Size() == 0) {
//       printf("mlist->Size() == 0\n");
        // It must be stalemate or checkmate:
        if (score == 0) {
          send_msg ("1/2-1/2 {Stalemate}\n");
        } else {
            if (pos->GetToMove() == WHITE) {
              send_msg ("0-1 {Black mates}\n");
            } else {
              send_msg ("1-0 {White mates}\n");
            }
        }
        return;
    }

    // Look for forced draws, unless there is only one move to make:
    if (mlist->Size() != 1) {
        if (config.draw  &&  mode.drawOffered) {
            // The opponent offered a draw. Accept it if we score
            // the position as exactly zero (drawn) and we are not
            // ahead on material, or if the score is bad for us
            // by half a pawn or so.
            int mscore = engine->ScoreMaterial();
            if (score < -50  ||  (score == 0  &&  mscore <= 0)) {
//               printf("offer draw\n");
              send_msg ("offer draw\n");
            }
        }

        // Should we offer a draw?
        if (score != 0) {
            mode.drawnScores = 0;
        } else {
            mode.drawnScores++;
            // Offer a draw every 4 moves when the last few scores
            // have all been zero (drawn), but only if the material
            // score is equal or worse for us, since the oppponent
            // should prove they can draw if behind on material.
            if (config.draw  &&  mode.drawnScores >= 4) {
                int mscore = engine->ScoreMaterial();
                if (mscore <= 0) {
//                   printf("offer draw\n");
                  send_msg ("offer draw\n");
                    mode.drawnScores = 0;
                }
            }
        }

        // If we are hopelessly lost and the opponent has at
        // least 20 seconds remaining, resign now.
        if (config.resign  &&  score < -800  &&  tc.oppCentiSecondsLeft > 2000) {
            if (pos->GetToMove() == WHITE) {
//               printf ("0-1 {White resigns}\n");
              send_msg ("0-1 {White resigns}\n");
            } else {
//               printf ("1-0 {Black resigns}\n");
              send_msg ("1-0 {Black resigns}\n");
            }
            engine->SetPosition(NULL);
            mode.drawOffered = false;
            mode.drawnScores = 0;
            return;
        }
    }

    // Print and play the best move:
    char san[20];
    pos->MakeSANString (mlist->Get(0), san, SAN_MATETEST);
    engine->PlayMove (mlist->Get(0));
//     printf ("move %s\n", san);
    send_msg ("move %s\n", san);
    pos = engine->GetPosition();
    if (pos->IsKingInMate()) {
        if (pos->GetToMove() == WHITE) {
//           printf ("0-1 {Black mates}\n");
          send_msg ("0-1 {Black mates}\n");
        } else {
//           printf ("1-0 {White mates}\n");
          send_msg ("1-0 {White mates}\n");
        }
    }
    mode.drawOffered = false;
//     printf("---makeReply\n");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// main
//   The main Scidlet routine.
int
main (int argc, char ** argv)
{

    // init
    if (init_socket() != 0) {
      return 1;
    }
    
    tc.movesPerControl = 0;
    tc.minutesPerControl = 0;
    tc.centiSecondsLeft = 4000;
    tc.oppCentiSecondsLeft = 4000;
    tc.incrementSeconds = 0;
    tc.fixedTimeControl = false;
    mode.force = false;
    mode.ponder = false;
    mode.analyze = false;
    mode.state = waiting;
    mode.drawOffered = false;

    Engine * engine = new Engine();
    engine->SetXBoardMode (false);
    engine->SetCallbackFunction (callback, NULL);

    engine->SetHashTableKilobytes (config.hashTableMB);
    engine->SetPawnTableKilobytes (config.pawnTableMB);
    engine->SetPruning (config.pruning);

    while (true) {
        if (!readInput( engine ))
          my_usleep(10000);

        ponder.guessed = false;
        if (mode.ponder  &&  !mode.force  /* &&  !inputReady() */ && !readInput( engine ) ) {
            // Ponder until interrupted by input:
            simpleMoveT ponderMove;
            if (selectPonderMove (engine, &ponderMove)) {
                startPondering (engine, &ponderMove);
            }
        }

        if (! mode.analyze) {
          if (ponder.guessed) {
              engine->PlayMove (&ponder.move);
          } else {
              bool reply = readInput (engine);
              if ( !reply && mode.state != playing ) { /*printf("! mode.analyze continue 1\n");*/ continue; }
          }
          if (mode.force) { /*printf("! mode.analyze continue 2\n");*/ continue; }
        }
        
        // Check for certain draws:
        if (engine->NoMatingMaterial()) {
          send_msg ("1/2-1/2 {No mating material}\n");
            continue;
        }
        if (engine->FiftyMoveDraw()) {
          send_msg ("1/2-1/2 {Draw by 50 move rule}\n");
            continue;
        }
        if (engine->RepeatedPosition() >= 3) {
          send_msg ("1/2-1/2 {Draw by repetition}\n");
            continue;
        }

        char san[20];
        MoveList mlist;
        Position * pos = engine->GetPosition();
        pos->GenerateMoves (&mlist);
        int score = 0;

        if (ponder.guessed) {
//           printf("ponder.guessed == true\n");
          int index = mlist.Find (&ponder.reply);
            if (index >= 0) { mlist.MoveToFront (index); }
            makeReply (engine, &mlist, ponder.score);
            continue;
        }
        
//         printf("mlist.Size() = %d\n", mlist.Size());
        if ( mode.analyze ) {
          setSearchTime (engine);
          score = engine->Think (NULL);
        } else { 
          if (mlist.Size() != 1) {
                // Set the search time for this move:
                setSearchTime (engine);
    
                // Search for the best move to play:
                mode.state = thinking;
                score = engine->Think (&mlist);
                mode.state = waiting;
            }
            makeReply (engine, &mlist, score);
            mode.state = waiting;
        }
    }
    return 0;
}
