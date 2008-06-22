#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

#if (!defined(INLINE32) && !defined(VC_INLINE32) && !defined(ALPHA) && !defined(INLINE64)) || (defined(ALPHA) && !defined(PopCnt))

#  if defined (_M_IA64)

#    ifdef __ICL
typedef unsigned long long __m64;
#    elif _MSC_VER >= 1300
typedef union __declspec (intrin_type) __declspec(align(8)) __m64
{
  unsigned __int64 m64_u64;
  float m64_f32[2];
  __int8 m64_i8[8];
  __int16 m64_i16[4];
  __int32 m64_i32[2];
  __int64 m64_i64;
  unsigned __int8 m64_u8[8];
  unsigned __int16 m64_u16[4];
  unsigned __int32 m64_u32[2];
} __m64;
#    endif

__m64 __m64_popcnt(__m64);

#    pragma intrinsic (__m64_popcnt)

int PopCnt(register BITBOARD a)
{
#    ifdef __ICL
  return (int) __m64_popcnt(a);
#    else
  __m64 m;

  m.m64_u64 = a;
  m = __m64_popcnt(m);
  return (int) m.m64_u64;
#    endif
}

#  else

#    if !defined(INLINE32) && !defined(VC_INLINE32)
int PopCnt(register BITBOARD a)
{
  register int c = 0;

  while (a) {
    c++;
    a &= a - 1;
  }
  return (c);
}
#    endif

#  endif

#  if defined (_M_AMD64) || defined (_M_IA64)

extern unsigned char _BitScanReverse64(unsigned long *, unsigned __int64);

#    pragma intrinsic (_BitScanReverse64)
extern unsigned char _BitScanForward64(unsigned long *, unsigned __int64);

#    pragma intrinsic (_BitScanForward64)

int MSB(BITBOARD arg1)
{
  unsigned long index;

  if (_BitScanReverse64(&index, arg1))
    return index;
  else
    return 64;
}

int LSB(BITBOARD arg1)
{
  unsigned long index;

  if (_BitScanForward64(&index, arg1))
    return index;
  else
    return 64;
}

#  else

#    if !defined(INLINE32) && !defined(VC_INLINE32)
int MSB(BITBOARD arg1)
{
  if (arg1 >> 48)
    return (msb[arg1 >> 48] + 48);
  if ((arg1 >> 32) & 65535)
    return (msb[(arg1 >> 32) & 65535] + 32);
  if ((arg1 >> 16) & 65535)
    return (msb[(arg1 >> 16) & 65535] + 16);
  return (msb[arg1 & 65535]);
}

int LSB(BITBOARD arg1)
{
  if (arg1 & 65535)
    return (lsb[arg1 & 65535]);
  if ((arg1 >> 16) & 65535)
    return (lsb[(arg1 >> 16) & 65535] + 16);
  if ((arg1 >> 32) & 65535)
    return (lsb[(arg1 >> 32) & 65535] + 32);
  return (lsb[arg1 >> 48] + 48);
}
#    endif
#  endif
#endif
