#!/usr/bin/env perl
#
# Rename the public MD4C API surface to this fork's ENRMRKD_ / enrmrkd_ prefix.
#
# This fork is embedded into applications (react-native-enriched-markdown) which
# may link another copy of MD4C at the same time. Keeping upstream's global
# names would mean duplicate symbols at link time and ambiguous `md4c.h` lookups
# in header maps, so everything a consumer can see is prefixed; file-local
# statics inside the parser keep their upstream names to keep merges from
# upstream manageable.
#
# The script is idempotent and re-runnable: after merging new code from
# mity/md4c, run it to normalize whatever came in with upstream names.
#
# Usage: perl scripts/rename-upstream-symbols.pl [file...]
#        (with no arguments, all tracked sources and docs are processed)

use strict;
use warnings;

# Public identifiers of the MD_ namespace, i.e. everything declared by the
# public headers. Anything not listed here is file-local and stays as upstream.
my @public_md = qw(
    MD_ALIGN MD_ALIGN_CENTER MD_ALIGN_DEFAULT MD_ALIGN_LEFT MD_ALIGN_RIGHT
    MD_ATTRIBUTE
    MD_BLOCKTYPE
    MD_BLOCK_ADMONITION MD_BLOCK_ADMONITION_DETAIL
    MD_BLOCK_BLANK MD_BLOCK_BLANK_DETAIL
    MD_BLOCK_CODE MD_BLOCK_CODE_DETAIL
    MD_BLOCK_DOC
    MD_BLOCK_FOOTNOTE_DEF MD_BLOCK_FOOTNOTE_DEF_DETAIL MD_BLOCK_FOOTNOTE_DEF_SECTION
    MD_BLOCK_H MD_BLOCK_H_DETAIL MD_BLOCK_HR MD_BLOCK_HTML
    MD_BLOCK_LI MD_BLOCK_LI_DETAIL
    MD_BLOCK_OL MD_BLOCK_OL_DETAIL
    MD_BLOCK_P MD_BLOCK_QUOTE
    MD_BLOCK_TABLE MD_BLOCK_TABLE_DETAIL MD_BLOCK_TBODY
    MD_BLOCK_TD MD_BLOCK_TD_DETAIL MD_BLOCK_TH MD_BLOCK_THEAD MD_BLOCK_TR
    MD_BLOCK_UL MD_BLOCK_UL_DETAIL
    MD_CHAR MD_OFFSET MD_SIZE
    MD_DIALECT_COMMONMARK MD_DIALECT_GITHUB
    MD_FLAG_ADMONITIONS MD_FLAG_COLLAPSEWHITESPACE MD_FLAG_FOOTNOTES
    MD_FLAG_HARD_SOFT_BREAKS MD_FLAG_HIGHLIGHT MD_FLAG_INSERT
    MD_FLAG_LATEXMATHSPANS MD_FLAG_NOHTML MD_FLAG_NOHTMLBLOCKS
    MD_FLAG_NOHTMLSPANS MD_FLAG_NOINDENTEDCODEBLOCKS
    MD_FLAG_PERMISSIVEATXHEADERS MD_FLAG_PERMISSIVEAUTOLINKS
    MD_FLAG_PERMISSIVEEMAILAUTOLINKS MD_FLAG_PERMISSIVEURLAUTOLINKS
    MD_FLAG_PERMISSIVEWWWAUTOLINKS MD_FLAG_PRESERVEBLANKLINES
    MD_FLAG_SPOILERS MD_FLAG_STRIKETHROUGH MD_FLAG_SUBSCRIPTS
    MD_FLAG_SUPERSCRIPTS MD_FLAG_TABLES MD_FLAG_TASKLISTS MD_FLAG_UNDERLINE
    MD_FLAG_WIKILINKS MD_FLAG_xxxx
    MD_HTML_FLAG_DEBUG MD_HTML_FLAG_SKIP_UTF8_BOM MD_HTML_FLAG_VERBATIM_ENTITIES
    MD_HTML_FLAG_XHTML MD_HTML_FLAG_xxxx
    MD_PARSER MD_RENDERER
    MD_SPANTYPE
    MD_SPAN_A MD_SPAN_A_DETAIL MD_SPAN_CODE MD_SPAN_DEL MD_SPAN_EM
    MD_SPAN_FOOTNOTE_REF MD_SPAN_FOOTNOTE_REF_DETAIL
    MD_SPAN_IMG MD_SPAN_IMG_DETAIL MD_SPAN_INS
    MD_SPAN_LATEXMATH MD_SPAN_LATEXMATH_DISPLAY MD_SPAN_MARK MD_SPAN_SPOILER
    MD_SPAN_STRONG MD_SPAN_SUBSCRIPT MD_SPAN_SUPERSCRIPT MD_SPAN_U
    MD_SPAN_WIKILINK MD_SPAN_WIKILINK_DETAIL
    MD_TEXTTYPE
    MD_TEXT MD_TEXT_BR MD_TEXT_CODE MD_TEXT_ENTITY MD_TEXT_HTML
    MD_TEXT_LATEXMATH MD_TEXT_NORMAL MD_TEXT_NULLCHAR MD_TEXT_SOFTBR
);

