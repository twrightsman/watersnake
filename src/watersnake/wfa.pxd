from libc.stdint cimport uint64_t, uint32_t
from posix.time cimport timespec


cdef extern from "alignment/cigar.h":
    int cigar_sprint(
        char* buffer,
        cigar_t* const cigar,
        const bint print_matches
    )

    ctypedef struct cigar_t:
        # Alignment operations
        char* operations         # Raw alignment operations
        int max_operations       # Maximum buffer size
        int begin_offset         # Begin offset
        int end_offset           # End offset
        # Score and end position (useful for partial alignments like Z-dropped)
        int score                # Computed scored
        int end_v                # Alignment-end vertical coordinate (pattern characters aligned)
        int end_h                # Alignment-end horizontal coordinate (text characters aligned)
        # CIGAR (SAM compliant)
        bint has_misms           # Show 'X' and '=', instead of  just 'M'
        uint32_t* cigar_buffer   # CIGAR-operations (max_operations length)
        int cigar_length         # Total CIGAR-operations


cdef extern from "wavefront/wavefront_bialigner.h":
    ctypedef struct wavefront_bialigner_t:
        pass


cdef extern from "wavefront/wavefront.h":
    ctypedef struct wavefront_pos_t:
        pass


cdef extern from "wavefront/wavefront_components.h":
    ctypedef struct wavefront_components_t:
        pass


cdef extern from "wavefront/wavefront_slab.h":
    ctypedef struct wavefront_slab_t:
        pass


cdef extern from "system/profiler_counter.h":
    ctypedef struct profiler_counter_t:
        uint64_t total
        uint64_t samples
        uint64_t min
        uint64_t max
        double m_oldM
        double m_newM
        double m_oldS
        double m_newS


cdef extern from "system/profiler_timer.h":
    ctypedef struct profiler_timer_t:
        # Timer
        timespec begin_timer     # Timer begin
        # Total time & samples taken
        profiler_counter_t time_ns
        uint64_t accumulated


cdef extern from "wavefront/wavefront_plot.h":
    ctypedef struct wavefront_plot_attr_t:
        bint enabled                # Is plotting enabled
        int resolution_points       # Total resolution points
        int align_level             # Level of recursion to plot (-1 == final)

    ctypedef struct wavefront_plot_t:
        pass


cdef extern from "wavefront/wavefront_heuristic.h":
    ctypedef enum wf_heuristic_strategy:
        wf_heuristic_none            = 0x0000000000000000ul
        wf_heuristic_banded_static   = 0x0000000000000001ul
        wf_heuristic_banded_adaptive = 0x0000000000000002ul
        wf_heuristic_wfadaptive      = 0x0000000000000004ul
        wf_heuristic_xdrop           = 0x0000000000000010ul
        wf_heuristic_zdrop           = 0x0000000000000020ul
        wf_heuristic_wfmash          = 0x0000000000000040ul

    ctypedef struct wavefront_heuristic_t:
        # Heuristic
        wf_heuristic_strategy strategy      # Heuristic strategy
        int steps_between_cutoffs           # Score-steps between heuristic cut-offs
        # Static/Adaptive Banded
        int min_k                           # Banded: Minimum k to consider in band
        int max_k                           # Banded: Maximum k to consider in band
        # WFAdaptive
        int min_wavefront_length            # Adaptive: Minimum wavefronts length to cut-off
        int max_distance_threshold          # Adaptive: Maximum distance between offsets allowed
        # Drops
        int xdrop                           # X-drop parameter
        int zdrop                           # Z-drop parameter
        # Internals
        int steps_wait                      # Score-steps until next cut-off
        int max_sw_score                    # Maximum swg-score observed (for x/z drops)
        int max_wf_score                    # Corresponding wf-score (to max_sw_score)
        int max_sw_score_offset             # Offset of the maximum score observed
        int max_sw_score_k                  # Diagonal of the maximum score observed


cdef extern from "alignment/affine2p_penalties.h":
    ctypedef struct affine2p_matrix_type:
        pass

    ctypedef struct affine2p_penalties_t:
        int match              # (Penalty representation; usually M <= 0)
        int mismatch           # (Penalty representation; usually X > 0)
        # Usually concave; Q1 + E1 < Q2 + E2 and E1 > E2.
        int gap_opening1       # (Penalty representation; usually O1 > 0)
        int gap_extension1     # (Penalty representation; usually E1 > 0)
        int gap_opening2       # (Penalty representation; usually O2 > 0)
        int gap_extension2     # (Penalty representation; usually E2 > 0)


