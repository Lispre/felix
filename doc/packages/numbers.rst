Package: src/packages/numbers.fdoc


======================
Operations on numbers.
======================

================ =====================================
key              file                                  
================ =====================================
number.flx       share/lib/std/scalar/number.flx       
real.flx         share/lib/std/scalar/real.flx         
float_format.flx share/lib/std/scalar/float_format.flx 
float_math.flx   share/lib/std/scalar/float_math.flx   
int.flx          share/lib/std/scalar/int.flx          
quaternion.flx   share/lib/std/scalar/quaternion.flx   
random.flx       share/lib/std/random.flx              
================ =====================================


General Numeric operations.
===========================


.. index:: zero(fun)
.. index:: neg(fun)
.. index:: one(fun)
.. code-block:: felix

  //[number.flx]
  
  instance[t in numbers] FloatAddgrp[t] {
    fun zero: unit -> t = "(?1)0" ;
    fun + : t * t -> t = "$1+$2" ;
    fun neg : t -> t = "-$1" ;
    fun - : t * t -> t = "$1-$2" ;
    proc += : &t * t = "*$1+=$2;";
    proc -= : &t * t = "*$1-=$2;";
  }
  
  instance[t in numbers] FloatMultSemi1[t] {
    fun one: unit -> t = "(?1)1";
    fun * : t * t -> t = "$1*$2";
    proc *= : &t * t = "*$1*=$2;";
  }
  
  instance[t in numbers] FloatRing[t] {}
  instance[t in ints \cup complexes] FloatDring[t] {
    fun / : t * t -> t = "$1/$2";
    fun % : t * t -> t = "$1%$2";
    proc /= : &t * t = "*$1/=$2;";
    proc %= : &t * t = "*$1%=$2;";
  }
  instance[t in floats] FloatDring[t] {
    fun / : t * t -> t = "$1/$2";
    fun % : t * t -> t = "fmod($1,$2)";
    proc /= : &t * t = "*$1/=$2;";
    proc %= : &t * t = "*$1=fmod($1,$2);";
  }

Floating Numbers.
=================

Operations on Real and Complex numbers.


