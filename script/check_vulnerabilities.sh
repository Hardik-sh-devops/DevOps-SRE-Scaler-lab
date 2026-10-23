#!/bin/bash

# Check Bandit report
if grep -E '"issue_severity": "(HIGH|CRITICAL)"' bandit-report.json; then
    echo "SAST vulnerability found!"
    exit 1
fi

# Check Trivy report
if grep -E '"Severity": "(HIGH|CRITICAL)"' trivy-report.json; then
    echo "Container vulnerability found!"
    exit 1
fi

echo "No High or Critical vulnerabilities found."
exit 0
