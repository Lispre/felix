Package: src/packages/embed.fdoc


===========================
Driver Embedding Technology
===========================

==================== ===================================
key                  file                                
==================== ===================================
flx_world_config.hpp share/lib/rtl/flx_world_config.hpp  
flx_world_config.cpp share/src/rtl/flx_world_config.cpp  
flx_world.hpp        share/lib/rtl/flx_world.hpp         
flx_world.cpp        share/src/rtl/flx_world.cpp         
flx_async_world.hpp  share/lib/rtl/flx_async_world.hpp   
flx_async_world.cpp  share/src/rtl/flx_async_world.cpp   
flx_async.hpp        share/lib/rtl/flx_async.hpp         
flx_async.cpp        share/src/flx_async/flx_async.cpp   
flx_async.py         $PWD/buildsystem/flx_async.py       
unix_flx_async.fpc   $PWD/src/config/unix/flx_async.fpc  
win32_flx_async.fpc  $PWD/src/config/win32/flx_async.fpc 
==================== ===================================



Embedding
=========

This technology is designed to allow Felix to be embedded in any
C or C++ program or library.

The embedding library code is used by the core drivers.


The  :code:`flx_config` class.
------------------------------

The  :code:`flx_config` class is used to store configuration
data used by subsequent initialisation steps
used to initiate a Felix world.


.. index:: RTL_EXTERN(class)
.. index:: def(type)
.. index:: def(type)
.. index:: def(type)
.. code-block:: cpp

  //[flx_world_config.hpp]
  
  #ifndef __flx_world_config_H_
  #define __flx_world_config_H_
  
  #include "flx_rtl_config.hpp"
  #include "flx_gc.hpp"
  #include "flx_collector.hpp"
  #include "flx_dynlink.hpp"
  
  // for async_sched
  #include <list>
  #include "flx_async.hpp"
  #include "flx_sync.hpp"
  
  namespace flx { namespace run {
  
  class RTL_EXTERN flx_config {
  public:
    bool  debug;
  
    bool debug_threads;
    bool debug_allocations;
    bool debug_collections;
    bool report_collections;
    bool report_gcstats;
  
    bool debug_driver;
    bool finalise;
  
    size_t gc_freq;
    size_t min_mem;
    size_t max_mem;
    int gcthreads;
  
    double free_factor;
  
    bool allow_collection_anywhere;
  
    bool static_link;
    char *filename; // expected to live forever
    char **flx_argv;
    int flx_argc;
  
    // TODO: fn up in macro area
    int init(int argc, char **argv);
  
  // interface for drivers. there's more, create_frame, etc
    create_async_hooker_t *ptr_create_async_hooker=nullptr;
  
    typedef ::flx::dynlink::flx_dynlink_t *(*link_library_t)(flx_config *c, ::flx::gc::generic::gc_profile_t*);
    typedef void (*init_ptr_create_async_hooker_t)(flx_config *, bool debug_driver);
    typedef int (*get_flx_args_config_t)(int argc, char **argv, flx_config* c);
  
    link_library_t link_library;
    init_ptr_create_async_hooker_t init_ptr_create_async_hooker;
    get_flx_args_config_t get_flx_args_config;
  
    flx_config (link_library_t, init_ptr_create_async_hooker_t, get_flx_args_config_t); 
  
  
  };
  
  }} // namespaces
  #endif