my @map;
push @map, [$_, 'ENRMRKD_' . substr($_, 3)] for @public_md;

push @map,
    # Build-time configuration macros and include guards.
    ['MD4C_USE_UTF8',  'ENRMRKD_USE_UTF8'],
    ['MD4C_USE_UTF16', 'ENRMRKD_USE_UTF16'],
    ['MD4C_USE_ASCII', 'ENRMRKD_USE_ASCII'],
    ['MD4C_HTML_H',    'ENRMRKD_HTML_H'],
    ['MD4C_ENTITY_H',  'ENRMRKD_ENTITY_H'],
    ['MD4C_H',         'ENRMRKD_H'],
    # Exported functions and the HTML entity table's types.
    ['md_parse',       'enrmrkd_parse'],
    ['md_html',        'enrmrkd_html'],
    ['entity_lookup',  'enrmrkd_entity_lookup'],
    ['ENTITY_MAP',     'ENRMRKD_ENTITY_MAP'],
    ['ENTITY_tag',     'ENRMRKD_ENTITY_tag'],
    ['ENTITY',         'ENRMRKD_ENTITY'],
    # File names, as referenced by #include lines, docs and linker flags.
    ['md4c-html\.\[hc\]', 'enrmrkd-html.[hc]'],
    ['md4c\.\[hc\]',      'enrmrkd.[hc]'],
    ['entity\.\[hc\]',    'enrmrkd-entity.[hc]'],
    ['md4c-html\.h',   'enrmrkd-html.h'],
    ['md4c-html\.c',   'enrmrkd-html.c'],
    ['md4c\.h',        'enrmrkd.h'],
    ['md4c\.c',        'enrmrkd.c'],
    ['entity\.h',      'enrmrkd-entity.h'],
    ['entity\.c',      'enrmrkd-entity.c'],
    ['-lmd4c-html',    '-lenrmrkd-html'],
    ['-lmd4c',         '-lenrmrkd'],
    ;

my @files = @ARGV;
if(!@files) {
    @files = glob('src/*.c src/*.h md2html/*.c md2html/*.h md2html/*.1'
                  . ' test/embedded/*.cpp test/fuzzers/*.c'
                  . ' test/spec*.txt test/coverage.txt'
                  . ' scripts/build_entity_map.py README.md');
}

for my $file (@files) {
    open(my $fh, '<', $file) or die "$file: $!";
    my $text = do { local $/; <$fh> };
    close($fh);

    my $orig = $text;
    for my $rule (@map) {
        my ($from, $to) = @$rule;
        # Word-ish boundaries that also work for patterns ending in a
        # bracket or starting with a dash (e.g. "md4c.[hc]", "-lmd4c").
        $text =~ s/(?<!\w)$from(?!\w)/$to/g;
    }
    next if $text eq $orig;

    open($fh, '>', $file) or die "$file: $!";
    print $fh $text;
    close($fh);
    print "renamed in $file\n";
}
