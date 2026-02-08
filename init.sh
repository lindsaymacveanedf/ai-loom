#!/bin/bash

# AI Loom Initialization Script
# This script helps you configure AI Loom for your project

set -e

echo "=================================="
echo "  AI Loom - Project Setup"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt for input with a default value
prompt() {
    local prompt_text="$1"
    local default_value="$2"
    local var_name="$3"

    if [ -n "$default_value" ]; then
        read -p "$prompt_text [$default_value]: " input
        eval "$var_name=\"${input:-$default_value}\""
    else
        read -p "$prompt_text: " input
        eval "$var_name=\"$input\""
    fi
}

# Function to prompt yes/no
prompt_yn() {
    local prompt_text="$1"
    local default="$2"
    local var_name="$3"

    while true; do
        read -p "$prompt_text (y/n) [$default]: " yn
        yn=${yn:-$default}
        case $yn in
            [Yy]* ) eval "$var_name=true"; break;;
            [Nn]* ) eval "$var_name=false"; break;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

echo -e "${BLUE}Step 1: Basic Project Information${NC}"
echo "-----------------------------------"
prompt "Project/Organization name" "" PROJECT_NAME
prompt "GitHub organization or username" "" GITHUB_ORG
echo ""

echo -e "${BLUE}Step 2: Repositories${NC}"
echo "--------------------"
echo "Enter your repositories (one per line, format: name description)"
echo "Example: frontend React web application"
echo "Type 'done' when finished."
echo ""

REPOS=()
REPO_DESCS=()
while true; do
    read -p "Repository: " repo_input
    if [ "$repo_input" = "done" ] || [ -z "$repo_input" ]; then
        break
    fi
    repo_name=$(echo "$repo_input" | awk '{print $1}')
    repo_desc=$(echo "$repo_input" | cut -d' ' -f2-)
    REPOS+=("$repo_name")
    REPO_DESCS+=("$repo_desc")
done
echo ""

echo -e "${BLUE}Step 3: Branch Conventions${NC}"
echo "--------------------------"
echo "For each repository, specify the workflow:"
echo "  1) PR to main (trunk-based)"
echo "  2) PR to develop, then merge to main"
echo "  3) Direct push to main (no PR)"
echo ""

declare -A REPO_WORKFLOWS
for repo in "${REPOS[@]}"; do
    while true; do
        read -p "Workflow for '$repo' (1/2/3): " workflow
        case $workflow in
            1) REPO_WORKFLOWS[$repo]="Trunk-based; PRs into main."; break;;
            2) REPO_WORKFLOWS[$repo]="Uses **develop** for preproduction; merge to main for production."; break;;
            3) REPO_WORKFLOWS[$repo]="Commit straight to **main**; no PR requirement."; break;;
            *) echo "Please enter 1, 2, or 3.";;
        esac
    done
done
echo ""

echo -e "${BLUE}Step 4: Tools${NC}"
echo "-------------"
echo "Which tools do you use? (y/n for each)"

prompt_yn "AWS CLI" "n" USE_AWS
prompt_yn "Terraform" "n" USE_TERRAFORM
prompt_yn "Docker" "n" USE_DOCKER
prompt_yn "Kubernetes (kubectl)" "n" USE_K8S
echo ""

echo -e "${BLUE}Step 5: Project Architecture${NC}"
echo "----------------------------"
echo "Briefly describe your architecture components."
echo "Type 'done' when finished."
echo ""

ARCH_COMPONENTS=()
while true; do
    read -p "Component (e.g., 'API: Node.js Lambda'): " component
    if [ "$component" = "done" ] || [ -z "$component" ]; then
        break
    fi
    ARCH_COMPONENTS+=("$component")
done
echo ""

# Generate REPOS.md
echo -e "${GREEN}Generating configuration files...${NC}"

cat > REPOS.md << EOF
# Repository URLs

Reference clone URLs for ${PROJECT_NAME} repositories.

EOF

