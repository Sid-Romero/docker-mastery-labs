# Lab Generator Scripts

Automated DevOps lab generator using web scraping and Google Gemini AI.

## in General

This system automatically generates hands-on DevOps labs by:
1. Scraping trending DevOps content from multiple sources
2. Selecting a random topic and technology
3. Using Gemini AI to generate a complete lab structure
4. Creating the lab files in the repository

## Requirements

- Python 3.11+
- Google Gemini API key

## Setup

### 1. Install dependencies

```bash
cd scripts
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY
# i deleted it tho
```

you can have a Gemini API key at: https://aistudio.google.com/app/apikey

### 3. For GitHub Actions

Add the secret `GEMINI_API_KEY` to your repository:
- Go to Settings > Secrets and variables > Actions
- Click "New repository secret"
- Name: `GEMINI_API_KEY`
- Value: your API key

## Usage

### Run tests

```bash
python lab_generator.py --test
```

### Dry run (no files created)

```bash
python lab_generator.py --dry-run --skip-scrape
```

### Generate a lab

```bash
python3 lab_generator.py
```

### Force a specific technology

```bash
python lab_generator.py --technology docker
python lab_generator.py --technology kubernetes
python lab_generator.py --technology helm
python lab_generator.py --technology argocd
python lab_generator.py --technology ansible
```

### Skip web scraping (use fallback topics)

```bash
python lab_generator.py --skip-scrape
```

## CLI Options

| Option | Description |
|--------|-------------|
| `--test` | Run local tests | # need more advanced local test or CI test
| `--dry-run` | Run without creating files |
| `--skip-scrape` | Skip web scraping, use fallback topics |
| `--technology <tech>` | Force a specific technology |

## File Structure

```
scripts/
  lab_generator.py    # Main orchestrator
  web_scraper.py      # Scrapes DevOps content from web
  ai_generator.py     # Generates labs using Gemini AI
  file_creator.py     # Creates lab directories and files
  requirements.txt    # Python dependencies
  .env or env.example # Environment template
  README.md           # This file
```

## Data Sources

The scraper fetches content from:
- Dev.to (RSS feeds)
- GitHub Trending repositories
- CNCF Blog
- Reddit (r/devops, r/kubernetes, r/docker, r/ansible)
- Hacker News (filtered)
- Medium (DevOps tags)

## Technologies

Labs are generated for:
- Docker
- Kubernetes
- Helm
- ArgoCD
- Ansible

## GitHub Actions Workflow

The workflow runs automatically:
- Every 3-5 hours (alternating schedule)
- Switches to daily after 50 labs are generated

Manual trigger available via Actions tab with options to force technology or generation.

## Troubleshooting

### ModuleNotFoundError

Install dependencies:
```bash
pip install -r requirements.txt
```

### GEMINI_API_KEY not set

Create `.env` file with your API key:
```bash
cp .env.example .env
# Edit .env
```

### Scraping fails

Use `--skip-scrape` to use fallback topics:
```bash
python lab_generator.py --skip-scrape
```
