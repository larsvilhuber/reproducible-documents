FROM rocker/verse:4.6.1

# Install additional R packages (same script participants use on posit.cloud),
# in the versions recorded in renv.lock
WORKDIR /tmp
COPY renv.lock libraries.R /tmp/

RUN Rscript /tmp/libraries.R

# The packages are now in the image: do not activate the project's renv
# library (which is empty in a fresh checkout) when the project is mounted
ENV RENV_CONFIG_AUTOLOADER_ENABLED=FALSE