for i in "${!REPOS[@]}"; do
    repo="${REPOS[$i]}"
    desc="${REPO_DESCS[$i]}"
    if [ -n "$desc" ]; then
        echo "- **${repo}**: https://github.com/${GITHUB_ORG}/${repo} — ${desc}" >> REPOS.md
    else
        echo "- **${repo}**: https://github.com/${GITHUB_ORG}/${repo}" >> REPOS.md
    fi
done

cat >> REPOS.md << 'EOF'

## Branch and workflow

EOF

for repo in "${REPOS[@]}"; do
    echo "- **${repo}**: ${REPO_WORKFLOWS[$repo]}" >> REPOS.md
done

cat >> REPOS.md << 'EOF'

## Work directory and cloning for any fix

For any fix that needs one or more of these repos cloned locally: create a run directory under `work/<purpose>-<date>/`, look up this file for clone URLs, and clone only the repos you need. See **[runbooks/general-fix.md](./runbooks/general-fix.md)** for the full pattern (create run dir → clone from REPOS.md → task work → back out).

---

## Clone examples

```bash
EOF

for repo in "${REPOS[@]}"; do
    echo "git clone https://github.com/${GITHUB_ORG}/${repo}.git" >> REPOS.md
done

echo '```' >> REPOS.md

# Update TOOLS.md with selected tools
if [ "$USE_AWS" = "true" ] || [ "$USE_TERRAFORM" = "true" ] || [ "$USE_DOCKER" = "true" ] || [ "$USE_K8S" = "true" ]; then
    # Read current TOOLS.md and add tools section
    TOOLS_SECTION=""
    if [ "$USE_AWS" = "true" ]; then
        TOOLS_SECTION+="| **AWS CLI** | SSO login, Lambda, API Gateway, DynamoDB, etc. |\n"
    fi
    if [ "$USE_TERRAFORM" = "true" ]; then
        TOOLS_SECTION+="| **Terraform** | Infrastructure as code. |\n"
    fi
    if [ "$USE_DOCKER" = "true" ]; then
        TOOLS_SECTION+="| **Docker** | Containerization and local services. |\n"
    fi
    if [ "$USE_K8S" = "true" ]; then
        TOOLS_SECTION+="| **kubectl** | Kubernetes cluster management. |\n"
    fi

    # Insert tools into TOOLS.md (after the existing table)
    sed -i.bak "s|<!-- CUSTOMIZE: Add your project-specific tools -->|${TOOLS_SECTION}|" TOOLS.md 2>/dev/null || \
    sed -i '' "s|<!-- CUSTOMIZE: Add your project-specific tools -->|${TOOLS_SECTION}|" TOOLS.md
fi

# Update CONTEXT.md with architecture
if [ ${#ARCH_COMPONENTS[@]} -gt 0 ]; then
    ARCH_SECTION=""
    for component in "${ARCH_COMPONENTS[@]}"; do
        ARCH_SECTION+="- **${component}\n"
    done

    # This is a simple replacement - in practice you might want more sophisticated templating
    echo "" >> CONTEXT.md
    echo "### Project Components" >> CONTEXT.md
    echo "" >> CONTEXT.md
    for component in "${ARCH_COMPONENTS[@]}"; do
        echo "- **${component}" >> CONTEXT.md
    done
fi

# Ensure current/ directory exists
mkdir -p current

echo ""
echo -e "${GREEN}=================================="
echo "  Setup Complete!"
echo "==================================${NC}"
echo ""
echo "Files updated:"
echo "  - REPOS.md (your repositories)"
echo "  - TOOLS.md (your tools)"
echo "  - CONTEXT.md (your architecture)"
echo ""
echo "Next steps:"
echo "  1. Review and customize the generated files"
echo "  2. Clone your baseline repos into current/"
echo "  3. Commit and push to your repository"
echo ""
echo "To clone your repos into current/:"
for repo in "${REPOS[@]}"; do
    echo "  git clone https://github.com/${GITHUB_ORG}/${repo}.git current/${repo}"
done
echo ""
echo -e "${BLUE}Happy coding with AI Loom!${NC}"
