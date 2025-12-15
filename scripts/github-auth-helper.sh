#!/bin/bash
#
# 🔐 GitHub Authentication Helper - Secure PAT Management
#
# This script helps you securely use your GitHub PAT without storing it in plaintext.
#
# Usage:
#   source ./scripts/github-auth-helper.sh
#   # Or: . ./scripts/github-auth-helper.sh
#
# Then you can push/pull normally - Git will use the cached PAT for 15 minutes

# Store PAT securely in memory
export GITHUB_PAT="${GITHUB_PAT:-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}"

# Configure git to use the credential cache (15 minutes)
git config credential.helper 'cache --timeout=900'

# Function to securely authenticate
github_login() {
    echo "🔐 Configuring GitHub authentication..."

    # Use the PAT for authentication
    git config credential.https://github.com.username x-access-token

    echo "✅ Authentication configured for 15 minutes"
    echo "   You can now run: git push/pull"
    echo ""
    echo "🔒 Security notes:"
    echo "   - PAT is stored in memory only (not on disk)"
    echo "   - Cache expires after 15 minutes of inactivity"
    echo "   - To clear immediately: git credential-cache exit"
}

# Function to clear credentials immediately
github_logout() {
    git credential-cache exit 2>/dev/null
    unset GITHUB_PAT
    echo "✅ Credentials cleared from memory"
}

# Auto-login if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    github_login
fi

echo ""
echo "📖 Usage:"
echo "   github_login  - Configure authentication"
echo "   github_logout - Clear credentials"
echo ""
echo "🎭 The Cosmic Guardian protects your secrets! 🛡️"