.. index:: Floatinf(class)
.. index:: Doubleinf(class)
.. index:: Ldoubleinf(class)
.. index:: Fcomplex(class)
.. index:: Dcomplex(class)
.. index:: Lcomplex(class)
.. index:: real(fun)
.. index:: imag(fun)
.. index:: abs(fun)
.. index:: arg(fun)
.. index:: neg(fun)
.. index:: zero(fun)
.. index:: one(fun)
.. index:: sin(fun)
.. index:: cos(fun)
.. index:: tan(fun)
.. index:: asin(fun)
.. index:: acos(fun)
.. index:: atan(fun)
.. index:: sinh(fun)
.. index:: cosh(fun)
.. index:: tanh(fun)
.. index:: asinh(fun)
.. index:: acosh(fun)
.. index:: atanh(fun)
.. index:: exp(fun)
.. index:: log(fun)
.. index:: pow(fun)
.. index:: abs(fun)
.. index:: log10(fun)
.. index:: sqrt(fun)
.. index:: ceil(fun)
.. index:: floor(fun)
.. index:: trunc(fun)
.. index:: embed(fun)
.. index:: atan2(fun)
.. index:: CartComplex(class)
.. index:: def(type)
.. code-block:: felix

  //[float_math.flx]
  
  // note: has to be called Fcomplex to avoid clash with class Complex
  
  // Note: ideally we'd use constrained polymorphism for the instances..
  // saves typing it all out so many times
  open class Floatinf
  {
     const FINFINITY : float = "INFINITY" requires C99_headers::math_h;
  }
  
  open class Doubleinf
  {
     const DINFINITY : double = "(double)INFINITY" requires C99_headers::math_h;
  }
  
  open class Ldoubleinf
  {
     const LINFINITY : ldouble = "(long double)INFINITY" requires C99_headers::math_h;
  }
  
  
  
  
  open class Fcomplex
  {
    ctor[t in reals] fcomplex : t * t = "::std::complex<float>($1,$2)";
    ctor[t in reals] fcomplex : t = "::std::complex<float>($1,0)";
    instance Str[fcomplex] {
      fun str (z:fcomplex) => str(real z) + "+" + str(imag z)+"i";
    }
  }
  
  open class Dcomplex
  {
    ctor[t in reals] dcomplex : t * t = "::std::complex<double>($1,$2)";
    ctor[t in reals] dcomplex : t = "::std::complex<double>($1,0)";
    instance Str[dcomplex] {
      fun str (z:dcomplex) => str(real z) + "+" + str(imag z)+"i";
    }
  }
  
  open class Lcomplex
  {
    ctor[t in reals] lcomplex : t * t = "::std::complex<long double>($1,$2)";
    ctor[t in reals] lcomplex : t = "::std::complex<long double>($1,0)";
    instance Str[lcomplex] {
      fun str (z:lcomplex) => str(real z) + "+" + str(imag z)+"i";
    }
  }
  
  instance[t in floats] Complex[complex[t],t] {
    fun real : complex[t] -> t = "real($1)";
    fun imag : complex[t] -> t = "imag($1)";
    fun abs: complex[t] -> t = "abs($1)";
    fun arg : complex[t] -> t = "arg($1)";
    fun neg : complex[t] -> complex[t] = "-$1";
    fun + : complex[t] * complex[t] -> complex[t] = "$1+$2";
    fun - : complex[t] * complex[t] -> complex[t] = "$1-$2";
    fun * : complex[t] * complex[t] -> complex[t] = "$1*$2";
    fun / : complex[t] * complex[t] -> complex[t] = "$1/$2";
    fun + : complex[t] * t -> complex[t] = "$1+$2";
    fun - : complex[t] * t -> complex[t] = "$1-$2";
    fun * : complex[t] * t -> complex[t] = "$1*$2";
    fun / : complex[t] * t -> complex[t] = "$1/$2";
    fun + : t * complex[t] -> complex[t] = "$1+$2";
    fun - : t * complex[t] -> complex[t] = "$1-$2";
    fun * : t * complex[t] -> complex[t] = "$1*$2";
    fun / : t * complex[t] -> complex[t] = "$1/$2";
    fun zero: 1 -> complex[t] = "::std::complex<?1>(0.0)";
    fun one: 1 -> complex[t] = "::std::complex<?1>(1.0)";
  }
  
  instance[t in (floats  \cup  complexes)] Trig[t] {
    requires Cxx_headers::cmath;
    fun sin: t -> t = "::std::sin($1)";
    fun cos: t -> t = "::std::cos($1)";
    fun tan: t -> t = "::std::tan($1)";
    fun asin: t -> t = "::std::asin($1)";
    fun acos: t -> t = "::std::acos($1)";
    fun atan: t -> t = "::std::atan($1)";
    fun sinh: t -> t = "::std::sinh($1)";
    fun cosh: t -> t = "::std::cosh($1)";
    fun tanh: t -> t = "::std::tanh($1)";
    fun asinh: t -> t = "::std::asinh($1)";
    fun acosh: t -> t = "::std::acosh($1)";
    fun atanh: t -> t = "::std::atanh($1)";
    fun exp: t -> t = "::std::exp($1)";
    fun log: t -> t = "::std::log($1)";
    fun pow: t * t -> t = "::std::pow($1,$2)";
  }
  
  instance[t in floats] Real[t] {
    requires Cxx_headers::cmath;
    fun abs: t -> t = "::std::abs($1)";
    fun log10: t -> t = "::std::log10($1)";
    fun sqrt: t -> t = "::std::sqrt($1)";
    fun ceil: t -> t = "::std::ceil($1)";
    fun floor: t -> t = "::std::floor($1)";
    fun trunc: t -> t = "::std::trunc($1)";
    fun embed: int -> t = "(?1)($1)";
    fun atan2: t * t -> t = "::std::atan2($1,$2)";
  }
  
  class CartComplex[r] {
    typedef t = complex[r];
    inherit Complex[t,r];
  }
  
  typedef complex[t in floats] = typematch t with
    | float => fcomplex
    | double => dcomplex
    | ldouble => lcomplex
    endmatch
  ;
  
Complex Constructors.
---------------------



.. code-block:: felix

  //[float_math.flx]
  
  ctor complex[float] (x:float, y:float) => fcomplex(x,y);
  ctor complex[double] (x:double, y:double) => dcomplex(x,y);
  ctor complex[ldouble] (x:ldouble, y:ldouble) => lcomplex(x,y);
  
  ctor complex[float] (x:float) => fcomplex(x,0.0f);
  ctor complex[double] (x:double) => dcomplex(x,0.0);
  ctor complex[ldouble] (x:ldouble) => lcomplex(x,0.0l);
  
  typedef polar[t in floats] = complex[t];
  ctor[t in floats] polar[t] : t * t = "::std::polar($1,$2)";
  
  
  instance[r in floats] CartComplex[r] {}
  
  open Real[float];
  open Real[double];
  open Real[ldouble];
  open Complex[fcomplex, float];
  open Complex[dcomplex, double];
  open Complex[lcomplex, ldouble];
  open CartComplex[float];
  open CartComplex[double];
  open CartComplex[ldouble];
  
  
  
