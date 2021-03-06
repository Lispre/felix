Package: src/packages/botan.fdoc


===============
Botan Interface
===============

============== ====================================
key            file                                 
============== ====================================
botan_unix.fpc $PWD/src/config/unix/botan.fpc       
rng.fpc        $PWD/src/config/botan_rng.fpc        
system_rng.fpc $PWD/src/config/botan_system_rng.fpc 
rng.flx        share/lib/botan/rng.flx              
============== ====================================

========== ================================
key        file                             
========== ================================
bigint.flx share/lib/botan/bigint.flx       
bigint.fpc $PWD/src/config/botan_bigint.fpc 
========== ================================

========== ==============================
key        file                           
========== ==============================
hash.flx   share/lib/botan/hash.flx       
hash.fpc   $PWD/src/config/botan_hash.fpc 
========== ==============================


Random number generators.
=========================


.. index:: RandomNumberGenerator(type)
.. index:: System_RNG(fun)
.. index:: add_entropy(proc)
.. index:: randomize_with_input(proc)
.. index:: randomize_with_ts_input(proc)
.. index:: randomize(proc)
.. code-block:: felix

  //[rng.flx]
  library Botan { class Rng
  {
    requires package "botan_rng", package "botan_system_rng";
    type RandomNumberGenerator = "Botan::RandomNumberGenerator*";
    fun System_RNG: 1 -> RandomNumberGenerator = "new Botan::System_RNG()";
    proc add_entropy: RandomNumberGenerator * +byte * size = "$1->add_entropy($2,$3);";
    proc randomize_with_input: 
      RandomNumberGenerator * +byte * size * +byte * size=
      "$1->add_entropy($2,$3,$4,$5);"
    ;
    proc randomize_with_ts_input: RandomNumberGenerator * +byte * size = 
      "$1->randomize_with_ts_input($2,$3);"
    ;
    proc randomize: RandomNumberGenerator * +byte * size = 
      "$1->randomize_with_input($2,$3);"
    ;
  }}


Big Integers
============


.. index:: bigint(type)
.. index:: bigint(ctor)
.. index:: gcd(fun)
.. index:: lcm(fun)
.. index:: jacobi(fun)
.. index:: power_mod(fun)
.. code-block:: felix

  //[bigint.flx]
  library Botan { class BigInt
  {
    requires package "botan_bigint";
    type bigint = "Botan::BigInt";
    body strbigint = """
      static ::std::string strbigint (Botan::BigInt const &pi) {
        ::std::stringstream s;
        s << pi;
        return s.str();
      }
    """;
  
    ctor bigint : string = "Botan::BigInt ($1)";
  
    instance Forward[bigint] {
      fun succ: bigint -> bigint = "$1+Botan::BigInt(1)";
      proc pre_incr: &bigint = "$1->operator++();";
      proc post_incr: &bigint = "$1->operator++();";
    }
    instance Bidirectional[bigint] {
      fun pred: bigint -> bigint = "$1-Botan::BigInt(1)";
      proc pre_decr: &bigint = "$1->operator--();";
      proc post_decr: &bigint = "$1->operator--();";
    }
  
    instance FloatAddgrp[bigint] {
      fun zero: 1 -> bigint = "Botan::Bigint(0)";
      fun neg: bigint -> bigint = "-$1";
      proc += : &bigint * bigint = "$1->operator+= ($2);";
      proc -= : &bigint * bigint = "$1->operator-=($2);";
  
      fun + : bigint * bigint -> bigint = "$1+$2";
      fun - : bigint * bigint -> bigint = "$1-$2";
    }
    instance FloatMultSemi1[bigint] {
      fun one : 1 -> bigint = "Botan::BigInt(1)";
      fun * : bigint * bigint -> bigint = "$1*$2";
      proc *= : &bigint * bigint = "$1->operator*=($2);";
    }
    instance FloatDring[bigint] {
      fun / : bigint * bigint -> bigint = "$1/$2";
      fun % : bigint * bigint -> bigint = "$1%$2";
      proc /= : &bigint * bigint = "$1->operator/=($2);";
      proc %= : &bigint * bigint = "$1->operator%=($2);";
    }
    instance Integer[bigint] {
      body bigintshl = """
         // throws if right argument abs value is too big
         static Botan::BigInt shl(Botan::BigInt const &l, Botan::BigInt r) {
           if (r.is_negative()) {
              r = -r;
              ::std::size_t rr = r.to_u32bit();
              return l >> rr;
           } else {
             ::std::size_t rr = r.to_u32bit();
             return l << rr;
           }
         }
      """;
      fun << : bigint * bigint -> bigint = "bigint_shl($1,$2)" requires bigintshl; 
      fun >> : bigint * bigint -> bigint = "bigint_shl($1,-$2)" requires bigintshl; 
    }
    instance Signed_integer[bigint] {
      fun abs: bigint -> bigint = "$1.abs()";
      fun sgn: bigint -> int = "$1.is_zero()? 0 : ($1.is_positive() ? 1 : -1)";
    }
    inherit Signed_integer[bigint];
  
    instance Eq[bigint] {
      fun == : bigint * bigint -> bool = "$1==$2";
    }
    instance Tord[bigint] {
      fun < : bigint * bigint -> bool = "$1<$2";
      fun <= : bigint * bigint -> bool = "$1<=$2";
      fun > : bigint * bigint -> bool = "$1>$2";
      fun >= : bigint * bigint -> bool = "$1>=$2";
    }
    inherit Tord[bigint]; // includes Eq
    instance Str[bigint] {
      fun str: bigint -> string = "strbigint($1)" requires strbigint;
    }
    fun gcd: bigint * bigint -> bigint = "Botan::gcd($1,$2)";
    fun lcm: bigint * bigint -> bigint = "Botan::lcm($1,$2)";
    fun jacobi: bigint * bigint -> bigint = "Botan::jacobi($1,$2)";
  
    // b^x % m
    fun power_mod: bigint * bigint * bigint -> bigint = "Botan::power_mod($1,$2,$3)";
  }}
  


Hash functions
==============


.. index:: BufferedComputation(type)
.. index:: output_length(fun)
.. index:: update(proc)
.. index:: update(proc)
.. index:: final(proc)
.. code-block:: felix

  //[hash.flx]
  library Botan { class Hash {
    type BufferedComputation = "::Botan::BufferedComputation*";
    fun output_length : BufferedComputation -> size = "$1->output_length()";
    proc update : BufferedComputation * +byte * size = "$1->update($2,$3);";
    proc update : BufferedComputation * byte = "$1->update($2);";
    proc final: BufferedComputation * +byte = "$1->final($2);";
  
  }}



.. code-block:: fpc

  //[botan_unix.fpc]
  Name: botan 
  Platform: Unix 
  Description: Botan Crypto Library 
  provides_dlib: -L/usr/local/lib -lbotan-2
  provides_slib: -L/usr/local/lib -lbotan-2
  cflags: -I/usr/local/include/botan-2.0


.. code-block:: fpc

  //[rng.fpc]
  Requires: botan
  includes: '"botan/rng.h"'
  cflags: -I/usr/local/include/botan-2.0



.. code-block:: fpc

  //[system_rng.fpc]
  Requires: botan
  includes: '"botan/system_rng.h"'
  cflags: -I/usr/local/include/botan-2.0


.. code-block:: fpc

  //[bigint.fpc]
  Requires: botan
  includes: '"botan/bigint.h"' '"botan/numthry.h"'
  cflags: -I/usr/local/include/botan-2.0