.. code-block:: cpp

  //[flx_world_config.cpp]
  
  #include "flx_world_config.hpp"
  #include <cstdlib>
  
  static double egetv(char const *name, double dflt)
  {
    char *env = ::std::getenv(name);
    double val = env?::std::atof(env):dflt;
    return val;
  }
  
  namespace flx { namespace run {
  
  // =================================================================
  // // Constructor
  // =================================================================
  flx_config::flx_config 
  (
    link_library_t link_library_arg,
    init_ptr_create_async_hooker_t init_ptr_create_async_hooker_arg,
    get_flx_args_config_t get_flx_args_config_arg
  ) :
    link_library(link_library_arg),
    init_ptr_create_async_hooker(init_ptr_create_async_hooker_arg),
    get_flx_args_config(get_flx_args_config_arg)
  {
    //fprintf(stderr,"flx_config constrfuctor\n");
  }
  
  // =================================================================
  // Initialiser
  // =================================================================
  
  int
  flx_config::init(int argc, char **argv) {
    if(get_flx_args_config(argc, argv, this)) return 1;
  
    debug = (bool)egetv("FLX_DEBUG", debug);
    if (debug) {
      fprintf(stderr,
        "[FLX_DEBUG] Debug enabled for %s link program\n",
        static_link ? "static" : "dynamic");
    }
  
    debug_threads = (bool)egetv("FLX_DEBUG_THREADS", debug);
    if (debug_threads) {
      fprintf(stderr, "[FLX_DEBUG_THREADS] Threads debug enabled\n");
    }
  
    debug_allocations = (bool)egetv("FLX_DEBUG_ALLOCATIONS", debug);
    if (debug_allocations) {
      fprintf(stderr, "[FLX_DEBUG_ALLOCATIONS] Allocation debug enabled\n");
    }
  
    debug_collections = (bool)egetv("FLX_DEBUG_COLLECTIONS", debug);
    if (debug_collections)
    {
      fprintf(stderr, "[FLX_DEBUG_COLLECTIONS] Collection debug enabled\n");
    }
  
    report_collections = (bool)egetv("FLX_REPORT_COLLECTIONS", debug);
    if (report_collections)
    {
      fprintf(stderr, "[FLX_REPORT_COLLECTIONS] Collection report enabled\n");
    }
  
    report_gcstats = (bool)egetv("FLX_REPORT_GCSTATS", report_collections);
    if (report_collections)
    {
      fprintf(stderr, "[FLX_REPORT_GCSTATS] GC statistics report enabled\n");
    }
  
  
    debug_driver = (bool)egetv("FLX_DEBUG_DRIVER", debug);
    if (debug_driver)
    {
      fprintf(stderr, "[FLX_DEBUG_DRIVER] Driver debug enabled\n");
    }
  
    finalise = (bool)egetv("FLX_FINALISE", 0);
    if (debug)
      fprintf(stderr,
        "[FLX_FINALISE] Finalisation %s\n", finalise ? "Enabled" : "Disabled");
  
    // default collection frequency is 1000 interations
    gc_freq = (size_t)egetv("FLX_GC_FREQ", 1000);
    if (gc_freq < 1) gc_freq = 1;
    if (debug)
      fprintf(stderr, "[FLX_GC_FREQ] call gc every %zu iterations\n", gc_freq);
  
    // default min mem is 10 Meg
    min_mem = (size_t)(egetv("FLX_MIN_MEM", 10) * 1000000.0);
    if (debug)
      fprintf(stderr, "[FLX_MIN_MEM] call gc only if more than %zu Meg heap used\n", min_mem/1000000);
  
    // default max mem is unlimited
    max_mem = (size_t)(egetv("FLX_MAX_MEM", 0) * 1000000.0);
    if (max_mem == 0) max_mem = (size_t)-1;
    if (debug)
      fprintf(stderr, "[FLX_MAX_MEM] terminate if more than %zu Meg heap used\n", max_mem/1000000);
  
    // default free factor is 10%, this is also the minimum allowed
    free_factor = egetv("FLX_FREE_FACTOR", 1.1);
    if (free_factor < 1.1) free_factor = 1.1;
    if (debug)
      fprintf(stderr, "[FLX_FREE_FACTOR] reset gc trigger %4.2f times heap used after collection\n", free_factor);
  
    // experimental flag to allow collection anywhere
    // later, we default this one to true if we can
    // find all the thread stacks, which should be possible
    // with gcc and probably msvc++
  
    allow_collection_anywhere = (bool)egetv("FLX_ALLOW_COLLECTION_ANYWHERE", 1);
    if (debug)
      fprintf(stderr, "[FLX_ALLOW_COLLECTION_ANYWHERE] %s\n", allow_collection_anywhere ? "True" : "False");
  
    gcthreads = (int)egetv("FLX_GCTHREADS",0);
    if (debug)
      fprintf(stderr, "[FLX_GCTHREADS] %d\n",gcthreads);
  
    if (debug) {
      for (int i=0; i<flx_argc; ++i)
        fprintf(stderr, "flx_argv[%d]->%s\n", i, flx_argv[i]);
    }
    return 0;
  }
  
  }} // namespaces
  
The  :code:`flx_world` class.
-----------------------------

Objects of the  :code:`flx_world` class are used to represent
a Felix world.

.. index:: RTL_EXTERN(class)
.. index:: async_sched(struct)
.. code-block:: cpp

  //[flx_world.hpp]
  
  #ifndef __flx_world_H_
  #define __flx_world_H_
  #include "flx_rtl_config.hpp"
  
  #include "flx_gc.hpp"
  #include "flx_collector.hpp"
  #include "flx_dynlink.hpp"
  
  // for async_sched
  #include <list>
  #include "flx_async.hpp"
  #include "flx_sync.hpp"
  #include "flx_world_config.hpp"
  #include "flx_async_world.hpp"
  
  namespace flx { namespace run {
  
  class RTL_EXTERN flx_world {
    bool debug;
    bool debug_driver;
  
    ::flx::gc::generic::allocator_t *allocator;
  
    ::flx::gc::collector::flx_collector_t *collector;
  
    ::flx::gc::generic::gc_profile_t *gcp;
  
    ::flx::dynlink::flx_dynlink_t *library;
    ::flx::dynlink::flx_libinst_t *instance;
  
    struct async_sched *async_scheduler;
  
    int explicit_dtor();
  public:
    flx_config *c;
    flx_world(flx_config *); 
    int setup(int argc, char **argv);
  
    int teardown();
  
    // add/remove (current pthread, stack pointer) for garbage collection
    void begin_flx_code();
    void end_flx_code();
  
    // returns number of pending operations scheduled by svc_general
    // return error code < 0 otherwise
    // catches all known exceptions
    int run_until_blocked();
    int run_until_complete();
  
    void* ptf()const { return instance->thread_frame; }	// for creating con_t
  
    void spawn_fthread(::flx::rtl::con_t *top);
  
    void external_multi_swrite (::flx::rtl::schannel_t *chan, void *data);
  
    async_sched *get_async_scheduler()const { return async_scheduler; }
    sync_sched *get_sync_scheduler()const { return &async_scheduler->ss; }
  };
  
  
  }} // namespaces
  #endif //__flx_world_H_



