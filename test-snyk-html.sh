#!/bin/bash
echo '{"vulnerabilities": [{"id": "TEST-123", "title": "Test Vulnerability"}]}' > dummy-results.json
snyk-to-html -i dummy-results.json -o dummy-results.html --debug
