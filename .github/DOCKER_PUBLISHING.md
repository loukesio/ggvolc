# Docker Publishing Setup

This guide explains how to enable automatic Docker image publishing to Docker Hub or GitHub Container Registry when you push changes.

## Current Setup

✅ **Automated Building & Testing** - Already enabled!
- Builds Docker image on every push to master/main
- Runs tests to verify ggvolc works correctly
- Generates build reports

## Option 1: Publish to Docker Hub

### Setup Steps:

1. **Create Docker Hub account** (if you don't have one):
   - Go to https://hub.docker.com/signup
   - Create account (free tier is fine)

2. **Create Docker Hub repository**:
   - Go to https://hub.docker.com/repositories
   - Click "Create Repository"
   - Name: `ggvolc`
   - Visibility: Public (or Private if you prefer)

3. **Generate Docker Hub access token**:
   - Go to Account Settings → Security → Access Tokens
   - Click "New Access Token"
   - Description: "GitHub Actions"
   - Permissions: Read & Write
   - Copy the token (you won't see it again!)

4. **Add secrets to GitHub repository**:
   - Go to your GitHub repo: Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add two secrets:
     - Name: `DOCKER_USERNAME`, Value: your Docker Hub username
     - Name: `DOCKER_PASSWORD`, Value: your access token from step 3

5. **Enable publishing in workflow**:
   - Edit `.github/workflows/docker-build.yml`
   - Uncomment the `push-to-dockerhub` job (lines ~73-108)
   - Update `loukesio/ggvolc` to `YOUR_USERNAME/ggvolc`
   - Commit and push

### Result:
Your Docker image will be automatically published to:
`docker pull YOUR_USERNAME/ggvolc:latest`

---

## Option 2: Publish to GitHub Container Registry (ghcr.io)

### Setup Steps:

1. **Enable GitHub Container Registry** (already enabled by default)

2. **Make packages public** (optional):
   - After first push, go to: https://github.com/users/YOUR_USERNAME/packages/container/ggvolc/settings
   - Change visibility to Public

3. **Enable publishing in workflow**:
   - Edit `.github/workflows/docker-build.yml`
   - Uncomment the `push-to-ghcr` job (lines ~110-145)
   - Commit and push

### Result:
Your Docker image will be automatically published to:
`docker pull ghcr.io/YOUR_USERNAME/ggvolc:latest`

---

## Option 3: Both (Recommended)

You can enable both Docker Hub and GHCR! Just uncomment both jobs.

**Benefits:**
- Docker Hub: More discoverable, better known
- GHCR: Free, integrated with GitHub, no separate account needed

---

## Testing Locally First

Before enabling publishing, test the build locally:

```bash
# Build the image
docker build -t ggvolc:test .

# Run tests
docker run --rm ggvolc:test R -e "library(ggvolc); packageVersion('ggvolc')"

# Test an example
docker run --rm ggvolc:test R -e "
library(ggvolc)
data(all_genes)
ggvolc(all_genes)
"
```

---

## Workflow Triggers

The Docker build workflow runs when:
- ✅ You push changes to `master` or `main` branch
- ✅ Changes affect: Dockerfile, docker-compose.yml, R code, DESCRIPTION
- ✅ Someone creates a pull request
- ✅ You manually trigger it (Actions tab → Docker Build → Run workflow)

---

## Viewing Build Results

After pushing:
1. Go to your GitHub repo
2. Click "Actions" tab
3. Click on the latest workflow run
4. View the build report and test results

---

## Versioning Strategy

The workflow automatically tags images:
- `latest` - Most recent build from main/master
- `main` or `master` - Branch name
- `v1.0.0` - If you create a Git tag (semver pattern)

To create a version tag:
```bash
git tag v0.1.0
git push origin v0.1.0
```

This will create `ggvolc:v0.1.0` and `ggvolc:0.1` images.

---

## Troubleshooting

### Build fails in GitHub Actions

1. Check the Actions tab for error messages
2. Test locally first: `docker build .`
3. Ensure all files are committed and pushed

### Can't publish to Docker Hub

- Verify secrets are set correctly (DOCKER_USERNAME, DOCKER_PASSWORD)
- Check Docker Hub token has Read & Write permissions
- Ensure repository name matches: `username/ggvolc`

### Can't publish to GHCR

- Ensure workflow has `packages: write` permission (already in commented code)
- Make package public after first push

### Image is too large

Current size should be ~2-3GB (includes R, RStudio, tidyverse).

To reduce:
- Use `rocker/r-ver` instead of `rocker/tidyverse` (only base R)
- Remove RStudio Server if not needed
- Use multi-stage builds

---

## Cost

- ✅ **GitHub Actions**: Free for public repos (2000 minutes/month)
- ✅ **Docker Hub**: Free tier (unlimited public repos, limited pulls)
- ✅ **GHCR**: Free (500MB storage free, then $0.25/GB)

---

## Next Steps

1. Test locally: `docker build .`
2. Push to GitHub and check Actions tab
3. If tests pass, enable publishing (optional)
4. Add badge to README.md (see below)

---

## Adding Status Badge to README

Add this to your README.md:

```markdown
[![Docker Build](https://github.com/loukesio/ggvolc/actions/workflows/docker-build.yml/badge.svg)](https://github.com/loukesio/ggvolc/actions/workflows/docker-build.yml)
```

If publishing to Docker Hub:
```markdown
[![Docker Hub](https://img.shields.io/docker/v/loukesio/ggvolc?label=Docker%20Hub)](https://hub.docker.com/r/loukesio/ggvolc)
[![Docker Pulls](https://img.shields.io/docker/pulls/loukesio/ggvolc)](https://hub.docker.com/r/loukesio/ggvolc)
```