.. code-block:: cpp

  //[flx_world.cpp]
  
  #include "flx_world.hpp"
  #include "flx_eh.hpp"
  #include "flx_ts_collector.hpp"
  #include "flx_rtl.hpp"
  
  using namespace ::std;
  using namespace ::flx::rtl;
  using namespace ::flx::pthread;
  using namespace ::flx::run;
  
  namespace flx { namespace run {
  
  // terminates process!
  // Not called by default (let the OS clean up)
  
  static int do_final_cleanup(
    bool debug_driver,
    flx::gc::generic::gc_profile_t *gcp,
    ::flx::dynlink::flx_dynlink_t *library,
    ::flx::dynlink::flx_libinst_t *instance
  )
  {
    flx::gc::generic::collector_t *collector = gcp->collector;
  
    // garbage collect application objects
    {
      if (debug_driver || gcp->debug_collections)
        fprintf(stderr, "[do_final_cleanup] Finalisation: pass 1 Data collection starts ..\n");
  
      size_t n = collector->collect();
      size_t a = collector->get_allocation_count();
  
      if (debug_driver || gcp->debug_collections)
        fprintf(stderr, "[do_final_cleanup] flx_run collected %zu objects, %zu left\n", n, a);
    }
  
    // garbage collect system objects
    {
      if (debug_driver || gcp->debug_collections)
        fprintf(stderr, "[do_final_cleanup] Finalisation: pass 2 Final collection starts ..\n");
  
      collector->free_all_mem();
      size_t a = collector->get_allocation_count();
  
      if (debug_driver || gcp->debug_collections)
        fprintf(stderr, "[do_final_cleanup] Remaining %zu objects (should be 0)\n", a);
  
      if (a != 0){
        fprintf(stderr, "[do_final_cleanup] flx_run %zu uncollected objects, should be zero!! return code 5\n", a);
        return 5;
      }
    }
  
    if (debug_driver)
      fprintf(stderr, "[do_final_cleanup] exit 0\n");
  
    return 0;
  }
  
  static void *get_stack_pointer() { void *x=(void*)&x; return x; }
  
  // RUN A FELIX INSTANCE IN THE CURRENT PTHREAD
  //
  // CURRENTLY ONLY CALLED ONCE IN MAIN THREAD
  // RETURNS A LIST OF FTHREADS
  // 
  
  static std::list<fthread_t*>*
  run_felix_pthread_ctor(
    flx::gc::generic::gc_profile_t *gcp,
    ::flx::dynlink::flx_libinst_t *instance)
  {
    //fprintf(stderr, "run_felix_pthread_ctor -- the MAIN THREAD: library instance: %p\n", instance);
    flx::gc::generic::collector_t *collector = gcp->collector;
    std::list<fthread_t*> *active = new std::list<fthread_t*>;
  
    {
      con_t *top = instance->main_proc;
      //fprintf(stderr, "  ** MAIN THREAD: flx_main entry point : %p\n", top);
      if (top)
      {
        fthread_t *flx_main = new (*gcp, _fthread_ptr_map, false) fthread_t(top);
        collector->add_root(flx_main);
        active->push_front(flx_main);
      }
    }
  
    {
      con_t *top = instance->start_proc;
      //fprintf(stderr, "  ** MAIN THREAD: flx_start (initialisation) entry point : %p\n", top);
      if (top)
      {
        fthread_t *ft = new (*gcp, _fthread_ptr_map, false) fthread_t(top);
        collector->add_root(ft);
        active->push_front(ft);
      }
    }
    return active;
  }
  
  static void run_felix_pthread_dtor(
    bool debug_driver,
    flx::gc::generic::gc_profile_t *gcp,
    ::flx::dynlink::flx_dynlink_t *library,
    ::flx::dynlink::flx_libinst_t *instance
  )
  {
    if (debug_driver)
      fprintf(stderr, "[run_felix_pthread_dtor] MAIN THREAD FINISHED: waiting for other threads\n");
  
    gcp->collector->get_thread_control()->join_all();
  
    if (debug_driver) 
      fprintf(stderr, "[run_felix_pthread_dtor] ALL THREADS DEAD: mainline cleanup!\n");
  
    if (debug_driver) {
      flx::gc::generic::collector_t *collector = gcp->collector;
  
      size_t uncollected = collector->get_allocation_count();
      size_t roots = collector->get_root_count();
      fprintf(stderr,
        "[run_felix_pthread_dtor] program finished, %zu collections, %zu uncollected objects, roots %zu\n",
        gcp->collections, uncollected, roots);
    }
    gcp->collector->remove_root(instance);
  
    if (gcp->finalise)
      (void)do_final_cleanup(debug_driver, gcp, library, instance);
  
    if (debug_driver) 
      fprintf(stderr, "[run_felix_pthread_dtor] mainline cleanup complete, exit\n");
     
  }
  
  // construct from flx_config pointer
  flx_world::flx_world(flx_config *c_arg) : c(c_arg) {}
  
  int flx_world::setup(int argc, char **argv) {
    int res;
    if((res = c->init(argc, argv) != 0)) return res;
  
    debug = c->debug;
    if(debug)
      fprintf(stderr, "[flx_world: setup]\n");
    debug_driver = c->debug_driver;
  
    if(debug)
      fprintf(stderr, "[flx_world: setup] Created allocator\n");
    allocator = new flx::gc::collector::malloc_free();
    allocator->set_debug(c->debug_allocations);
  
    char *tracecmd = getenv("FLX_TRACE_ALLOCATIONS");
    if(tracecmd && strlen(tracecmd)>0) {
       FILE *f = fopen(tracecmd,"w");
       if(f) {
         fprintf(stderr, "Allocation tracing active, file = %s\n",tracecmd);
         allocator = new flx::gc::collector::tracing_allocator(f,allocator);
       }
       else 
         fprintf(stderr, "Unable to open allocation trace file %s for output (ignored)\n",tracecmd);
    }
  
    // previous direct ctor scope ended at closing brace of FLX_MAIN
    // but delete can probably be moved up after collector delete (also used by explicit_dtor)
    ::flx::pthread::thread_control_t *thread_control = new ::flx::pthread::thread_control_t(c->debug_threads);
    if(debug)
      fprintf(stderr, "[flx_world: setup] Created thread control object\n");
  
    // NB: !FLX_SUPPORT_ASYNC refers to async IO, hence ts still needed thanks to flx pthreads
    FILE *tracefile = NULL;
    {
      char *tracecmd = getenv("FLX_TRACE_GC");
      if(tracecmd && strlen(tracecmd)>0) {
        tracefile = fopen(tracecmd,"w");
        if(tracefile) 
          fprintf(stderr, "GC tracing active, file = %s\n",tracecmd);
      }
    }
  
    collector = new flx::gc::collector::flx_ts_collector_t(
      allocator, 
      thread_control, 
      c->gcthreads, tracefile
    );
    collector->set_debug(c->debug_collections, c->report_gcstats);
    if(debug)
      fprintf(stderr, "[flx_world: setup] Created ts collector\n");
  
    gcp = new flx::gc::generic::gc_profile_t(
      c->debug_driver,
      c->debug_allocations,
      c->debug_collections,
      c->report_collections,
      c->report_gcstats,
      c->allow_collection_anywhere,
      c->gc_freq,
      c->min_mem,
      c->max_mem,
      c->free_factor,
      c->finalise,
      collector
    );
  
    if(debug)
      fprintf(stderr, "[flx_world: setup] Created gc profile object\n");
  
    library = c->link_library(c,gcp);
    collector->add_root (library);
  
    if(debug)
      fprintf(stderr, "[flx_world: setup] Created library object\n");
  
    if (debug_driver)
    {
      fprintf(stderr, "[flx_world:setup] flx_run driver begins argv[0]=%s\n", c->flx_argv[0]);
      for (int i=1; i<argc-1; ++i)
        fprintf(stderr, "[flx_world:setup]                       argv[%d]=%s\n", i,c->flx_argv[i]);
    }
  
    // flx_libinst_t::create can run code, so add thread to avoid world_stop abort
    thread_control->add_thread(get_stack_pointer());
  
    // Create the usercode driver instance
    // NB: seems to destroy()ed in do_final_cleanup
    instance = new (*gcp, ::flx::dynlink::flx_libinst_ptr_map, false) ::flx::dynlink::flx_libinst_t(debug_driver);
    collector->add_root(instance);
    instance->create(
      library,
      gcp,
      c->flx_argc,
      c->flx_argv,
      stdin,
      stdout,
      stderr,
      debug_driver);
  
    thread_control->remove_thread();
  
    if (debug_driver) {
      fprintf(stderr, "[flx_world:setup] loaded library %s at %p\n", c->filename, library->library);
      fprintf(stderr, "[flx_world:setup] thread frame at %p\n", instance->thread_frame);
      fprintf(stderr, "[flx_world:setup] initial continuation at %p\n", instance->start_proc);
      fprintf(stderr, "[flx_world:setup] main continuation at %p\n", instance->main_proc);
      fprintf(stderr, "[flx_world:setup] creating async scheduler\n");
    }
  
    auto schedlist = run_felix_pthread_ctor(gcp, instance);
  
    async_scheduler = new async_sched(
      this,
      debug_driver,
      gcp, schedlist
      ); // deletes active for us!
  
    return 0;
  }
  
  int flx_world::explicit_dtor()
  {
    if (debug_driver)
      fprintf(stderr, "[explicit_dtor] entry\n");
  
    run_felix_pthread_dtor(debug_driver, gcp, library, instance);
  
    if (gcp->finalise)
    {
      if (debug_driver)
        fprintf(stderr, "[explicit_dtor] flx_run driver ends with finalisation complete\n");
    }
    else
    {
      if (debug_driver || gcp->debug_collections)
      {
        size_t a = gcp->collector->get_allocation_count();
        fprintf(stderr,
          "[explicit_dtor] flx_run driver ends with finalisation skipped, %zu uncollected "
            "objects\n", a);
      }
    }
  
    if (debug_driver)
      fprintf(stderr, "[explicit_dtor] exit 0\n");
  
    return 0;
  }
  
  int flx_world::teardown() {
    if (debug_driver)
      fprintf(stderr, "[teardown] entry\n");
  
    collector->get_thread_control()->add_thread(get_stack_pointer());
  
    delete async_scheduler;
  
    if (debug_driver)
      fprintf(stderr, "[teardown] deleted async_scheduler\n");
  
  
    // could this override error_exit_code if something throws?
    int error_exit_code = explicit_dtor();
    if (debug_driver)
      fprintf(stderr,"[teardown] explicit dtor run code %d\n", error_exit_code);
  
    thread_control_base_t *thread_control = collector->get_thread_control();
  
    instance=0;
    library=0;
    if (debug_driver)
      fprintf(stderr,"[teardown] library & instance NULLED\n");
  
    // And we're done, so start cleaning up.
    delete gcp;
  
    delete collector;
    if (debug_driver) 
      fprintf(stderr,"[teardown] collector deleted\n");
  
    delete allocator;
    if (debug_driver) 
      fprintf(stderr,"[teardown] allocator deleted\n");
  
    if (debug_driver) 
      fprintf(stderr, "[teardown] flx_run driver ends code=%d\n", error_exit_code);
  
    delete thread_control;  // RF: cautiously delete here
    if (debug_driver) 
      fprintf(stderr,"[teardown] thread control deleted\n");
    return error_exit_code;
  }
  
  void flx_world::begin_flx_code() {
    collector->get_thread_control() -> add_thread(get_stack_pointer());
  }
  
  void flx_world::end_flx_code() {
    collector->get_thread_control()->remove_thread();
  }
  
  // returns number of pending operations scheduled by svc_general
  // return error code < 0 otherwise
  // catches all known exceptions
  //
  int flx_world::run_until_blocked() {
    // this may not be called on the same thread, so let thread control know
    // when we exit, main thread is not running so pthreads can garbage collect without waiting for us
  
    try {
      return async_scheduler->prun(async_sched::ret);
    }
    catch (flx_exception_t &x) { return - flx_exception_handler (&x); }
    catch (std::exception &x) { return - std_exception_handler (&x); }
    catch (int &x) { fprintf (stderr, "Exception type int: %d\n", x); return -x; }
    catch (::std::string &x) { fprintf (stderr, "Exception type string : %s\n", x.c_str()); return -1; }
    catch (::flx::rtl::con_t &x) { fprintf (stderr, "Rogue continuatiuon caught\n"); return -6; }
    catch (...) { fprintf(stderr, "[flx_world:run_until_blocked] Unknown exception in thread!\n"); return -5; }
  }
  
  int flx_world::run_until_complete () {
    // this may not be called on the same thread, so let thread control know
    // when we exit, main thread is not running so pthreads can garbage collect without waiting for us
  
    try {
      return async_scheduler->prun(async_sched::block);
    }
    catch (flx_exception_t &x) { return - flx_exception_handler (&x); }
    catch (std::exception &x) { return - std_exception_handler (&x); }
    catch (int &x) { fprintf (stderr, "Exception type int: %d\n", x); return -x; }
    catch (::std::string &x) { fprintf (stderr, "Exception type string : %s\n", x.c_str()); return -1; }
    catch (::flx::rtl::con_t &x) { fprintf (stderr, "Rogue continuatiuon caught\n"); return -6; }
    catch (...) { fprintf(stderr, "[flx_world:run_until_complete] Unknown exception in thread!\n"); return -5; }
  }
  
  
  // TODO: factor into async_sched. run_felix_pthread_ctor does this twice
  void flx_world::spawn_fthread(con_t *top) {
  	fthread_t *ft = new (*gcp, _fthread_ptr_map, false) fthread_t(top);
    get_sync_scheduler()->push_new(ft);
  }
  
  void flx_world::external_multi_swrite (schannel_t *chan, void *data) 
  {
    async_scheduler->external_multi_swrite (chan,data);
  } 
  
  }} // namespaces
  
