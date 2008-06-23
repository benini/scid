#include "glaurung.h"

uint8 BitCount[256];
uint8 PawnRank[2][128];
attack_data_t AttackData_[256];
attack_data_t *AttackData = AttackData_+128;
uint8 Distance_[256];
uint8 *Distance = Distance_+128;
uint32 History[2][4096];
root_search_info_t RSI[1];
engine_options_t Options[1];
int InitialKSQ, InitialKRSQ, InitialQRSQ;
bool EngineShouldQuit = false;
