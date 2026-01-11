# Use rocker/tidyverse as base image (includes R, RStudio Server, and tidyverse packages)
# Using R 4.5 to match your development environment
FROM rocker/tidyverse:4.5

# Metadata
LABEL maintainer="Loukas Theodosiou <theodosiou@evolbio.mpg.de>" \
      description="Docker image for ggvolc: Create volcano plots for differential gene expression data" \
      version="0.1.0"

# Set working directory
WORKDIR /home/rstudio

# Install system dependencies if needed (none required for ggvolc currently)
# RUN apt-get update && apt-get install -y \
#     libxml2-dev \
#     && rm -rf /var/lib/apt/lists/*

# Install ggvolc dependencies from CRAN
# These will be automatically installed when installing ggvolc, but we install them
# explicitly here to take advantage of Docker layer caching
RUN install2.r --error --skipinstalled \
    dplyr \
    ggplot2 \
    ggrepel \
    ggtext \
    gridExtra \
    && rm -rf /tmp/downloaded_packages

# Copy the package source code into the container
COPY . /home/rstudio/ggvolc

# Build and install the ggvolc package from source
RUN R CMD build /home/rstudio/ggvolc \
    && R CMD INSTALL ggvolc_*.tar.gz \
    && rm ggvolc_*.tar.gz

# Optional: Copy example scripts or vignettes to a convenient location
RUN mkdir -p /home/rstudio/examples

# Set proper permissions for RStudio user
RUN chown -R rstudio:rstudio /home/rstudio

# Expose port 8787 for RStudio Server
EXPOSE 8787

# The base image already has CMD to start RStudio Server
# Default user: rstudio, password: rstudio
# To change password, set environment variable PASSWORD when running container
