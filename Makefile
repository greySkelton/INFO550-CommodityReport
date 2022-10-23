commodityReport.html: commodityReport.Rmd loadData createTables createFigures
	Rscript code/03_render_report.R

createTables: loadData
	Rscript code/01_make_tables.R

createFigures: loadData
	Rscript code/02_make_figures.R
	
loadData: 
	Rscript code/00_load_data.R

.PHONY: clean
clean:
	rm -f output/*.rds && rm -f commodityReport.html