# Makefile

RMD       := Stock_Market_Analysis.Rmd
HTML      := $(RMD:.Rmd=.html)
PDF       := $(RMD:.Rmd=.pdf)
IMG_DIR   := img

.PHONY: all clean docker

all: $(HTML)

$(HTML): $(RMD)
	Rscript -e "rmarkdown::render('$<', output_file='$@')"

$(PDF): $(HTML)
	pandoc $< -o $@ --pdf-engine=xelatex

clean:
	rm -f $(HTML) $(PDF)
	rm -rf $(IMG_DIR)/*.png

docker:
	docker build -t stock-analysis:latest .

