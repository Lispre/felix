Package: src/packages/regex.fdoc


===================
Regular Expressions
===================

================== ================================
key                file                             
================== ================================
re2.py             $PWD/buildsystem/re2.py          
unix_re2.fpc       $PWD/src/config/unix/re2.fpc     
win32_re2.fpc      $PWD/src/config/win32/re2.fpc    
flx_re2_config.hpp share/lib/rtl/flx_re2_config.hpp 
================== ================================

============ ================================
key          file                             
============ ================================
__init__.flx share/lib/std/regex/__init__.flx 
============ ================================

============ ================================
key          file                             
============ ================================
re2.flx      share/lib/std/regex/re2.flx      
tre.flx      share/lib/std/regex/tre.flx      
regdef.flx   share/lib/std/regex/regdef.flx   
regexps.fsyn share/lib/std/regex/regexps.fsyn 
lexer.flx    share/lib/std/regex/lexer.flx    
============ ================================

================= ==================================
key               file                               
================= ==================================
regexp_index.fdoc $PWD/src/web/tut/regexp_index.fdoc 
================= ==================================


RE2 Bootstrap Builder
=====================


.. code-block:: python

  #[re2.py]
  
  import fbuild
  from fbuild.functools import call
  from fbuild.path import Path
  from fbuild.record import Record
  
  import buildsystem
  
  # ------------------------------------------------------------------------------
  
  def build_runtime(phase):
      path = Path(phase.ctx.buildroot/'share'/'src/re2/re2')
  
      buildsystem.copy_to(phase.ctx, phase.ctx.buildroot / "share/lib/rtl/re2", [
          path / 're2/re2.h',
          path / 're2/set.h',
          path / 're2/stringpiece.h',
          path / 're2/variadic_function.h',
          ]
       )
  
      dst = 'host/lib/rtl/flx_re2'
      srcs = [
          path / 're2/bitstate.cc',
          path / 're2/compile.cc',
          path / 're2/dfa.cc',
          path / 're2/filtered_re2.cc',
          path / 're2/mimics_pcre.cc',
          path / 're2/nfa.cc',
          path / 're2/onepass.cc',
          path / 're2/parse.cc',
          path / 're2/perl_groups.cc',
          path / 're2/prefilter.cc',
          path / 're2/prefilter_tree.cc',
          path / 're2/prog.cc',
          path / 're2/re2.cc',
          path / 're2/regexp.cc',
          path / 're2/set.cc',
          path / 're2/simplify.cc',
          path / 're2/tostring.cc',
          path / 're2/unicode_casefold.cc',
          path / 're2/unicode_groups.cc',
          path / 'util/arena.cc',
          #path / 'util/benchmark.cc',
          path / 'util/hash.cc',
          #path / 'util/pcre.cc',
          #path / 'util/random.cc',
          path / 'util/rune.cc',
          path / 'util/stringpiece.cc',
          path / 'util/stringprintf.cc',
          path / 'util/strutil.cc',
          #path / 'util/thread.cc',
          path / 'util/valgrind.cc',
       ]
      includes = [
        phase.ctx.buildroot / 'share/lib/rtl',
        phase.ctx.buildroot / 'host/lib/rtl',
        path ]
      macros = ['BUILD_RE2'] + (['WIN32', 'NOMINMAX'],[])[not 'win32' in phase.platform]
      cflags = ([], ['-Wno-sign-compare'])[not 'win32' in phase.platform]
      lflags = []
      libs = []
      external_libs = []
  
      return Record(
          static=buildsystem.build_cxx_static_lib(phase, dst, srcs,
              includes=includes,
              macros=macros,
              cflags=cflags,
              libs=libs,
              external_libs=external_libs,
              lflags=lflags),
          shared=buildsystem.build_cxx_shared_lib(phase, dst, srcs,
              includes=includes,
              macros=macros,
              cflags=cflags,
              libs=libs,
              external_libs=external_libs,
              lflags=lflags))