The Asychronous Support System
------------------------------


.. index:: flx_world(struct)
.. code-block:: cpp

  //[flx_async_world.hpp]
  
  #ifndef __flx_async_world_H_
  #define __flx_async_world_H_
  
  #include "flx_gc.hpp"
  #include "flx_collector.hpp"
  #include "flx_sync.hpp"
  
  namespace flx { namespace run {
  
  // This class handles pthreads and asynchronous I/O
  // It shares operations with sync_sched by interleaving
  // based on state variables.
  //
  struct async_sched
  {
    enum block_flag_t {block, ret};
  
    struct flx_world *world;
    bool debug_driver;
    ::flx::gc::generic::gc_profile_t *gcp;
    ::std::list< ::flx::rtl::fthread_t*> *active;
  
    size_t async_count;
    async_hooker* async;
    sync_sched ss;  // (d, gcp, active), (ft, request), (pc, fs)
  
    async_sched(
      flx_world *world_arg, 
      bool d, 
      ::flx::gc::generic::gc_profile_t *g, 
      ::std::list< ::flx::rtl::fthread_t*> *a
    ) : 
      world(world_arg), 
      debug_driver(d), 
      gcp(g), 
      active(a), 
      async_count(0),
      async(NULL),
      ss(debug_driver, gcp, active)
    {}
  
    ~async_sched();
  
    int prun(block_flag_t);
    void do_spawn_pthread();
    void do_general();
  
    void external_multi_swrite(::flx::rtl::schannel_t *, void *data);
  private:
    bool schedule_queued_fthreads(block_flag_t);
  };
  
  
  }} // namespaces
  #endif //__flx_async_world_H_



