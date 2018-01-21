# FAISS installation directory
FAISSPATH=../faiss

# data directory
DATADIR=data

# select corpus file from data directory
#DATASET=deu_newscrawl_2017_1K-sentences.txt
#DATASET=deu_newscrawl_2017_10K-sentences.txt
DATASET=deu_newscrawl_2017_30K-sentences.txt
#DATASET=deu_newscrawl_2017_100K-sentences.txt
#DATASET=deu_newscrawl_2017_300K-sentences.txt
#DATASET=deu_newscrawl_2017_1M-sentences.txt

# output directory
OUTDIR=out

# k in kNN query
K=4

# R script file name. will automatically rendered from RMarkdown notebook file
INITR=init.R

# RMarkdown notebook filename
NOTEBOOK=notes
NOTEBOOKRMD=$(NOTEBOOK).Rmd

all: run docs

# build R script from RMarkdown notebook, init output directory, run first part of R script to build faiss input
build: 
	cd bin && Rscript tangle.R -o "$(INITR)"
	mkdir -p $(OUTDIR)
	cd bin && Rscript $(INITR) -d "../$(DATADIR)" -f "$(DATASET)" -o "../$(OUTDIR)"

# execute faiss
run: build
	sh run "../$(FAISSPATH)" "../$(OUTDIR)" "$(K)"

# run second part of R script to evaluate results
results: run
	cd bin && Rscript $(INITR) --results TRUE -k $(K)

# generate reveal-md slides
slides:
	cd docs && reveal-md slides.md --static slides

clean:
	rm -rf bin/$(INITR) $(OUTDIR)
	rm -rf docs/$(NOTEBOOK)_cache
	rm -rf cache