String handling
===============



.. code-block:: felix

  //[__init__.flx]
  include "std/regex/re2";
  include "std/regex/tre";
  include "std/regex/regdef";
  include "std/regex/lexer";
  
  
RE2 regexps
===========



.. index:: Re2(class)
.. index:: RE2(type)
.. index:: _ctor_RE2(gen)
.. index:: StringPiece(type)
.. index:: subscript(fun)
.. index:: Arg(type)
.. index:: Encoding(type)
.. index:: RE2Options(type)
.. index:: ErrorCode(type)
.. index:: Anchor(type)
.. index:: pattern(fun)
.. index:: error(fun)
.. index:: error_code(fun)
.. index:: error_arg(fun)
.. index:: ok(fun)
.. index:: ProgramSize(fun)
.. index:: GlobalReplace(gen)
.. index:: Extract(gen)
.. index:: QuoteMeta(fun)
.. index:: PossibleMatchRange(fun)
.. index:: NumberOfCapturingGroups(fun)
.. index:: NamedCapturingGroups(fun)
.. index:: Match(gen)
.. index:: apply(gen)
.. index:: CheckRewriteString(fun)
.. index:: iterator(gen)
.. index:: extract(fun)
.. index:: extract(fun)
.. code-block:: felix

  //[re2.flx]
  
  include "stl/stl_map";
  
  //$ Binding of Google RE2 regexp library.
  open class Re2 {
    requires package "re2";
  
  // This is an almost full binding of Google's re2 package.
  // We do not support conversions of digits strings to integers
  //
  // TODO: we need to check the lvalue handling here
  // The RE2, Options classes aren't copyable, so we may have
  // to use pointers
  //
  // TODO: named group extractor
  
    // hackery because ::re2::RE2 isn't copyable, so we have to use a pointer
    // but we need the shape of RE2 to create on the heap
    private body RE2_serial = """
    static ::std::string RE2_encoder(void *p) { 
      return (*(::std::shared_ptr< ::re2::RE2>*)p)->pattern(); 
    }
  
    static size_t RE2_decoder (void *p, char *s, size_t i) { 
      char tmp[sizeof(::std::string)];
      i = ::flx::gc::generic::string_decoder (&tmp,s,i);
      new(p) ::std::shared_ptr< ::re2::RE2> (new ::re2::RE2 (*(::std::string*)(&tmp)));
      ::destroy((::std::string*)&tmp);
      return i;
    }
    """; 
  /*
    private type RE2_ = "::re2::RE2" 
    ;
  */
    type RE2 = "::std::shared_ptr< ::re2::RE2>" 
      requires Cxx11_headers::memory,
      RE2_serial, encoder "RE2_encoder", decoder "RE2_decoder"
    ;
  
    gen _ctor_RE2 : string -> RE2 = "::std::shared_ptr< ::re2::RE2>(new RE2($1))";
  
  
    type StringPiece = "::re2::StringPiece";
      ctor StringPiece: &string = "::re2::StringPiece(*$1)"; // Argument must be reference to variable!
      ctor StringPiece: string = "::re2::StringPiece($1)"; // DANGEROUS DEPRECATE
      ctor StringPiece: unit = "::re2::StringPiece()";
      ctor StringPiece: StringPiece = "::re2::StringPiece($1)"; // copy constructor
      ctor StringPiece: +char * !ints = "::re2::StringPiece($1,$2)"; // array and length
      ctor StringPiece (x:varray[char]) => StringPiece(x.stl_begin,x.len);
      ctor string: StringPiece = "$1.as_string()";
      fun len: StringPiece -> size = "(size_t)$1.length()";
      fun data: StringPiece -> +char = "(char*)$1.data()"; // cast away const
   
   
      instance Container[StringPiece,char] {
        fun len: StringPiece -> size = "$1.size()";
      }
      instance Eq[StringPiece] {
        fun == : StringPiece * StringPiece -> bool = "$1==$2";
      }
      instance Tord[StringPiece] {
        fun < : StringPiece * StringPiece -> bool = "$1<$2";
      }
      instance Str[StringPiece] {
        fun str: StringPiece -> string ="$1.as_string()";
      }
  
    fun subscript (x:StringPiece, s:slice[int]):StringPiece =>
      match s with
      | #Slice_all => x
  
      | Slice_from (start) => 
        // unsafe, FIXME
        StringPiece (x.data + start.size, x.len.int - start)
  
      | Slice_to_incl (xend) =>
        // unsafe, FIXME
        StringPiece (x.data, xend + 1)
  
      | Slice_to_excl (xend) => 
        // unsafe, FIXME
        StringPiece (x.data, xend)
  
      | Slice_range_incl (start, xend) => 
        // unsafe, FIXME
        StringPiece (x.data + start.size, xend - start+1)
  
      | Slice_range_excl (start, xend) => 
        // unsafe, FIXME
        StringPiece (x.data + start, xend - start)
  
      | Slice_one (index) =>
        // unsafe, FIXME
        StringPiece (x.data + index, 1)
      endmatch
    ;
  
    type Arg = "::re2::Arg";
  
    type Encoding = "::re2::RE2::Encoding";
      const EncodingUTF8: Encoding = "::re2::RE2::EncodingUTF8";
      const EncodingLatin1: Encoding = "::re2::RE2::EncodingLatin1";
  
    type RE2Options = "::re2::RE2::Options";
  
      proc Copy: RE2Options * RE2Options = "$1.Copy($2);";
  
      fun encoding: RE2Options -> Encoding = "$1.encoding()";
      proc set_encoding: RE2Options * Encoding = "$1.set_encoding($2);";
      
      fun posix_syntax: RE2Options -> bool = "$1.posix_syntax()";
      proc set_posix_syntax: RE2Options * bool = "$1.set_posix_syntax($2);";
  
      fun longest_match: RE2Options -> bool = "$1.longest_match()";
      proc set_longest_match: RE2Options * bool = "$1.set_longest_match($2);";
      
      fun log_errors: RE2Options -> bool = "$1.log_errors()";
      proc set_log_errors: RE2Options * bool = "$1.set_log_errors($2);";
      
      fun max_mem: RE2Options -> int = "$1.max_mem()";
      proc set_max_mem: RE2Options * int = "$1.set_max_mem($2);";
      
      fun literal: RE2Options -> bool = "$1.literal()";
      proc set_literal: RE2Options * bool = "$1.set_literal($2);";
  
      fun never_nl: RE2Options -> bool = "$1.never_nl()";
      proc set_never_nl: RE2Options * bool = "$1.set_never_nl($2);";
      
      fun case_sensitive: RE2Options -> bool = "$1.case_sensitive()";
      proc set_case_sensitive: RE2Options * bool = "$1.set_case_sensitive($2);";
      
      fun perl_classes: RE2Options -> bool = "$1.perl_classes()";
      proc set_perl_classes: RE2Options * bool = "$1.set_perl_classes($2);";
      
      fun word_boundary: RE2Options -> bool = "$1.word_boundary()";
      proc set_word_boundary: RE2Options * bool = "$1.set_word_boundary($2);";
      
      fun one_line: RE2Options -> bool = "$1.one_line()";
      proc set_one_line: RE2Options * bool = "$1.set_one_line($2);";
  
      fun ParseFlags: RE2Options -> int = "$1.ParseFlags()";
     
    type ErrorCode = "::re2::RE2::ErrorCode";
      const NoError : ErrorCode = "::re2::RE2::NoError";
      const ErrorInternal: ErrorCode = "::re2::RE2::ErrorInternal";
      const ErrorBadEscape : ErrorCode = "::re2::RE2::ErrorBadEscape";
      const ErrorBadCharClass : ErrorCode = "::re2::RE2::ErrorBadCharClass";
      const ErrorBadCharRange : ErrorCode = "::re2::RE2::ErrorBadCharRange";
      const ErrorMissingBracket : ErrorCode = "::re2::RE2::ErrorMissingBracket";
      const ErrorMissingParen : ErrorCode = "::re2::RE2::ErrorMissingParen";
      const ErrorTrailingBackslash : ErrorCode = "::re2::RE2::ErrorTrailingBackslash";
      const ErrorRepeatArgument : ErrorCode = "::re2::RE2::ErrorRepeatArgument";
      const ErrorRepeatSize : ErrorCode = "::re2::RE2::ErrorRepeatSize";
      const ErrorRepeatOp: ErrorCode = "::re2::RE2::ErrorRepeatOp";
      const ErrorBadPerlOp: ErrorCode = "::re2::RE2::ErrprBadPerlOp";
      const ErrorBadUTF8: ErrorCode = "::re2::RE2::ErrorBadUTF8";
      const ErrorBadNamedCapture: ErrorCode = "::re2::RE2::ErrorBadNamedCapture";
      const ErrorPatternTooLarge: ErrorCode = "::re2::RE2::ErrorPatternTooLarge";
  
    type Anchor = "::re2::RE2::Anchor";
      const UNANCHORED: Anchor = "::re2::RE2::UNANCHORED";
      const ANCHOR_START: Anchor = "::re2::RE2::ANCHOR_START";
      const ANCHOR_BOTH: Anchor = "::re2::RE2::ANCHOR_BOTH";
  
    fun pattern: RE2 -> string = "$1->pattern()";
    instance Str[RE2] {
      fun str (r:RE2) => r.pattern;
    }
  
    fun error: RE2 -> string = "$1->error()";
    fun error_code: RE2 -> ErrorCode = "$1->error_code()";
    fun error_arg: RE2 -> string = "$1->error_arg()";
    fun ok: RE2 -> bool = "$1->ok()";
    fun ProgramSize: RE2 -> int = "$1->ProgramSize()";
  
    gen GlobalReplace: &string * RE2 * StringPiece -> int = "::re2::RE2::GlobalReplace($1, *$2, $3)";
    gen Extract: StringPiece * RE2 * StringPiece * &string -> bool = "::re2::RE2::Extract($1, *$2, $3, $4)";
  
    fun QuoteMeta: StringPiece -> string = "::re2::RE2::QuoteMeta($1)";
   
    fun PossibleMatchRange: RE2 * &string * &string * int -> bool = "$1->PossibleMatchRange($2,$3,$3,$4)";
    fun NumberOfCapturingGroups: RE2 -> int = "$1->NumberOfCapturingGroups()";
    fun NamedCapturingGroups: RE2 -> Stl_Map::stl_map[string, int] = "$1->NamedCapturingGroups()";
  
    // this function is fully general, just needs an anchor
    gen Match: RE2 * StringPiece * int * Anchor * +StringPiece * int -> bool = 
      "$1->Match($2, $3, $2.length(),$4, $5, $6)"
     ;
  
    noinline gen Match(re:RE2, var s:string) : opt[varray[string]] = {
      var emptystring = "";
      var n = NumberOfCapturingGroups re;
      var v = varray[StringPiece] (n.size+1,StringPiece emptystring);
      var Match-result = Match (re, StringPiece s, 0, ANCHOR_BOTH, v.stl_begin, n+1);
      return 
        if Match-result then
          Some$ map string of (StringPiece) v
        else 
          None[varray[string]]
      ;
    }
  
    gen apply (re:RE2, s:string) => Match (re,s);
  
    fun CheckRewriteString: RE2 * StringPiece * &string -> bool = "$1->CheckRewriteString($2, $3)";
  
    instance Set[RE2, string] {
      fun \in : string * RE2 -> bool =
        "$2->Match(::re2::StringPiece($1),0, ::re2::StringPiece($1).length(),::re2::RE2::ANCHOR_BOTH, (::re2::StringPiece*)0, 0)"
      ;
    }
  
    gen iterator (re2:string, var target:string) => iterator (RE2 re2, target);
  
    instance Iterable[RE2 * string, varray[string]] {
      gen iterator (r:RE2, var target:string) () : opt[varray[string]] = {
        var emptystring = "";
        var l = len target;
        var s = StringPiece target;
        var p1 = s.data;  
        var p = 0;
        var n = NumberOfCapturingGroups(r)+1;
        var v1 = varray[StringPiece] (n.size,StringPiece emptystring);
        var v2 = varray[string] (n.size,"");
      again:>
        var result = Match(r, s, p, UNANCHORED,v1.stl_begin, n);
        if not result goto endoff;
        for var i in 0 upto n - 1 do set(v2, i.size, string(v1.i)); done
        var p2 = v1.0.data;
        assert(v1.0.len.int > 0); // prevent infinite loop
        p = (p2 - p1).int+v1.0.len.int;
        yield Some v2;
        goto again;
      endoff:>
        return None[varray[string]];
      }
    }
    inherit Streamable[RE2 * string, Varray::varray[string]];
  
    // Extract Some match array or None if not matching.
    fun extract (re2:string, target:string) : opt[varray[string]] => iterator (RE2 re2, target) ();
    fun extract (re2:RE2, target:string) : opt[varray[string]] => iterator (re2, target) ();
  
  }
  
  open Set[RE2, string];
  
