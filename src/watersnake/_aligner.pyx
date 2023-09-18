from libc.limits cimport INT_MAX
from libc.stdint cimport UINT64_MAX
from libc.stdlib cimport malloc, free
from libc.string cimport strlen

cimport watersnake.wfa as wfa

from copy import copy


cdef class Aligner:
    cdef wfa.wavefront_aligner_attr_t _c_attributes
    cdef wfa.wavefront_aligner_t* _c_aligner

    def __cinit__(self):
        self._c_attributes = wfa.wavefront_aligner_attr_t(
            distance_metric = wfa.distance_metric_t.gap_affine,
            alignment_scope = wfa.alignment_scope_t.compute_alignment,
            alignment_form = wfa.alignment_form_t(
                span = wfa.alignment_span_t.alignment_end2end,
                pattern_begin_free = 0,
                pattern_end_free = 0,
                text_begin_free = 0,
                text_end_free = 0
            ),
            match_funct = NULL,
            match_funct_arguments = NULL,
            linear_penalties = wfa.linear_penalties_t(
                match = 0,
                mismatch = 4,
                indel = 2
            ),
            affine_penalties = wfa.affine_penalties_t(
                match = 0,
                mismatch = 4,
                gap_opening = 6,
                gap_extension = 2
            ),
            affine2p_penalties = wfa.affine2p_penalties_t(
                match = 0,
                mismatch = 4,
                gap_opening1 = 6,
                gap_extension1 = 2,
                gap_opening2 = 24,
                gap_extension2 = 1
            ),
            heuristic = wfa.wavefront_heuristic_t(
                strategy = wfa.wf_heuristic_strategy.wf_heuristic_wfadaptive,
                min_wavefront_length = 10,
                max_distance_threshold = 50,
                steps_between_cutoffs = 1
            ),
            memory_mode = wfa.wavefront_memory_t.wavefront_memory_high,
            mm_allocator = NULL,
            plot = wfa.wavefront_plot_attr_t(
                enabled = False,
                resolution_points = 2000,
                align_level = 0
            ),
            system = wfa.alignment_system_t(
                max_alignment_score = INT_MAX,  # Unlimited
                probe_interval_global = 3000,
                probe_interval_compact = 6000,
                max_memory_compact = -1,  # Automatic, based on memory mode
                max_memory_resident = -1,  # Automatic, based on memory mode
                max_memory_abort = UINT64_MAX,  # Unlimited
                verbose = 0,
                check_alignment_correct = False,
                max_num_threads = 1,  # Single thread by default,
                min_offsets_per_thread = 500  # Minimum WF-length to spawn a thread
            )
        )

        self._c_aligner = wfa.wavefront_aligner_new(&self._c_attributes)

        if self._c_aligner is NULL:
            raise MemoryError()

    def __dealloc__(self):
        if self._c_aligner is not NULL:
            wfa.wavefront_aligner_delete(self._c_aligner)

    def align(self, pattern: str, text: str) -> str:
        pattern_bytes = pattern.encode('ascii')
        text_bytes = text.encode('ascii')

        wfa.wavefront_align(
            wf_aligner = self._c_aligner,
            pattern = pattern_bytes,
            pattern_length = strlen(pattern_bytes),
            text = text_bytes,
            text_length = strlen(text_bytes)
        )

        cdef size_t cigar_buffer_size = <size_t> self._c_aligner.cigar.max_operations + 1
        cigar_buffer_memory = malloc(cigar_buffer_size * sizeof(char))
        if not cigar_buffer_memory:
            raise MemoryError()
        cigar_buffer = <char *> cigar_buffer_memory

        wfa.cigar_sprint(
            buffer = cigar_buffer,
            cigar = self._c_aligner.cigar,
            print_matches = True
        )

        cigar_bytes = <bytes> cigar_buffer
        cigar = cigar_buffer.decode('ascii')
        free(cigar_buffer_memory)

        return cigar
