commodityReport.html: commodityReport.Rmd loadData createTables createFigures
	Rscript code/03_render_report.R

createTables: loadData
	Rscript code/01_make_tables.R

createFigures: loadData
	Rscript code/02_make_figures.R
	
loadData: 
	Rscript code/00_load_data.R
	
.PHONY: install
install:
	Rscript -e "renv::restore(prompt = FALSE)"

.PHONY: clean
clean:
	rm -f output/*.rds && rm -f commodityReport.html && rm -f report/commodityReport.html
	
build:
	docker build -t gskelton/commodity_project .
	
project:
	docker run -v "/$$(pwd)/report":/project/report gskelton/commodity_project