Regular definitions
===================



.. index:: Regdef(class)
.. index:: regex(union)
.. index:: ngrp(fun)
.. index:: render(fun)
.. code-block:: felix

  //[regdef.flx]
  
  class Regdef {
    union regex =
    | Alts of list[regex]
    | Seqs of list[regex]
    | Rpt of regex * int * int
    | Charset of string
    | String of string
    | Group of regex
    | Perl of string
    ;
  
    private fun prec: regex -> int =
    | Perl _ => 3
    | Alts _ => 3
    | Seqs _ => 2
    | String _ => 2
    | Rpt _ => 1
    | Charset _ => 0
    | Group _ => 0
    ;
  
    private fun hex_digit (i:int)=>
      if i<10 then string (char (ord (char "0") + i)) 
      else string (char (ord (char "A") + i - 10))
      endif
    ;
    private fun hex2(c:char)=>
      let i = ord c in
      "\\x" + hex_digit ( i / 16 ) + hex_digit ( i % 16 )
    ;
    private fun charset_quote(c:char)=>
      if c in "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstvuwxyz" then string c
      else hex2 c
      endif
    ;
  
    private fun hex(s:string when len s > 0uz)= {
      var r = ""; 
      for var i in 0uz upto len s - 1uz do
        r += charset_quote s.[i];
      done
      return r; 
    }
  
    fun ngrp (s:string)=> "(?:"+s+")";
    private fun cngrp (s:string, op: int, ip: int) => if ip > op then ngrp (s) else s endif; 
  
    fun render: regex -> string =
    | Alts rs => fold_left 
     (fun (acc:string) (elt:regex)=> 
       (if acc == "" then "" else acc + "|" endif) + (render elt)) 
      "" rs
    | Seqs rs => fold_left 
      (fun (acc:string) (elt:regex)=> acc + cngrp(render elt,2,prec elt))
      "" rs
    | Rpt (r,i,x) =>
      if i == 0 and x == -1 then ngrp (render r) + "*"
      elif i == 1 and x == -1 then ngrp (render r) + "+"
      elif i == 0 and x == 1 then ngrp (render r) + "?"
      else
        cngrp(render r,1,prec r) + "{" + str i + "," + if x < 0 then "" else str x endif + "}"
      endif
  
    | String s => hex(s)
    | Charset s => "[" + hex s + "]"
    | Group r => "(" + render r + ")"
    | Perl s => s
    ;
  }
  