.. code-block:: cpp

  //[flx_async_world.cpp ]
  
  
  #include "flx_world.hpp"
  #include "flx_async_world.hpp"
  #include "flx_sync.hpp"
  
  using namespace ::flx::rtl;
  using namespace ::flx::pthread;
  
  namespace flx { namespace run {
  
  static void prun_pthread_entry(void *data) {
    async_sched *d = (async_sched*)data;
    d->prun(async_sched::block);
    delete d;
  }
  
  // SPAWNING A NEW FELIX PTHREAD
  // CREATES ITS OWN PRIVATE ASYNC SCHEDULER 
  // CREATES ITS OWN PRIVATE SYNC SCHEDULER
  // SHARES WORLD INCLUDING COLLECTOR
  // REGISTERS IN THREAD_CONTROL
  void async_sched::do_spawn_pthread()
  {
    fthread_t *ftx = *(fthread_t**)ss.request->data;
    if (debug_driver)
      fprintf(stderr, "[prun: spawn_pthread] Spawn pthread %p\n", ftx);
    gcp->collector->add_root(ftx);
    std::list<fthread_t*> *pactive = new std::list<fthread_t*>;
    pactive->push_front(ftx);
    void *data = new async_sched(world,debug_driver, gcp, pactive);
    flx_detached_thread_t dummy;
  
    if (debug_driver)
      fprintf(stderr, "[prun: spawn_pthread] Starting new pthread, thread counter= %zu\n",
        gcp->collector->get_thread_control()->thread_count());
  
    {
      ::std::mutex spawner_lock;
      ::std::condition_variable_any spawner_cond;
      bool spawner_flag = false;
      ::std::unique_lock< ::std::mutex> locktite(spawner_lock);
      dummy.init(prun_pthread_entry, data, gcp->collector->get_thread_control(), 
        &spawner_lock, &spawner_cond,
        &spawner_flag
      );
  
      if (debug_driver)
        fprintf(stderr,
          "[prun: spawn_pthread] Thread %p waiting for spawned thread to register itself\n",
          (void*)get_current_native_thread());
  
      while (!spawner_flag)
        spawner_cond.wait(spawner_lock);
  
      if (debug_driver)
        fprintf(stderr,
          "[prun: spawn_pthread] Thread %p notes spawned thread has registered itself\n",
          (void*)get_current_native_thread());
    }
  }
  
  void async_sched::do_general()
  {
    if (debug_driver)
      fprintf(stderr, "[prun: svc_general] from fthread=%p\n", ss.ft);
  
    if(debug_driver)
      fprintf(stderr, "[prun: svc_general] async=%p, ptr_create_async_hooker=%p\n", 
        async,
        world->c->ptr_create_async_hooker)
      ;
    if (!async) 
    {
      if(debug_driver)
        fprintf(stderr,"[prun: svc_general] trying to create async system..\n");
  
      if (world->c->ptr_create_async_hooker == NULL) {
        if(debug_driver)
          fprintf(stderr,"[prun: svc_general] trying to create async hooker..\n");
        world->c->init_ptr_create_async_hooker(world->c,debug_driver);
      }
      // Error out if we don't have the hooker function.
      if (world->c->ptr_create_async_hooker == NULL) {
        fprintf(stderr,
          "[prun: svc_general] Unable to initialise async I/O system: terminating\n");
        exit(1);
      }
  
      // CREATE A NEW ASYNCHRONOUS EVENT MANAGER
      // DONE ON DEMAND ONLY
      async = (*world->c->ptr_create_async_hooker)(
        gcp->collector->get_thread_control(), // thread_control object
        20000, // bound on resumable thread queue
        50,    // bound on general input job queue
        2,     // number of threads in job pool
        50,    // bound on async fileio job queue
        1      // number of threads doing async fileio
      );
    }
    ++async_count;
    if (debug_driver)
      fprintf(stderr,
         "[prun: svc_general] Async system created: %p, count %zu\n",async,async_count);
    // CHANGED TO USE NEW UNION LAYOUT RULES
    // One less level of indirection for pointers
    // void *dreq =  *(void**)ss.request->data;
    void *dreq =  (void*)ss.request->data;
    if (debug_driver)
      fprintf(stderr, "[prun: svc_general] Request object %p\n", dreq);
  
    // requests are now ALWAYS considered asynchronous
    // even if the request handler reschedules them immediately
    async->handle_request(dreq, ss.ft);
    if (debug_driver)
      fprintf(stderr, "[prun: svc_general] Request object %p captured fthread %p \n", dreq, ss.ft);
    if (debug_driver)
      fprintf(stderr, "[prun: svc_general] Request object %p\n", dreq);
    ss.ft = 0; // drop current without unrooting
    if(debug_driver)
      fprintf(stderr,"[prun: svc_general] request dispatched..\n");
  }
  
  
  int async_sched::prun(block_flag_t block_flag) {
  sync_run:
      // RUN SYNCHRONOUS SCHEDULER
      if (debug_driver)
        fprintf(stderr, "prun: sync_run\n");
  
      if (debug_driver)
        fprintf(stderr, "prun: Before running: Sync state is %s\n",
          ss.get_fpc_desc());
  
      sync_sched::fstate_t fs = ss.frun();
  
      if (debug_driver)
        fprintf(stderr, "prun: After running: Sync state is %s/%s\n",
          ss.get_fstate_desc(fs), ss.get_fpc_desc());
  
      switch(fs)
      {
        // HANDLE DELEGATED SERVICE REQUESTS
        case sync_sched::delegated:
          if (debug_driver)
            fprintf(stderr, "sync_sched:delegated request %d\n", ss.request->variant);
          switch (ss.request->variant) 
          {
            case svc_spawn_pthread: do_spawn_pthread(); goto sync_run;
  
            case svc_general: do_general(); goto sync_run;
  
            default:
              fprintf(stderr,
                "prun: Unknown service request code 0x%4x\n", ss.request->variant);
              abort();
          }
  
        // SCHEDULE ANY ASYNCHRONOUSLY QUEUED FTHREADS
        case sync_sched::blocked: // ran out of active threads - are there any in the async queue?
          if(schedule_queued_fthreads(block_flag)) goto sync_run;
          break;
        default:
          fprintf(stderr, "prun: Unknown frun return status 0x%4x\n", fs);
          abort();
      }
  
    // TEMPORARILY OUT OF JOBS TO DO
    if (debug_driver)
      fprintf(stderr, "prun: Out of ready jobs, %zu pending\n", async_count);
    return async_count;
  }
  
  bool async_sched::schedule_queued_fthreads(block_flag_t block_flag) {
    if (debug_driver) {
      fprintf(stderr,
        "prun: out of active synchronous threads, trying async, pending=%zu\n", async_count);
    }
    int scheduled_some = 0;
    if (async && async_count > 0) {
      if (block_flag==block)
      {
        fthread_t* ftp = async->dequeue();
        if (debug_driver)
          fprintf(stderr, "prun: block mode: Async Retrieving fthread %p\n", ftp);
  
        ss.push_old(ftp);
        --async_count;
        ++scheduled_some;
      }
      else
      {
        fthread_t* ftp = async->maybe_dequeue();
        while (ftp) {
          if (debug_driver)
            fprintf(stderr, "prun:ret mode: Async Retrieving fthread %p\n", ftp);
  
          ss.push_old(ftp);
          --async_count;
          ++scheduled_some;
          ftp = async->maybe_dequeue();
        }
      }
    }
    if (debug_driver)
      fprintf(stderr, "prun: Async returning: scheduled %d, pending=%zu\n", scheduled_some, async_count);
    return scheduled_some != 0;
  }
  
  void async_sched::external_multi_swrite(::flx::rtl::schannel_t *chan, void *data)
    {
      ss.external_multi_swrite (chan,data);
    }
  
  async_sched::~async_sched() {
    try
    {
      if (debug_driver)
        fprintf(stderr, "prun: Terminating Felix subsystem\n");
      delete async;
      delete active;
    }
    catch (...) { fprintf(stderr, "Unknown exception deleting async!\n"); }
  }
  
  }} // namespaces
  
