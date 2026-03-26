#!/bin/bash
set -euo pipefail

# Verify API Gateway TLS Certificate Status

CONSUL_NAMESPACE="${1:-consul}"
CERT_MANAGER_NAMESPACE="${2:-cert-manager}"

echo "=========================================="
echo "API Gateway TLS Verification"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Check if Gateway exists
echo "1. Checking Gateway resource..."
if kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE" &>/dev/null; then
    check_pass "Gateway 'api-gateway' exists in namespace '$CONSUL_NAMESPACE'"
else
    check_fail "Gateway 'api-gateway' not found in namespace '$CONSUL_NAMESPACE'"
    exit 1
fi
echo ""

# 2. Check Gateway listener status
echo "2. Checking Gateway listener status..."
LISTENER_PROGRAMMED=$(kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="Programmed")].status}' 2>/dev/null || echo "Unknown")
LISTENER_RESOLVED=$(kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="ResolvedRefs")].status}' 2>/dev/null || echo "Unknown")
LISTENER_REASON=$(kubectl get gateway api-gateway -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.listeners[0].conditions[?(@.type=="ResolvedRefs")].reason}' 2>/dev/null || echo "Unknown")

if [ "$LISTENER_PROGRAMMED" = "True" ]; then
    check_pass "Gateway listener is programmed and ready"
else
    check_fail "Gateway listener is NOT programmed (Status: $LISTENER_PROGRAMMED)"
fi

if [ "$LISTENER_RESOLVED" = "True" ]; then
    check_pass "Gateway listener certificate references are resolved"
else
    check_fail "Gateway listener certificate references NOT resolved (Reason: $LISTENER_REASON)"
fi
echo ""

# 3. Check TLS secret existence
echo "3. Checking TLS secret..."
if kubectl get secret api-gateway-tls -n "$CONSUL_NAMESPACE" &>/dev/null; then
    check_pass "TLS secret 'api-gateway-tls' exists"

    # Check secret data
    CERT_DATA=$(kubectl get secret api-gateway-tls -n "$CONSUL_NAMESPACE" -o jsonpath='{.data.tls\.crt}' 2>/dev/null || echo "")
    KEY_DATA=$(kubectl get secret api-gateway-tls -n "$CONSUL_NAMESPACE" -o jsonpath='{.data.tls\.key}' 2>/dev/null || echo "")

    if [ -n "$CERT_DATA" ] && [ -n "$KEY_DATA" ]; then
        check_pass "TLS secret contains certificate and key data"
    else
        check_fail "TLS secret is missing certificate or key data"
    fi
else
    check_fail "TLS secret 'api-gateway-tls' does NOT exist"
fi
echo ""