Real numbers
============



.. code-block:: felix

  //[real.flx]
  instance[t in reals] Tord[t] {
    fun < : t * t -> bool = "$1<$2";
  }
  
Floating Formats
================



.. index:: float_format(class)
.. index:: mode(union)
.. index:: fmt(fun)
.. index:: fmt(fun)
.. index:: fmt_default(fun)
.. index:: fmt_fixed(fun)
.. index:: fmt_scientific(fun)
.. index:: xstr(fun)
.. index:: xstr(fun)
.. index:: xstr(fun)
.. code-block:: felix

  //[float_format.flx ]
  //$ Functions to format floating point numbers.
  open class float_format
  {
    //$ Style of formatting.
    //$ default (w,d)    : like C "w.dG" format
    //$ fixed (w,d)      : like C "w.dF" format
    //$ scientific (w,d) : like C "w.dE" format
    union mode =
      | default of int * int
      | fixed of int * int
      | scientific of int * int
    ;
  
    //$ Format a real number v with format m.
    fun fmt[t in reals] (v:t, m: mode) =>
      match m with
      | default (w,p) => fmt_default(v,w,p)
      | fixed (w,p) => fmt_fixed(v,w,p)
      | scientific(w,p) => fmt_scientific(v,w,p)
      endmatch
    ;
  
    //$ Format a complex number v in x + iy form,
    //$ with format m for x and y.
    fun fmt[t,r with Complex[t,r]] (v:t, m: mode) =>
      match m with
      | default (w,p) => fmt_default(real v,w,p) +"+"+fmt_default(imag v,w,p)+"i"
      | fixed (w,p) => fmt_fixed(real v,w,p)+"+"+fmt_fixed(imag v,w,p)+"i"
      | scientific(w,p) => fmt_scientific(real v,w,p)+"+"+fmt_scientific(imag v,w,p)+"i"
      endmatch
    ;
  
    //$ Format default.
    fun fmt_default[t] : t * int * int -> string="::flx::rtl::strutil::fmt_default($a)" requires package "flx_strutil";
  
    //$ Format fixed.
    fun fmt_fixed[t] : t * int * int -> string="::flx::rtl::strutil::fmt_fixed($a)" requires package "flx_strutil";
  
    //$ Format scientfic.
    fun fmt_scientific[t] : t * int * int -> string="::flx::rtl::strutil::fmt_scientific($a)" requires package "flx_strutil";
  }
  
  instance Str[float] {
    fun xstr: float -> string = "::flx::rtl::strutil::str<#1>($1)" requires package "flx_strutil";
  
    //$ Default format float, also supports nan, +inf, -inf.
    noinline fun str(x:float):string =>
      if Float::isnan x then "nan"
      elif Float::isinf x then
        if x > 0.0f then "+inf" else "-inf" endif
      else xstr x
      endif
    ;
  }
  
  instance Str[double] {
    fun xstr: double -> string = "::flx::rtl::strutil::str<#1>($1)" requires package "flx_strutil";
  
    //$ Default format double, also supports nan, +inf, -inf.
    noinline fun str(x:double):string =>
      if Double::isnan x then "nan"
      elif Double::isinf x then
        if x > 0.0 then "+inf" else "-inf" endif
      else xstr x
      endif
    ;
  }
  
  instance Str[ldouble] {
    fun xstr: ldouble -> string = "::flx::rtl::strutil::str<#1>($1)" requires package "flx_strutil";
  
    //$ Default format long double, also supports nan, +inf, -inf.
    noinline fun str(x:ldouble):string =>
      if Ldouble::isnan x then "nan"
      elif Ldouble::isinf x then
        if x > 0.0l then "+inf" else "-inf" endif
      else xstr x
      endif
    ;
  }
  
  
  
Integral Promotion.
===================



.. code-block:: felix

  //[int.flx]
  
  typedef fun integral_promotion: TYPE -> TYPE =
    | #tiny => int
    | #utiny => int
    | #short => int
    | #ushort => int
    | #int => int
    | #uint => uint
    | #long => long
    | #ulong => ulong
    | #vlong => vlong
    | #uvlong => uvlong
  ;
  