The Asynchronous I/O interface.
-------------------------------

The embedding system depends on the interface but
not the implementation.
 

.. index:: ASYNC_EXTERN(class)
.. index:: ASYNC_EXTERN(class)
.. index:: ASYNC_EXTERN(class)
.. code-block:: cpp

  //[flx_async.hpp]
  #ifndef __FLX_ASYNC_H__
  #define __FLX_ASYNC_H__
  #include "flx_rtl_config.hpp"
  #include "flx_rtl.hpp"
  #include "pthread_bound_queue.hpp"
  
  #ifdef BUILD_ASYNC
  #define ASYNC_EXTERN FLX_EXPORT
  #else
  #define ASYNC_EXTERN FLX_IMPORT
  #endif
  
  // GLOBAL NAMESPACE!
  
  class ASYNC_EXTERN async_hooker {
  public:
    virtual flx::rtl::fthread_t *dequeue()=0;
    virtual flx::rtl::fthread_t *maybe_dequeue()=0;
    virtual void handle_request(void *data, flx::rtl::fthread_t *ss)=0;
    virtual ~async_hooker();
  };
  
  typedef
  async_hooker *
  create_async_hooker_t
  (
    ::flx::pthread::thread_control_base_t*,
    int n0,   // bound on resumable thread queue
    int n1,   // bound on general input job queue
    int m1,   // number of threads in job pool
    int n2,   // bound on async fileio job queue
    int m2    // number of threads doing async fileio
  );
  
  extern "C" {
  ASYNC_EXTERN async_hooker *
  create_async_hooker
  (
    ::flx::pthread::thread_control_base_t*,
    int n0,   // bound on resumable thread queue
    int n1,   // bound on general input job queue
    int m1,   // number of threads in job pool
    int n2,   // bound on async fileio job queue
    int m2    // number of threads doing async fileio
  );
  }
  
  namespace flx { namespace async {
  struct ASYNC_EXTERN finote_t
  {
    virtual void signal()=0;
    virtual ~finote_t();
  };
  
  class ASYNC_EXTERN wakeup_fthread_t : public finote_t
  {
    ::flx::rtl::fthread_t *f;
    ::flx::pthread::bound_queue_t *q;
  public:
    wakeup_fthread_t(::flx::pthread::bound_queue_t *q_a, ::flx::rtl::fthread_t *f_a);
    void signal () { q->enqueue(f); }
  };
  
  
  class ASYNC_EXTERN flx_driver_request_base {
      finote_t *fn;
      virtual bool start_async_op_impl() = 0;
  public:
      flx_driver_request_base();
      virtual ~flx_driver_request_base(); // so destructors work
  
      // returns finished flag (async may fail or immediately finish)
      void start_async_op(finote_t *fn_a);
      void notify_finished();
  };
  
  }}
  
  #endif