Syntax
======



.. code-block:: felix

  //[regexps.fsyn]
  
  //$ Syntax for regular definitions.
  //$ Binds to library class Regdef,
  //$ which in turn binds to the binding of Google RE2.
  SCHEME """(define (regdef x) `(ast_lookup (,(noi 'Regdef) ,x ())))""";
  
  syntax regexps {
    priority 
      ralt_pri <
      rseq_pri <
      rpostfix_pri <
      ratom_pri
    ;
  
   
    //$ Regular definition binder.
    //$ Statement to name a regular expression.
    //$ The expression may contain names of previously named regular expressions.
    //$ Defines the LHS symbol as a value of type Regdef::regex.
    stmt := "regdef" sdeclname "=" sregexp[ralt_pri] ";" =># 
      """
      `(ast_val_decl ,_sr ,(first _2) ,(second _2) (some ,(regdef "regex" )) (some ,_4))
      """;
  
    //$ Inline regular expression.
    //$ Can be used anywhere in Felix code.
    //$ Returns a a value of type Regdef::regex.
    x[sapplication_pri] := "regexp" "(" sregexp[ralt_pri] ")" =># "_3";
  
    //$ Alternatives.
    private sregexp[ralt_pri] := sregexp[>ralt_pri] ("|" sregexp[>ralt_pri])+ =># 
      """`(ast_apply ,_sr (  
        ,(regdef "Alts")
        (ast_apply ,_sr (,(noi 'list) ,(cons _1 (map second _2))))))"""
    ;
  
    //$ Sequential concatenation.
    private sregexp[rseq_pri] := sregexp[>rseq_pri] (sregexp[>rseq_pri])+ =># 
      """`(ast_apply ,_sr ( 
        ,(regdef "Seqs")
        (ast_apply ,_sr (,(noi 'list) ,(cons _1 _2)))))"""
    ;
  
  
    //$ Postfix star (*).
    //$ Kleene closure: zero or more repetitions.
    private sregexp[rpostfix_pri] := sregexp[rpostfix_pri] "*" =># 
      """`(ast_apply ,_sr ( ,(regdef "Rpt") (,_1,0,-1)))"""
    ;
  
    //$ Postfix plus (+).
    //$ One or more repetitions.
    private sregexp[rpostfix_pri] := sregexp[rpostfix_pri] "+" =>#
      """`(ast_apply ,_sr ( ,(regdef "Rpt") (,_1,1,-1)))"""
    ;
  
    //$ Postfix question mark (?).
    //$ Optional. Zero or one repetitions.
    private sregexp[rpostfix_pri] := sregexp[rpostfix_pri] "?" =>#
      """`(ast_apply ,_sr (,(regdef "Rpt") (,_1,0,1)))"""
    ;
  
    //$ Parenthesis. Non-capturing group.
    private sregexp[ratom_pri] := "(" sregexp[ralt_pri] ")" =># "_2";
  
    //$ Group psuedo function.
    //$ Capturing group.
    private sregexp[ratom_pri] := "group" "(" sregexp[ralt_pri] ")" =># 
      """`(ast_apply ,_sr ( ,(regdef "Group") ,_3))"""
    ;
  
    //$ The charset prefix operator.
    //$ Treat the string as a set of characters,
    //$ that is, one of the contained characters.
    private sregexp[ratom_pri] := "charset" String =># 
      """`(ast_apply ,_sr ( ,(regdef "Charset") ,_2))"""
    ;
  
    //$ The string literal.
    //$ The given sequence of characters.
    //$ Any valid Felix string can be used here.
    private sregexp[ratom_pri] := String =># 
      """`(ast_apply ,_sr ( ,(regdef "String") ,_1)) """
    ;
  
    //$ The Perl psuedo function.
    //$ Treat the argument string expression as
    //$ a Perl regular expression, with constraints
    //$ as specified for Google RE2.
    private sregexp[ratom_pri] := "perl" "(" sexpr ")" =># 
      """`(ast_apply ,_sr ( ,(regdef "Perl") ,_3)) """
    ;
  
    //$ The regex psuedo function.
    //$ Treat the argument Felix expression of type Regdef::regex
    //$ as a regular expression.
    private sregexp[ratom_pri] := "regex" "(" sexpr ")" =># "_3";
  
    //$ Identifier.
    //$ Must name a previously defined variable of type Regdef:;regex.
    //$ For example, the LHS of a regdef binder.
    private sregexp[ratom_pri] := sname=># "`(ast_name ,_sr ,_1 ())";
   
  }
  
