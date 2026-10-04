/*
 * MD4C: Markdown parser for C
 * (https://github.com/mity/md4c)
 *
 * Copyright (c) 2016-2026 Martin Mitáš
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#ifndef ENRMRKD_HTML_H
#define ENRMRKD_HTML_H

#include "enrmrkd.h"

#ifdef __cplusplus
    extern "C" {
#endif


/* If set, debug output from enrmrkd_parse() is sent to stderr. */
#define ENRMRKD_HTML_FLAG_DEBUG                  0x0001
#define ENRMRKD_HTML_FLAG_VERBATIM_ENTITIES      0x0002
#define ENRMRKD_HTML_FLAG_SKIP_UTF8_BOM          0x0004
#define ENRMRKD_HTML_FLAG_XHTML                  0x0008


/* Render Markdown into HTML.
 *
 * Note only contents of <body> tag is generated. Caller must generate
 * HTML header/footer manually before/after calling enrmrkd_html().
 *
 * Params input and input_size specify the Markdown input.
 * Callback process_output() gets called with chunks of HTML output.
 * (Typical implementation may just output the bytes to a file or append to
 * some buffer).
 * Param userdata is just propagated back to process_output() callback.
 * Param parser_flags are flags from enrmrkd.h propagated to enrmrkd_parse().
 * Param render_flags is bitmask of ENRMRKD_HTML_FLAG_xxxx.
 *
 * Returns -1 on error (if enrmrkd_parse() fails.)
 * Returns 0 on success.
 */
int enrmrkd_html(const ENRMRKD_CHAR* input, ENRMRKD_SIZE input_size,
            void (*process_output)(const ENRMRKD_CHAR*, ENRMRKD_SIZE, void*),
            void* userdata, unsigned parser_flags, unsigned renderer_flags);


#ifdef __cplusplus
    }  /* extern "C" { */
#endif

#endif  /* ENRMRKD_HTML_H */