.. index:: async_hooker_impl(class)
.. index:: proto_async(class)
.. code-block:: cpp

  //[flx_async.cpp]
  #include "flx_async.hpp"
  #include "pthread_bound_queue.hpp"
  #include "flx_rtl.hpp"
  #include <cassert>
  #include <stdio.h>
  
  using namespace ::flx::rtl;
  using namespace ::flx::pthread;
  using namespace ::flx::async;
  
  async_hooker::~async_hooker(){ }
  
  namespace flx { namespace async {
  
  // FINISHED NOTIFIER
  finote_t::~finote_t(){}
  
  // DERIVED NOTIFIER WHICH DOES FTHREAD WAKEUP
  // BY ENQUEUING THE FTHREAD INTO THE READY QUEUE 
  wakeup_fthread_t::wakeup_fthread_t(
    ::flx::pthread::bound_queue_t *q_a, 
    ::flx::rtl::fthread_t *f_a) 
  : f(f_a), q(q_a) {}
  
  // ASYNC HOOKER IMPLEMENTATION STAGE 1
  // Introduces new virtual get_ready_queue().
  class async_hooker_impl : public async_hooker {
  public:
    virtual bound_queue_t *get_ready_queue()=0;
    ~async_hooker_impl() {}
    void handle_request(void *data,fthread_t *ss)
    {
      flx::async::flx_driver_request_base* dreq =
            (flx::async::flx_driver_request_base*)data
      ;
      finote_t *fn = new wakeup_fthread_t(get_ready_queue(),ss);
      dreq->start_async_op(fn);
    }
  };
  
  
  // ASYNC HOOKER IMPLEMENTATION STAGE 2
  // Provides the ready queue and the dequeuing operations
  class proto_async : public async_hooker_impl
  {
      bound_queue_t async_ready;
  
  public:
     proto_async(thread_control_base_t *tc, int n0, int n1, int m1, int n2, int m2) :
       async_ready(tc,n0)
     {}
  
    ~proto_async(){}
  
    bound_queue_t *get_ready_queue() { return &async_ready; }
  
    fthread_t* dequeue()
    {
      return (fthread_t*)async_ready.dequeue();
    }
    fthread_t* maybe_dequeue()
    {
      return (fthread_t*)async_ready.maybe_dequeue();
    }
  };
  
  
  // DRIVER REQUEST BASE
  // THIS IS USED TO BUILD REQUESTS
  // PROVIDES DEFAULT NOTIFY_FINISHED ROUTINE WHICH USE FINOTE SIGNAL
  // DO ASYNC OP JUST CALLS DRIVED CLASS DO_ASYNC_OP_IMPL
  flx_driver_request_base::flx_driver_request_base() : fn(0) {}
  flx_driver_request_base::~flx_driver_request_base() {}       // so destructors work
  
  void flx_driver_request_base:: start_async_op(finote_t *fn_a)
  {
    //fprintf(stderr,"start async op %p, set fn = %p\n",this,fn_a);
    assert(fn==0);
    fn = fn_a;
    bool completed =  start_async_op_impl();
    if(completed)
    {
      fprintf(stderr,"instant complete\n");
      notify_finished();
    }
    else
    {
      //fprintf(stderr,"Pending\n");
    }
  }
  
  void flx_driver_request_base:: notify_finished()
  {
    //fprintf(stderr, "faio_req=%p, Notify finished %p\n", this,fn);
    assert(fn!=0);
    finote_t *fin = fn;
    fn=0;
    fin->signal();
    delete fin;
    //fprintf(stderr, "faio_req=%p, FINISHED\n",this);
  }
  
  }}
  
  async_hooker *create_async_hooker(thread_control_base_t *tc, int n0,int n1,int m1,int n2,int m2) {
    return new ::flx::async::proto_async(tc,n0,n1,m1,n2,m2);
  }
  
  