Conversion operators.
=====================



.. index:: Tiny(class)
.. index:: tiny(ctor)
.. index:: Short(class)
.. index:: short(ctor)
.. index:: Int(class)
.. index:: int(ctor)
.. index:: int(ctor)
.. index:: int(ctor)
.. index:: Long(class)
.. index:: long(ctor)
.. index:: Vlong(class)
.. index:: vlong(ctor)
.. index:: Utiny(class)
.. index:: utiny(ctor)
.. index:: Ushort(class)
.. index:: ushort(ctor)
.. index:: Uint(class)
.. index:: uint(ctor)
.. index:: Ulong(class)
.. index:: ulong(ctor)
.. index:: Uvlong(class)
.. index:: uvlong(ctor)
.. index:: Int8(class)
.. index:: int8(ctor)
.. index:: Int16(class)
.. index:: int16(ctor)
.. index:: Int32(class)
.. index:: int32(ctor)
.. index:: Int64(class)
.. index:: int64(ctor)
.. index:: Uint8(class)
.. index:: uint8(ctor)
.. index:: Uint16(class)
.. index:: uint16(ctor)
.. index:: Uint32(class)
.. index:: uint32(ctor)
.. index:: Uint64(class)
.. index:: uint64(ctor)
.. index:: Size(class)
.. index:: size(ctor)
.. index:: size(ctor)
.. index:: Ptrdiff(class)
.. index:: ptrdiff(ctor)
.. index:: Intptr(class)
.. index:: intptr(ctor)
.. index:: Uintptr(class)
.. index:: uintptr(ctor)
.. index:: Intmax(class)
.. index:: intmax(ctor)
.. index:: Uintmax(class)
.. index:: uintmax(ctor)
.. code-block:: felix

  //[int.flx]
  open class Tiny
  {
    ctor tiny: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] tiny: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Short
  {
    ctor short: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] short: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Int
  {
    ctor int: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] int: T = "static_cast<#0>($1)/*int.flx: ctor*/";
    ctor int : int = "($1)/*int.flx: ctor int IDENT*/";
    // special hack
    ctor int(x:bool)=> match x with | true => 1 | false => 0 endmatch;
  }
  
  open class Long
  {
    ctor long: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] long: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Vlong
  {
    ctor vlong: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] vlong: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Utiny
  {
    ctor utiny: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] utiny: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Ushort
  {
    ctor ushort: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] ushort: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uint
  {
    ctor uint: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uint: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Ulong
  {
    ctor ulong: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] ulong: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uvlong
  {
    ctor uvlong: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uvlong: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Int8
  {
    ctor int8: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] int8: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Int16
  {
    ctor int16: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] int16: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Int32
  {
    ctor int32: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] int32: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Int64
  {
    ctor int64: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] int64: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uint8
  {
    ctor uint8: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uint8: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uint16
  {
    ctor uint16: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uint16: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uint32
  {
    ctor uint32: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uint32: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uint64
  {
    ctor uint64: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uint64: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Size
  {
    ctor size: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] size: T = "static_cast<#0>($1)/*int.flx: ctor size from #0*/";
    ctor size: size = "($1)/*int.flx: ctor size IDENT*/";
  
    // special overrides so s.len - 1 works
    fun - : size * int -> size = "$1-$2";
    fun + : size * int -> size = "$1+$2";
  }
  
  open class Ptrdiff
  {
    ctor ptrdiff: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] ptrdiff: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Intptr
  {
    ctor intptr: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] intptr: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uintptr
  {
    ctor uintptr: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uintptr: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Intmax 
  {
    ctor intmax: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] intmax: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  open class Uintmax
  {
    ctor uintmax: string = "static_cast<#0>(::std::atoi($1.c_str()))" requires Cxx_headers::cstdlib;
    ctor[T in reals] uintmax: T = "static_cast<#0>($1)/*int.flx: ctor*/";
  }
  
  
Convert to decimal string.
==========================



.. index:: str(fun)
.. index:: str(fun)
.. index:: str(fun)
.. code-block:: felix

  //[int.flx]
  instance Str[tiny] {
    fun str: tiny -> string = "::flx::rtl::strutil::str<int>($1)" requires package "flx_strutil";
  }
  
  instance Str[utiny] {
    fun str: utiny -> string = "::flx::rtl::strutil::str<unsigned int>($1)" requires package "flx_strutil";
  }
  
  instance
  [
    T in 
      short \cup ushort \cup int \cup uint \cup long \cup ulong \cup vlong \cup uvlong \cup 
      exact_ints \cup weird_sints \cup weird_uints
  ] 
  Str[T] 
  {
    fun str: T -> string = "::flx::rtl::strutil::str<#1>($1)" requires package "flx_strutil";
  }
  
Convert to lexical string.
==========================



.. code-block:: felix

  //[int.flx]
  instance Repr[tiny]   { fun repr[with Str[tiny]]   (t:tiny)   : string => (str t) + "t";  }
  instance Repr[short]  { fun repr[with Str[short]]  (t:short)  : string => (str t) + "s";  }
  instance Repr[int]   { fun repr[with Str[int]]   (t:int)   : string => (str t) + "";  }
  instance Repr[long]   { fun repr[with Str[long]]   (t:long)   : string => (str t) + "l";  }
  instance Repr[vlong]  { fun repr[with Str[vlong]]  (t:vlong)  : string => (str t) + "v";  }
  instance Repr[int8]  { fun repr[with Str[int8]]  (t:int8)  : string => (str t) + "i8";  }
  instance Repr[int16]  { fun repr[with Str[int16]]  (t:int16)  : string => (str t) + "i16";  }
  instance Repr[int32]  { fun repr[with Str[int32]]  (t:int32)  : string => (str t) + "i32";  }
  instance Repr[int64]  { fun repr[with Str[int64]]  (t:int64)  : string => (str t) + "i64";  }
  instance Repr[intmax]  { fun repr[with Str[intmax]]  (t:intmax)  : string => (str t) + "j";  }
  instance Repr[intptr]  { fun repr[with Str[intptr]]  (t:intptr)  : string => (str t) + "p";  }
  instance Repr[ptrdiff]  { fun repr[with Str[ptrdiff]]  (t:ptrdiff)  : string => (str t) + "d";  }
  
  instance Repr[utiny]  { fun repr[with Str[utiny]]  (t:utiny)  : string => (str t) + "ut"; }
  instance Repr[ushort] { fun repr[with Str[ushort]] (t:ushort) : string => (str t) + "us"; }
  instance Repr[uint]   { fun repr[with Str[uint]]   (t:uint)   : string => (str t) + "u";  }
  instance Repr[ulong]  { fun repr[with Str[ulong]]  (t:ulong)  : string => (str t) + "ul"; }
  instance Repr[uvlong] { fun repr[with Str[uvlong]] (t:uvlong) : string => (str t) + "uv"; }
  instance Repr[uint8]  { fun repr[with Str[uint8]]  (t:uint8)  : string => (str t) + "u8";  }
  instance Repr[uint16]  { fun repr[with Str[uint16]]  (t:uint16)  : string => (str t) + "u16";  }
  instance Repr[uint32]  { fun repr[with Str[uint32]]  (t:uint32)  : string => (str t) + "u32";  }
  instance Repr[uint64]  { fun repr[with Str[uint64]]  (t:uint64)  : string => (str t) + "u64";  }
  instance Repr[size]  { fun repr[with Str[size]]  (t:size)  : string => (str t) + "uz";  }
  instance Repr[uintmax]  { fun repr[with Str[uintmax]]  (t:uintmax)  : string => (str t) + "uj";  }
  instance Repr[uintptr]  { fun repr[with Str[uintptr]]  (t:uintptr)  : string => (str t) + "up";  }
  
  
Methods of integers
===================



.. index:: succ(fun)
.. index:: pre_incr(proc)
.. index:: post_incr(proc)
.. index:: pred(fun)
.. index:: pre_decr(proc)
.. index:: post_decr(proc)
.. code-block:: felix

  //[int.flx]
  instance[t in ints] Addgrp[t] {}
  instance[t in ints] Ring[t] {}
  instance[t in ints] MultSemi1[t] {}
  instance[t in ints] Dring[t] {}
  
  instance [t in uints] Bits [t] {
    fun \^ : t * t -> t = "(?1)($1^$2)";
    fun \| : t * t -> t = "(?1)($1|$2)";
    fun \& : t * t -> t = "(?1)($1&$2)";
  
    // note: the cast is essential to ensure ~1tu is 254tu
    fun ~ : t -> t = "(?1)~$1";
    proc ^= : &t * t = "*$1^=$2;";
    proc |= : &t * t = "*$1|=$2;";
    proc &= : &t * t = "*$1&=$2;";
  }
  
  instance[t in ints] Forward[t] {
    fun succ: t -> t = "$1+1";
    proc pre_incr: &t = "++*$1;";
    proc post_incr: &t = "(*$1)++;";
  }
  
  instance[t in ints] Bidirectional[t] {
    fun pred: t -> t = "$1-1";
    proc pre_decr: &t = "--*$1;";
    proc post_decr: &t = "(*$1)--;";
  }
  
  instance[t in ints] Integer[t] {
    fun << : t * t -> t = "$1<<$2";
    fun >> : t * t -> t = "$1>>$2";
  }
  
Methods of signed integers
==========================



.. index:: sgn(fun)
.. index:: abs(fun)
.. code-block:: felix

  //[int.flx]
  instance[t in sints] Signed_integer[t] {
    fun sgn: t -> int = "$1<0??-1:$1>0??1:0";
    fun abs: t -> t = "$1<0??-$1:$1";
  }
  
Methods of unsigned integers
============================



.. code-block:: felix

  //[int.flx]
  instance[t in uints] Unsigned_integer[t] {}
  
Make functions accessible without qualification
===============================================



.. code-block:: felix

  //[int.flx]
  //open[T in sints] Signed_integer[T];
  open Signed_integer[tiny];
  open Signed_integer[short];
  open Signed_integer[int];
  open Signed_integer[long];
  open Signed_integer[vlong];
  open Signed_integer[int8];
  open Signed_integer[int16];
  open Signed_integer[int32];
  open Signed_integer[int64];
  open Signed_integer[intmax];
  open Signed_integer[ptrdiff];
  open Signed_integer[intptr];
  
  //open[T in uints] Unsigned_integer[T];
  open Unsigned_integer[utiny];
  open Unsigned_integer[ushort];
  open Unsigned_integer[uint];
  open Unsigned_integer[ulong];
  open Unsigned_integer[uvlong];
  open Unsigned_integer[uint8];
  open Unsigned_integer[uint16];
  open Unsigned_integer[uint32];
  open Unsigned_integer[uint64];
  open Unsigned_integer[uintmax];
  open Unsigned_integer[size];
  open Unsigned_integer[uintptr];
  
  
  
Quaternions
===========



.. index:: Quaternion(class)
.. index:: quaternion(type)
.. index:: quaternion(ctor)
.. index:: r(fun)
.. index:: i(fun)
.. index:: j(fun)
.. index:: k(fun)
.. index:: q(ctor)
.. index:: conj(fun)
.. index:: norm(fun)
.. index:: reciprocal(fun)
.. code-block:: felix

  //[quaternion.flx]
  
  class Quaternion
  {
    type quaternion = new double ^ 4;
    ctor quaternion (x:double^4) => _make_quaternion x;
    private typedef q = quaternion;
    fun r(x:q)=> (_repr_ x) . 0;
    fun i(x:q)=> (_repr_ x) . 1;
    fun j(x:q)=> (_repr_ x) . 2;
    fun k(x:q)=> (_repr_ x) . 3;
  
    ctor q (x:double) => quaternion (x,0.0,0.0,0.0);
  
    fun + (a:q,b:q):q =>
      quaternion (a.r+ b.r, a.i + b.i, a.j + b.j, a.k+b.k)
    ;
  
    fun * (a:q, b:q):q =>
      quaternion (
        a.r * b.r - a.i * b.i - a.j * b.j - a.k * b.k,
        a.r * b.i + a.i * b.r + a.j * b.k - a.k * b.j,
        a.r * b.j - a.i * b.k + a.j * b.r - a.k * b.i,
        a.r * b.k + a.i * b.j - a.j * b.i + a.k * b.r
      )
    ;
  
    fun conj (a:q):q => quaternion (a.r, -a.i, -a.j, -a.k);
    fun norm (a:q):double => sqrt (a.r * a.r + a.i * a.i + a.j * a.j +a.k * a.k);
  
    fun * (a:q, b: double):q => quaternion (a.r * b, a.i * b, a.j * b, a.k * b);
    fun * (a: double, b:q):q => a * b;
  
    fun reciprocal (a:q):q => let n = norm a in conj a * (1.0/ (n * n));
  
    // add more later, generalise scalar type
    // Later, GET RID of complex and quaternions
    // by introducing typeclasses for arbitrary R-modules
  }
  
Random number generation
========================


