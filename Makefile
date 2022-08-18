# Latex Makefile using latexmk, based on
# [1] https://gist.github.com/dogukancagatay/2eb82b0233829067aca6
# [2] http://tex.stackexchange.com/a/40759
# [3] https://github.com/schuster/latex-makefile
# [4] https://tex.stackexchange.com/questions/318569/makefile-for-a-latex-report

# Tools
RM = rm -f
# Compiler from MarkDown to HTML, LaTeX and PDF
PD = pandoc
# Builder from LaTeX. This Makefile is mostly a wrapper for latexmk with right options and a
LATEXMK = latexmk
# Auxiliary directory to collect LaTeX workfiles (*.aux, etc)
D = .z
# Directory for output PDFs
PDFDIR = pdf
# -use-make tells latexmk to call make for generating missing files.
#     -dvi-  - turn off required dvi
#     -ps-   - turn off postscript
# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -interaction=nonstopmode keeps the pdflatex backend from stopping at a
#   missing file reference and interactively asking you for an alternative.
LMK_OPTIONS = -silent -time -outdir=$(D) -use-make -pdf
# LMK_ENGINE = -lualatex
LMK_ENGINE = -pdflatex="pdflatex -interaction=nonstopmode"
LMK = $(LATEXMK) $(LMK_ENGINE) $(LMK_OPTIONS)

# Important naming convention for this Makefile to work:
# All articles in this folder are named 'article-onamae.tex' where 'onamae' is a placeholder for its name.
# All their dependencies are onamae-*.tex, but they will be handled automatically by latexmk.
# ART = $(wildcard article-*.tex)

ART = complex.tex

# pdf files will be named article-onamae.pdf, so just change .tex to .pdf
# Importantíssimo: latexmk shall not run on other texfiles
# (a common problem that happens when one runs 'latexmk' without arguments)
PDF = $(ART:.tex=.pdf)

# TARGETS (RULES)

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: doc
doc: pdf
pdf: $(PDF)

# CUSTOM BUILD RULES

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
$(PDFDIR):
	mkdir -p $@
$(D):
	mkdir -p $@

# [3], idea from [4]
# The M/MP/MF options here create phony Makefile rules in $*.deps, which are
# picked up the the -include *.deps below. The end result is that latexmk
# dynamically generates the list of *all* dependencies for each document it
# builds, so that 'make' will attempt to rebuild the document whenever any of
# those dependencies change.
# This rule works for any particular pdf.
%.pdf: %.tex $(D)
	$(LMK) -M -MP -MF $(D)/$*.deps $<
	mkdir -p $(PDFDIR)
	ln -Ff $(D)/$@ $(PDFDIR)/

clean:
	$(LATEXMK) -silent -c
	$(RM) $(D)/*.bbl

cleanall:
	# maybe just the line below?
	# $(RM) -r $(D)
	$(LMK) -silent -C
	$(RM) $(D)/*.run.xml
	$(RM) $(D)/*.deps
	$(RM) *.acn *.acr *.alg *.glg *.glo *.gls *.ist  *.synctex.gz

# Include auto-generated dependencies
-include *.deps

# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: all clean doc cleanall pdf