cdef extern from "alignment/affine_penalties.h":
    ctypedef struct affine_penalties_t:
        int match               # (Penalty representation; usually M <= 0)
        int mismatch            # (Penalty representation; usually X > 0)
        int gap_opening         # (Penalty representation; usually O > 0)
        int gap_extension       # (Penalty representation; usually E > 0)


cdef extern from "alignment/linear_penalties.h":
    ctypedef struct linear_penalties_t:
        int match           # (Penalty representation; usually M <= 0)
        int mismatch        # (Penalty representation; usually X > 0)
        int indel           # (Penalty representation; usually I > 0)


cdef extern from "wavefront/wavefront_penalties.h":
    ctypedef enum distance_metric_t:
        indel         = 0  # Longest Common Subsequence - LCS
        edit          = 1  # Levenshtein
        gap_linear    = 2  # Needleman-Wunsch
        gap_affine    = 3  # Smith-Waterman-Gotoh
        gap_affine_2p = 4  # Gap-Affine 2-pieces

    ctypedef struct wavefront_penalties_t:
        pass


cdef extern from "wavefront/wavefront_attributes.h":
    ctypedef int (*alignment_match_funct_t)(int, int, void*)

    ctypedef struct alignment_system_t:
        # Limits
        int max_alignment_score        # Maximum score allowed before quit
        # Probing intervals
        int probe_interval_global      # Score-ticks interval to check any limits
        int probe_interval_compact     # Score-ticks interval to check BT-buffer compacting
        # Memory
        uint64_t max_partial_compacts  # Maximum partial-compacts before attempting full-compact
        uint64_t max_memory_compact    # Maximum BT-buffer memory allowed before trigger compact
        uint64_t max_memory_resident   # Maximum memory allowed to be buffered before reap
        uint64_t max_memory_abort      # Maximum memory allowed to be used before aborting alignment
        # Verbose
        #  0 - Quiet
        #  1 - Report each sequence aligned                      (brief)
        #  2 - Report each sequence/subsequence aligned          (brief)
        #  3 - Report WFA progress (heavy tasks)                 (verbose)
        #  4 - Full report of each sequence/subsequence aligned  (very verbose)
        int verbose                    # Verbose (regulates messages during alignment)
        # Debug
        bint check_alignment_correct   # Verify that the alignment CIGAR output is correct
        # Profile
        profiler_timer_t timer         # Time alignment
        # OS
        int max_num_threads            # Maximum number of threads to use to compute/extend WFs
        int min_offsets_per_thread     # Minimum amount of offsets to spawn a thread

    ctypedef enum alignment_scope_t:
        compute_score,           # Only distance/score
        compute_alignment        # Full alignment CIGAR

    ctypedef enum alignment_span_t:
        alignment_end2end        # End-to-end alignment (aka global)
        alignment_endsfree       # Ends-free alignment  (semiglobal, glocal, etc)

    ctypedef struct alignment_form_t:
        # Mode
        alignment_span_t span    # Alignment form (End-to-end/Ends-free)
        # Extension
        bint extension           # Activate extension-like alignment
        # Ends-free
        int pattern_begin_free   # Allow free-gap at the beginning of the pattern
        int pattern_end_free     # Allow free-gap at the end of the pattern
        int text_begin_free      # Allow free-gap at the beginning of the text
        int text_end_free        # Allow free-gap at the end of the text

    ctypedef enum wavefront_memory_t:
        wavefront_memory_high     = 0  # High-memore mode (fastest, stores all WFs explicitly)
        wavefront_memory_med      = 1  # Succing-memory mode piggyback-based (medium, offloads half-full BT-blocks)
        wavefront_memory_low      = 2  # Succing-memory mode piggyback-based (slow, offloads only full BT-blocks)
        wavefront_memory_ultralow = 3  # Bidirectional WFA

    ctypedef struct wavefront_aligner_attr_t:
        # Distance model
        distance_metric_t distance_metric        # Alignment metric/distance used
        alignment_scope_t alignment_scope        # Alignment scope (score only or full-CIGAR)
        alignment_form_t alignment_form          # Alignment mode (end-to-end/ends-free)
        # Penalties
        linear_penalties_t linear_penalties      # Gap-linear penalties (placeholder)
        affine_penalties_t affine_penalties      # Gap-affine penalties (placeholder)
        affine2p_penalties_t affine2p_penalties  # Gap-affine-2p penalties (placeholder)
        # Heuristic strategy
        wavefront_heuristic_t heuristic          # Wavefront heuristic
        # Memory model
        wavefront_memory_t memory_mode           # Wavefront memory strategy (modular wavefronts and piggyback)
        # Custom function to compare sequences
        alignment_match_funct_t match_funct      # Custom matching function (match(v,h,args))
        void* match_funct_arguments              # Generic arguments passed to matching function (args)
        # External MM (instead of allocating one inside)
        mm_allocator_t* mm_allocator             # MM-Allocator
        # Display
        wavefront_plot_attr_t plot               # Plot wavefront
        # System
        alignment_system_t system                # System related parameters


