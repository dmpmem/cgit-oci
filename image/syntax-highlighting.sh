#!/bin/sh
# This script can be used to implement syntax highlighting in the cgit
# tree-view by referring to this file with the source-filter or repo.source-
# filter options in cgitrc.
#
# This script requires a shell supporting the ${var##pattern} syntax.
# It is supported by at least dash and bash, however busybox environments
# might have to use an external call to sed instead.
#
# Note: the highlight command (http://www.andre-simon.de/) uses css for syntax
# highlighting, so you'll probably want something like the following included
# in your css file:
#
# Style definition file generated by highlight 2.4.8, http://www.andre-simon.de/
#
# table.blob .num  { color:#2928ff; }
# table.blob .esc  { color:#ff00ff; }
# table.blob .str  { color:#ff0000; }
# table.blob .dstr { color:#818100; }
# table.blob .slc  { color:#838183; font-style:italic; }
# table.blob .com  { color:#838183; font-style:italic; }
# table.blob .dir  { color:#008200; }
# table.blob .sym  { color:#000000; }
# table.blob .kwa  { color:#000000; font-weight:bold; }
# table.blob .kwb  { color:#830000; }
# table.blob .kwc  { color:#000000; font-weight:bold; }
# table.blob .kwd  { color:#010181; }
#
#
# Style definition file generated by highlight 2.6.14, http://www.andre-simon.de/
#
# body.hl  { background-color:#ffffff; }
# pre.hl   { color:#000000; background-color:#ffffff; font-size:10pt; font-family:'Courier New';}
# .hl.num  { color:#2928ff; }
# .hl.esc  { color:#ff00ff; }
# .hl.str  { color:#ff0000; }
# .hl.dstr { color:#818100; }
# .hl.slc  { color:#838183; font-style:italic; }
# .hl.com  { color:#838183; font-style:italic; }
# .hl.dir  { color:#008200; }
# .hl.sym  { color:#000000; }
# .hl.line { color:#555555; }
# .hl.mark { background-color:#ffffbb;}
# .hl.kwa  { color:#000000; font-weight:bold; }
# .hl.kwb  { color:#830000; }
# .hl.kwc  { color:#000000; font-weight:bold; }
# .hl.kwd  { color:#010181; }
#
#
# Style definition file generated by highlight 3.8, http://www.andre-simon.de/
#
# body.hl { background-color:#e0eaee; }
# pre.hl  { color:#000000; background-color:#e0eaee; font-size:10pt; font-family:'Courier New';}
# .hl.num { color:#b07e00; }
# .hl.esc { color:#ff00ff; }
# .hl.str { color:#bf0303; }
# .hl.pps { color:#818100; }
# .hl.slc { color:#838183; font-style:italic; }
# .hl.com { color:#838183; font-style:italic; }
# .hl.ppc { color:#008200; }
# .hl.opt { color:#000000; }
# .hl.lin { color:#555555; }
# .hl.kwa { color:#000000; font-weight:bold; }
# .hl.kwb { color:#0057ae; }
# .hl.kwc { color:#000000; font-weight:bold; }
# .hl.kwd { color:#010181; }
#
#
# Style definition file generated by highlight 3.13, http://www.andre-simon.de/
#
# body.hl { background-color:#e0eaee; }
# pre.hl  { color:#000000; background-color:#e0eaee; font-size:10pt; font-family:'Courier New',monospace;}
# .hl.num { color:#b07e00; }
# .hl.esc { color:#ff00ff; }
# .hl.str { color:#bf0303; }
# .hl.pps { color:#818100; }
# .hl.slc { color:#838183; font-style:italic; }
# .hl.com { color:#838183; font-style:italic; }
# .hl.ppc { color:#008200; }
# .hl.opt { color:#000000; }
# .hl.ipl { color:#0057ae; }
# .hl.lin { color:#555555; }
# .hl.kwa { color:#000000; font-weight:bold; }
# .hl.kwb { color:#0057ae; }
# .hl.kwc { color:#000000; font-weight:bold; }
# .hl.kwd { color:#010181; }
#
#
# The following environment variables can be used to retrieve the configuration
# of the repository for which this script is called:
# CGIT_REPO_URL        ( = repo.url       setting )
# CGIT_REPO_NAME       ( = repo.name      setting )
# CGIT_REPO_PATH       ( = repo.path      setting )
# CGIT_REPO_OWNER      ( = repo.owner     setting )
# CGIT_REPO_DEFBRANCH  ( = repo.defbranch setting )
# CGIT_REPO_SECTION    ( = section        setting )
# CGIT_REPO_CLONE_URL  ( = repo.clone-url setting )
#

# store filename and extension in local vars
BASENAME="$1"
EXTENSION="${BASENAME##*.}"

[ "${BASENAME}" = "${EXTENSION}" ] && EXTENSION=txt
[ -z "${EXTENSION}" ] && EXTENSION=txt

# map Makefile and Makefile.* to .mk
[ "${BASENAME%%.*}" = "Makefile" ] && EXTENSION=mk

# highlight versions 2 and 3 have different commandline options. Specifically,
# the -X option that is used for version 2 is replaced by the -O xhtml option
# for version 3.
#
# Version 2 can be found (for example) on EPEL 5, while version 3 can be
# found (for example) on EPEL 6.
#
# This is for version 2
#exec highlight --force -f -I -X -S "$EXTENSION" 2>/dev/null

# This is for version 3
HIGHLIGHT_THEME="${HIGHLIGHT_THEME:-"$(cat /.highlight-theme)"}"
THEMEOPT=()
if [[ "$HIGHLIGHT_THEME" != "" ]]; then THEMEOPT+=("--style=$HIGHLIGHT_THEME"); fi
exec highlight --force --inline-css "${THEMEOPT[@]}" -f -I -O xhtml -S "$EXTENSION" 2>/dev/null