# 4. Check Certificate resource
echo "4. Checking Certificate resource..."
if kubectl get certificate api-gateway-cert -n "$CONSUL_NAMESPACE" &>/dev/null; then
    check_pass "Certificate 'api-gateway-cert' exists"

    CERT_READY=$(kubectl get certificate api-gateway-cert -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
    CERT_REASON=$(kubectl get certificate api-gateway-cert -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].reason}' 2>/dev/null || echo "Unknown")
    CERT_MESSAGE=$(kubectl get certificate api-gateway-cert -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' 2>/dev/null || echo "Unknown")

    if [ "$CERT_READY" = "True" ]; then
        check_pass "Certificate is ready"
    else
        check_fail "Certificate is NOT ready (Reason: $CERT_REASON)"
        echo "   Message: $CERT_MESSAGE"
    fi
else
    CERT_READY="False"
    check_fail "Certificate 'api-gateway-cert' not found"
fi
echo ""

# 5. Check CertificateRequest
echo "5. Checking CertificateRequest..."
CERT_REQUEST=$(kubectl get certificaterequest -n "$CONSUL_NAMESPACE" -l cert-manager.io/certificate-name=api-gateway-cert -o name 2>/dev/null | head -n 1 || echo "")
if [ -n "$CERT_REQUEST" ]; then
    check_pass "CertificateRequest exists: $CERT_REQUEST"

    CR_READY=$(kubectl get "$CERT_REQUEST" -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
    CR_REASON=$(kubectl get "$CERT_REQUEST" -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].reason}' 2>/dev/null || echo "Unknown")
    CR_MESSAGE=$(kubectl get "$CERT_REQUEST" -n "$CONSUL_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' 2>/dev/null || echo "Unknown")

    if [ "$CR_READY" = "True" ]; then
        check_pass "CertificateRequest is ready"
    else
        check_fail "CertificateRequest is NOT ready (Reason: $CR_REASON)"
        echo "   Message: $CR_MESSAGE"
    fi
else
    check_warn "No CertificateRequest found"
fi
echo ""

# 6. Check ClusterIssuer
echo "6. Checking ClusterIssuer..."
if kubectl get clusterissuer letsencrypt-staging &>/dev/null; then
    check_pass "ClusterIssuer 'letsencrypt-staging' exists"

    ISSUER_READY=$(kubectl get clusterissuer letsencrypt-staging -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")

    if [ "$ISSUER_READY" = "True" ]; then
        check_pass "ClusterIssuer is ready"
    else
        check_fail "ClusterIssuer is NOT ready"
    fi
else
    check_fail "ClusterIssuer 'letsencrypt-staging' not found"
fi
echo ""

# 7. Check cert-manager pod status
echo "7. Checking cert-manager pod status..."
CERT_MANAGER_POD=$(kubectl get pods -n "$CERT_MANAGER_NAMESPACE" -l app=cert-manager -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$CERT_MANAGER_POD" ]; then
    POD_STATUS=$(kubectl get pod "$CERT_MANAGER_POD" -n "$CERT_MANAGER_NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")

    if [ "$POD_STATUS" = "Running" ]; then
        check_pass "cert-manager pod is running: $CERT_MANAGER_POD"
    else
        check_fail "cert-manager pod status: $POD_STATUS"
    fi
else
    check_fail "cert-manager pod not found"
fi
echo ""

# 8. Check for recent cert-manager errors
echo "8. Checking cert-manager logs for errors..."
if [ -n "$CERT_MANAGER_POD" ]; then
    ERROR_COUNT=$(kubectl logs "$CERT_MANAGER_POD" -n "$CERT_MANAGER_NAMESPACE" --tail=100 2>/dev/null | grep -c "^E" || true)
    ERROR_COUNT=${ERROR_COUNT:-0}

    if [ "$ERROR_COUNT" -eq 0 ]; then
        check_pass "No errors in recent cert-manager logs"
    else
        check_warn "Found $ERROR_COUNT error lines in recent logs"
        echo ""
        echo "Recent errors:"
        kubectl logs "$CERT_MANAGER_POD" -n "$CERT_MANAGER_NAMESPACE" --tail=100 2>/dev/null | grep "^E" | tail -5
    fi
else
    check_warn "Cannot check logs - cert-manager pod not found"
fi
echo ""

# 9. Check Workload Identity binding
echo "9. Checking Workload Identity configuration..."
CM_SA_EMAIL=$(kubectl get sa cert-manager -n "$CERT_MANAGER_NAMESPACE" -o jsonpath='{.metadata.annotations.iam\.gke\.io/gcp-service-account}' 2>/dev/null || echo "")

if [ -n "$CM_SA_EMAIL" ]; then
    check_pass "Workload Identity annotation present: $CM_SA_EMAIL"
else
    check_fail "Workload Identity annotation NOT found on cert-manager service account"
fi
echo ""

# 10. Check ACME challenges
echo "10. Checking ACME challenges..."
CHALLENGES=$(kubectl get challenges -n "$CONSUL_NAMESPACE" 2>/dev/null | tail -n +2 || echo "")
if [ -n "$CHALLENGES" ]; then
    check_warn "Active ACME challenges found:"
    echo "$CHALLENGES"
    echo ""

    # Check for DNS errors in challenges
    CHALLENGE_NAME=$(echo "$CHALLENGES" | head -n 1 | awk '{print $1}')
    if [ -n "$CHALLENGE_NAME" ]; then
        echo "Challenge details:"
        kubectl describe challenge "$CHALLENGE_NAME" -n "$CONSUL_NAMESPACE" 2>/dev/null | grep -A 5 "Events:" || true
    fi
else
    check_pass "No active ACME challenges"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="

if [ "$LISTENER_PROGRAMMED" = "True" ] && [ "$CERT_READY" = "True" ]; then
    echo -e "${GREEN}✓ Gateway is ready and TLS certificate is valid${NC}"
    echo ""
    echo "You can now run: task test:gateway"
elif [ "$CERT_READY" != "True" ]; then
    echo -e "${RED}✗ TLS certificate is not ready${NC}"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check cert-manager logs: task cert-manager:logs"
    echo "2. Verify Workload Identity: task workload-identity:verify"
    echo "3. Check GCP IAM permissions for cert-manager service account"
    echo "4. Verify Cloud DNS zone exists and is accessible"
else
    echo -e "${YELLOW}⚠ Gateway configuration needs attention${NC}"
    echo ""
    echo "Review the checks above for specific issues"
fi
