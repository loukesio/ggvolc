# Docker Setup for ggvolc

This Docker image provides a complete R environment with RStudio Server and the `ggvolc` package pre-installed, based on the [rocker/tidyverse](https://hub.docker.com/r/rocker/tidyverse) image.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system
- [Docker Compose](https://docs.docker.com/compose/install/) (optional, but recommended)

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. **Build and start the container:**
   ```bash
   docker-compose up -d
   ```

2. **Access RStudio Server:**
   - Open your browser and go to: http://localhost:8787
   - Username: `rstudio`
   - Password: `ggvolc123` (can be changed in `docker-compose.yml`)

3. **Start using ggvolc:**
   ```r
   library(ggvolc)

   # Load example data
   data(all_genes)
   data(attention_genes)

   # Create a volcano plot
   ggvolc(all_genes, attention_genes, add_seg = TRUE)
   ```

4. **Stop the container:**
   ```bash
   docker-compose down
   ```

### Option 2: Using Docker CLI

1. **Build the image:**
   ```bash
   docker build -t ggvolc:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name ggvolc-rstudio \
     -p 8787:8787 \
     -e PASSWORD=ggvolc123 \
     -v $(pwd)/workspace:/home/rstudio/workspace \
     ggvolc:latest
   ```

3. **Access RStudio Server:**
   - Go to http://localhost:8787
   - Login with username `rstudio` and password `ggvolc123`

4. **Stop and remove the container:**
   ```bash
   docker stop ggvolc-rstudio
   docker rm ggvolc-rstudio
   ```

### Option 3: R Console Only (No RStudio)

If you just need R console without the web interface:

```bash
# Using docker-compose
docker-compose run --rm r-console

# Or using Docker CLI
docker run -it --rm ggvolc:latest R
```

## Features

- **R 4.5:** Matches the development environment
- **RStudio Server:** Web-based IDE accessible via browser
- **Tidyverse packages:** Pre-installed (dplyr, ggplot2, tidyr, etc.)
- **ggvolc package:** Pre-installed from source
- **Persistent workspace:** Files in `./workspace` are preserved between sessions

## Customization

### Change RStudio Password

Edit the `PASSWORD` environment variable in `docker-compose.yml`:

```yaml
environment:
  - PASSWORD=your_secure_password
```

### Disable Authentication (Local Use Only)

Add this to the environment section in `docker-compose.yml`:

```yaml
environment:
  - DISABLE_AUTH=true
```

### Mount Additional Directories

Add volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./workspace:/home/rstudio/workspace
  - ./data:/home/rstudio/data
  - ./scripts:/home/rstudio/scripts
```

### Install Additional R Packages

You can install packages interactively in RStudio, or add them to the Dockerfile:

```dockerfile
RUN install2.r --error --skipinstalled \
    package1 \
    package2 \
    && rm -rf /tmp/downloaded_packages
```

## Workspace Directory

The `workspace` directory is automatically created and mounted to `/home/rstudio/workspace` in the container. Any files you save here will persist after the container is stopped.

## Troubleshooting

### Port 8787 is already in use

Change the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8888:8787"  # Access RStudio at localhost:8888
```

### Permission issues with mounted volumes

On Linux, you may need to set proper ownership:

```bash
sudo chown -R 1000:1000 workspace/
```

### Container won't start

Check logs:
```bash
docker-compose logs rstudio
```

### Rebuild after changes

```bash
docker-compose build --no-cache
docker-compose up -d
```

## Using with GitHub Codespaces or Cloud Providers

This Docker setup can also be deployed to:
- GitHub Codespaces
- AWS EC2
- Google Cloud Run
- DigitalOcean
- Any cloud provider supporting Docker

## Development

### Testing Local Changes

If you're developing ggvolc and want to test changes:

1. Make changes to the R code
2. Rebuild the container:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

### Accessing R Package Check Logs

```bash
docker run --rm -v $(pwd):/pkg ggvolc:latest \
  R CMD check --as-cran /pkg
```

## Additional Resources

- [Rocker Project Documentation](https://rocker-project.org/)
- [Docker Documentation](https://docs.docker.com/)
- [RStudio Server Documentation](https://docs.posit.co/ide/server-pro/)

## GitHub Actions - Automated Builds

This repository includes automated Docker builds via GitHub Actions!

### What happens automatically:

✅ **Every push** to master/main branch:
- Docker image is built and tested
- ggvolc installation is verified
- Example code is run to ensure everything works
- Build report is generated

✅ **Every pull request**:
- Docker builds are tested before merging
- Ensures changes don't break the Docker setup

### View Build Status

Check the [Actions tab](https://github.com/loukesio/ggvolc/actions) to see build results.

### Publishing to Docker Hub (Optional)

Want to publish images automatically? See [.github/DOCKER_PUBLISHING.md](.github/DOCKER_PUBLISHING.md) for setup instructions.

Once enabled, images will be available as:
```bash
docker pull loukesio/ggvolc:latest
```

## Support

For issues related to:
- **ggvolc package:** https://github.com/loukesio/ggvolc/issues
- **Docker image:** https://github.com/loukesio/ggvolc/issues
- **Rocker base image:** https://github.com/rocker-org/rocker-versioned2/issues
