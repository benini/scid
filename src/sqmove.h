//////////////////////////////////////////////////////////////////////
//
//  FILE:       sqmove.h
//              Square movement lookup table
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    0.3
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_SQMOVE_H
#define SCID_SQMOVE_H

  const squareT
sqMove[65][11] = {
                /* UP  DN     LEF  UL  DL    RIGHT UR  DR */
   { /* A1 */  NS, A2, NS, NS, NS, NS, NS, NS, B1, B2, NS   },
   { /* B1 */  NS, B2, NS, NS, A1, A2, NS, NS, C1, C2, NS   },
   { /* C1 */  NS, C2, NS, NS, B1, B2, NS, NS, D1, D2, NS   },
   { /* D1 */  NS, D2, NS, NS, C1, C2, NS, NS, E1, E2, NS   },
   { /* E1 */  NS, E2, NS, NS, D1, D2, NS, NS, F1, F2, NS   },
   { /* F1 */  NS, F2, NS, NS, E1, E2, NS, NS, G1, G2, NS   },
   { /* G1 */  NS, G2, NS, NS, F1, F2, NS, NS, H1, H2, NS   },
   { /* H1 */  NS, H2, NS, NS, G1, G2, NS, NS, NS, NS, NS   },
   { /* A2 */  NS, A3, A1, NS, NS, NS, NS, NS, B2, B3, B1   },
   { /* B2 */  NS, B3, B1, NS, A2, A3, A1, NS, C2, C3, C1   },
   { /* C2 */  NS, C3, C1, NS, B2, B3, B1, NS, D2, D3, D1   },
   { /* D2 */  NS, D3, D1, NS, C2, C3, C1, NS, E2, E3, E1   },
   { /* E2 */  NS, E3, E1, NS, D2, D3, D1, NS, F2, F3, F1   },
   { /* F2 */  NS, F3, F1, NS, E2, E3, E1, NS, G2, G3, G1   },
   { /* G2 */  NS, G3, G1, NS, F2, F3, F1, NS, H2, H3, H1   },
   { /* H2 */  NS, H3, H1, NS, G2, G3, G1, NS, NS, NS, NS   },
   { /* A3 */  NS, A4, A2, NS, NS, NS, NS, NS, B3, B4, B2   },
   { /* B3 */  NS, B4, B2, NS, A3, A4, A2, NS, C3, C4, C2   },
   { /* C3 */  NS, C4, C2, NS, B3, B4, B2, NS, D3, D4, D2   },
   { /* D3 */  NS, D4, D2, NS, C3, C4, C2, NS, E3, E4, E2   },
   { /* E3 */  NS, E4, E2, NS, D3, D4, D2, NS, F3, F4, F2   },
   { /* F3 */  NS, F4, F2, NS, E3, E4, E2, NS, G3, G4, G2   },
   { /* G3 */  NS, G4, G2, NS, F3, F4, F2, NS, H3, H4, H2   },
   { /* H3 */  NS, H4, H2, NS, G3, G4, G2, NS, NS, NS, NS   },
   { /* A4 */  NS, A5, A3, NS, NS, NS, NS, NS, B4, B5, B3   },
   { /* B4 */  NS, B5, B3, NS, A4, A5, A3, NS, C4, C5, C3   },
   { /* C4 */  NS, C5, C3, NS, B4, B5, B3, NS, D4, D5, D3   },
   { /* D4 */  NS, D5, D3, NS, C4, C5, C3, NS, E4, E5, E3   },
   { /* E4 */  NS, E5, E3, NS, D4, D5, D3, NS, F4, F5, F3   },
   { /* F4 */  NS, F5, F3, NS, E4, E5, E3, NS, G4, G5, G3   },
   { /* G4 */  NS, G5, G3, NS, F4, F5, F3, NS, H4, H5, H3   },
   { /* H4 */  NS, H5, H3, NS, G4, G5, G3, NS, NS, NS, NS   },
   { /* A5 */  NS, A6, A4, NS, NS, NS, NS, NS, B5, B6, B4   },
   { /* B5 */  NS, B6, B4, NS, A5, A6, A4, NS, C5, C6, C4   },
   { /* C5 */  NS, C6, C4, NS, B5, B6, B4, NS, D5, D6, D4   },
   { /* D5 */  NS, D6, D4, NS, C5, C6, C4, NS, E5, E6, E4   },
   { /* E5 */  NS, E6, E4, NS, D5, D6, D4, NS, F5, F6, F4   },
   { /* F5 */  NS, F6, F4, NS, E5, E6, E4, NS, G5, G6, G4   },
   { /* G5 */  NS, G6, G4, NS, F5, F6, F4, NS, H5, H6, H4   },
   { /* H5 */  NS, H6, H4, NS, G5, G6, G4, NS, NS, NS, NS   },
   { /* A6 */  NS, A7, A5, NS, NS, NS, NS, NS, B6, B7, B5   },
   { /* B6 */  NS, B7, B5, NS, A6, A7, A5, NS, C6, C7, C5   },
   { /* C6 */  NS, C7, C5, NS, B6, B7, B5, NS, D6, D7, D5   },
   { /* D6 */  NS, D7, D5, NS, C6, C7, C5, NS, E6, E7, E5   },
   { /* E6 */  NS, E7, E5, NS, D6, D7, D5, NS, F6, F7, F5   },
   { /* F6 */  NS, F7, F5, NS, E6, E7, E5, NS, G6, G7, G5   },
   { /* G6 */  NS, G7, G5, NS, F6, F7, F5, NS, H6, H7, H5   },
   { /* H6 */  NS, H7, H5, NS, G6, G7, G5, NS, NS, NS, NS   },
   { /* A7 */  NS, A8, A6, NS, NS, NS, NS, NS, B7, B8, B6   },
   { /* B7 */  NS, B8, B6, NS, A7, A8, A6, NS, C7, C8, C6   },
   { /* C7 */  NS, C8, C6, NS, B7, B8, B6, NS, D7, D8, D6   },
   { /* D7 */  NS, D8, D6, NS, C7, C8, C6, NS, E7, E8, E6   },
   { /* E7 */  NS, E8, E6, NS, D7, D8, D6, NS, F7, F8, F6   },
   { /* F7 */  NS, F8, F6, NS, E7, E8, E6, NS, G7, G8, G6   },
   { /* G7 */  NS, G8, G6, NS, F7, F8, F6, NS, H7, H8, H6   },
   { /* H7 */  NS, H8, H6, NS, G7, G8, G6, NS, NS, NS, NS   },
   { /* A8 */  NS, NS, A7, NS, NS, NS, NS, NS, B8, NS, B7   },
   { /* B8 */  NS, NS, B7, NS, A8, NS, A7, NS, C8, NS, C7   },
   { /* C8 */  NS, NS, C7, NS, B8, NS, B7, NS, D8, NS, D7   },
   { /* D8 */  NS, NS, D7, NS, C8, NS, C7, NS, E8, NS, E7   },
   { /* E8 */  NS, NS, E7, NS, D8, NS, D7, NS, F8, NS, F7   },
   { /* F8 */  NS, NS, F7, NS, E8, NS, E7, NS, G8, NS, G7   },
   { /* G8 */  NS, NS, G7, NS, F8, NS, F7, NS, H8, NS, H7   },
   { /* H8 */  NS, NS, H7, NS, G8, NS, G7, NS, NS, NS, NS   },
   { /* NS */  NS, NS, NS, NS, NS, NS, NS, NS, NS, NS, NS   }
 };
#endif

//////////////////////////////////////////////////////////////////////
//  EOF: sqmove.h
//////////////////////////////////////////////////////////////////////