cdef extern from "system/mm_allocator.h":
    ctypedef struct mm_allocator_t:
        pass


cdef extern from "utils/string_padded.h":
    ctypedef struct strings_padded_t:
        pass


cdef extern from "wavefront/wfa.h":
    cdef enum wavefront_align_mode_t:
        wf_align_regular = 0
        wf_align_biwfa = 1
        wf_align_biwfa_breakpoint_forward = 2
        wf_align_biwfa_breakpoint_reverse = 3
        wf_align_biwfa_subsidiary = 4

    ctypedef struct wavefront_align_status_t:
        # Status
        int status                                                      # Status code
        int score                                                       # Current WF-alignment score
        int num_null_steps                                              # Total contiguous null-steps performed
        uint64_t memory_used                                            # Total memory used
        # Wavefront alignment functions
        void (*wf_align_compute)(wavefront_aligner_t* const, const int) # WF Compute function
        int (*wf_align_extend)(wavefront_aligner_t* const, const int)   # WF Extend function

    ctypedef struct wavefront_aligner_t:
        # Mode and status
        wavefront_align_mode_t align_mode           # WFA alignment mode
        char* align_mode_tag                        # WFA mode tag
        wavefront_align_status_t align_status       # Current alignment status
        # Sequences
        strings_padded_t* sequences                 # Padded sequences
        char* pattern                               # Pattern sequence (padded)
        int pattern_length                          # Pattern length
        char* text                                  # Text sequence (padded)
        int text_length                             # Text length
        # Custom function to compare sequences
        alignment_match_funct_t match_funct         # Custom matching function (match(v,h,args))
        void* match_funct_arguments                 # Generic arguments passed to matching function (args)
        # Alignment Attributes
        alignment_scope_t alignment_scope           # Alignment scope (score only or full-CIGAR)
        alignment_form_t alignment_form             # Alignment form (end-to-end/ends-free)
        wavefront_penalties_t penalties             # Alignment penalties
        wavefront_heuristic_t heuristic             # Heuristic's parameters
        wavefront_memory_t memory_mode              # Wavefront memory strategy (modular wavefronts and piggyback)
        # Wavefront components
        wavefront_components_t wf_components        # Wavefront components
        affine2p_matrix_type component_begin        # Alignment begin component
        affine2p_matrix_type component_end          # Alignment end component
        wavefront_pos_t alignment_end_pos           # Alignment end position
        # Bidirectional Alignment
        wavefront_bialigner_t* bialigner            # BiWFA aligner
        # CIGAR
        cigar_t* cigar                              # Alignment CIGAR
        # MM
        bint mm_allocator_own                       # Ownership of MM-Allocator
        mm_allocator_t* mm_allocator                # MM-Allocator
        wavefront_slab_t* wavefront_slab            # MM-Wavefront-Slab (Allocates/Reuses the individual wavefronts)
        # Display
        wavefront_plot_t* plot                      # Wavefront plot
        # System
        alignment_system_t system                   # System related parameters

    wavefront_aligner_t* wavefront_aligner_new(wavefront_aligner_attr_t* attributes)
    void wavefront_aligner_delete(wavefront_aligner_t* const wf_aligner)


cdef extern from "wavefront/wavefront_align.h":
    int wavefront_align(
        wavefront_aligner_t* const wf_aligner,
        const char* const pattern,
        const int pattern_length,
        const char* const text,
        const int text_length
    )