Config
======


.. code-block:: fpc

  //[unix_flx_async.fpc]
  Name: flx_async
  Description: Async hook
  provides_dlib: -lflx_async_dynamic
  provides_slib: -lflx_async_static
  includes: '"flx_async.hpp"'
  Requires: flx_pthread flx_gc flx 
  macros: BUILD_ASYNC
  library: flx_async
  srcdir: src/flx_async
  src: .*\.cpp


.. code-block:: fpc

  //[win32_flx_async.fpc]
  Name: flx_async
  Description: Async hook
  provides_dlib: /DEFAULTLIB:flx_async_dynamic
  provides_slib: /DEFAULTLIB:flx_async_static
  includes: '"flx_async.hpp"'
  Requires: flx_pthread flx_gc flx 
  macros: BUILD_ASYNC
  library: flx_async
  srcdir: src/flx_async
  src: .*\.cpp


.. code-block:: python

  #[flx_async.py]
  import fbuild
  from fbuild.functools import call
  from fbuild.path import Path
  from fbuild.record import Record
  from fbuild.builders.file import copy
  
  import buildsystem
  
  # ------------------------------------------------------------------------------
  
  def build_runtime(phase):
      path = Path (phase.ctx.buildroot/'share'/'src/flx_async')
      #buildsystem.copy_hpps_to_rtl(phase.ctx,
      #    path / 'flx_async.hpp',
      #)
  
      dst = 'host/lib/rtl/flx_async'
      suffix = '.so'
      srcs = [phase.ctx.buildroot/'share'/'src/flx_async/flx_async.cpp']
      includes = [
          phase.ctx.buildroot / 'host/lib/rtl',
          phase.ctx.buildroot / 'share/lib/rtl'
      ]
      macros = ['BUILD_ASYNC']
      libs = [
          call('buildsystem.flx_pthread.build_runtime', phase),
          call('buildsystem.flx_gc.build_runtime', phase),
      ]
  
      return Record(
          static=buildsystem.build_cxx_static_lib(phase, dst, srcs,
              includes=includes,
              macros=macros,
              libs=[lib.static for lib in libs]),
          shared=buildsystem.build_cxx_shared_lib(phase, dst, srcs,
              includes=includes,
              macros=macros,
              libs=[lib.shared for lib in libs]))