Lexer
=====



.. index:: Lexer(class)
.. index:: start_iterator(fun)
.. index:: end_iterator(fun)
.. index:: bounds(fun)
.. index:: string_between(fun)
.. index:: deref(fun)
.. code-block:: felix

  //[lexer.flx]
  class Lexer
  {
    pod type lex_iterator = "char const*";
    fun start_iterator : string -> lex_iterator = "$1.c_str()";
    fun end_iterator: string -> lex_iterator = "$1.c_str()+$1.size()";
    fun bounds (x:string): lex_iterator * lex_iterator = {
      return
        start_iterator x,
        end_iterator x
      ;
    }
    fun string_between: lex_iterator * lex_iterator -> string =
     "::std::string($1,$2)";
  
    fun + : lex_iterator * int -> lex_iterator = "$1 + $2";
    fun - : lex_iterator * int -> lex_iterator = "$1 - $2";
    fun - : lex_iterator * lex_iterator -> int = "$1 - $2";
    fun deref: lex_iterator -> char = "*$1";
  }
  
  instance Eq[Lexer::lex_iterator] {
    fun == :Lexer::lex_iterator * Lexer::lex_iterator -> bool = "$1==$2";
  }
  
  instance Tord[Lexer::lex_iterator] {
    fun < :Lexer::lex_iterator * Lexer::lex_iterator -> bool = "$1<$2";
  }
  
  open Eq[Lexer::lex_iterator];
  
