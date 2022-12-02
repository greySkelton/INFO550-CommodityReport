#Because I am doing development from command line
FROM rocker/r-ubuntu
RUN apt-get update && apt-get install -y pandoc zlib1g-dev
RUN apt-get update && apt-get install -y libcurl4-openssl-dev
RUN apt-get update && apt-get install -y libssl-dev
RUN apt-get update && apt-get install -y libfontconfig1-dev libudunits2-dev
RUN apt-get update && apt-get install -y libgdal-dev libgeos-dev libproj-dev
RUN apt-get update && apt-get install -y libmagick++-dev

#Creating directory in my image
RUN mkdir /project
WORKDIR /project

#Copy over all renv files
COPY .Rprofile .
COPY renv.lock .
#Copy Makefile, config file, and hiv_report.Rmd
COPY Makefile .
COPY commodityReport.Rmd .

#Create renv folder that is the same as in the local project directory
RUN mkdir renv
COPY renv/activate.R renv
COPY renv/settings.dcf renv

#Call upon renv to make sure we have necessary packages
RUN Rscript -e "renv::restore(prompt = FALSE)"

#Create code, output, raw_data, and report directories in our image
RUN mkdir code
RUN mkdir output
RUN mkdir raw_data

COPY raw_data/commodities.csv raw_data
COPY code/* code

RUN mkdir report

CMD make commodityReport.html && mv commodityReport.html report