Config
======


.. code-block:: fpc

  //[unix_re2.fpc]
  Name: Re2
  Description: Google Re2 regexp library
  provides_dlib: -lflx_re2_dynamic
  provides_slib: -lflx_re2_static
  includes: '"re2/re2.h"'
  library: flx_re2
  macros: BUILD_RE2
  srcdir: src/re2/re2
  headers: re2/(re2|set|stringpiece|variadic_function)\.h  
  src: re2/[^/]*\.cc|util/arena\.cc|util/hash\.cc|util/rune\.cc|util/stringpiece\.cc|util/strutil.cc|util/stringprintf\.cc|util/valgrind\.cc
  build_includes: src/re2/re2


.. code-block:: fpc

  //[win32_re2.fpc]
  Name: Re2
  Description: Google Re2 regexp library
  provides_dlib: /DEFAULTLIB:flx_re2_dynamic
  provides_slib: /DEFAULTLIB:flx_re2_static
  includes: '"re2/re2.h"'
  library: flx_re2
  macros: BUILD_RE2 WIN32 NOMINMAX
  srcdir: src\re2\re2
  headers: re2\\(re2|set|stringpiece|variadic_function)\.h  
  src: re2\\[^\\]*\.cc|util\\arena\.cc|util\\hash\.cc|util\\rune\.cc|util\\stringpiece\.cc|util\\strutil.cc|util\\stringprintf\.cc|util\\valgrind\.cc
  build_includes: src/re2/re2


.. code-block:: cpp

  //[flx_re2_config.hpp]
  #ifndef __FLX_RE2_CONFIG_H__
  #define __FLX_RE2_CONFIG_H__
  #include "flx_rtl_config.hpp"
  #ifdef BUILD_RE2
  #define RE2_EXTERN FLX_EXPORT
  #else
  #define RE2_EXTERN FLX_IMPORT
  #endif
  #endif




