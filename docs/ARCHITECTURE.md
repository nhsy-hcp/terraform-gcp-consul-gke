# Architecture Documentation

## Overview

This document describes the architecture of the Consul Service Mesh deployment on Google Kubernetes Engine (GKE).

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTPS (443)
                         │ HTTP (80) → Redirect to HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GCP Load Balancer                             │
│                  (Consul API Gateway)                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ TLS Termination
                         │ (cert-manager + Let's Encrypt)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Consul Service Mesh                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Service Intentions                       │  │
│  │              (Authorization Rules)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                        │
│         ┌───────────────┴───────────────┐                       │
│         ▼                               ▼                       │
│  ┌─────────────┐                 ┌─────────────┐               │
│  │  Frontend   │                 │   Backend   │               │
│  │   Service   │────────────────▶│   Service   │               │
│  │             │   mTLS (9091)   │             │               │
│  │ + Envoy     │                 │ + Envoy     │               │
│  │   Sidecar   │                 │   Sidecar   │               │
│  └─────────────┘                 └─────────────┘               │
│         │                               │                       │
│         └───────────────┬───────────────┘                       │
│                         ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Consul Server Cluster (3 nodes)               │  │
│  │         - Service Discovery                              │  │
│  │         - Configuration Management                       │  │
│  │         - Service Catalog                                │  │
│  │         - ACL Management                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Google Kubernetes Engine                        │
│                    (Regional Cluster)                            │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐               │
│  │   Zone A   │  │   Zone B   │  │   Zone C   │               │
│  │  (1 node)  │  │  (1 node)  │  │  (1 node)  │               │
│  └────────────┘  └────────────┘  └────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. GKE Cluster

**Configuration:**

- **Type**: Regional cluster (3 zones)
- **Nodes**: 1 node per zone (3 total)
- **Machine Type**: e2-standard-4 (4 vCPU, 16 GB memory)
- **Networking**: VPC-native with IP aliasing
- **Workload Identity**: Enabled for secure GCP service account binding

**Features:**

- Auto-repair and auto-upgrade enabled
- Horizontal Pod Autoscaling
- HTTP Load Balancing
- Node autoscaling (1-3 nodes per zone)

### 2. Consul Server Cluster

**Configuration:**

- **Replicas**: 3 (HA configuration)
- **Storage**: 10Gi persistent volume per server
- **Storage Class**: standard-rwo (GCP persistent disk)
- **Resources per server**:
  - Requests: 500Mi memory, 500m CPU
  - Limits: 1Gi memory, 1000m CPU

**Features:**

- TLS enabled for all communication
- ACLs enabled with bootstrap token
- Metrics collection enabled
- Pod anti-affinity for zone distribution
- Persistent storage for data durability

### 3. Consul Connect (Service Mesh)

**Components:**

- **Connect Inject**: Automatically injects Envoy sidecars
- **CNI Plugin**: Traffic redirection without init containers
- **Envoy Proxy**: Sidecar proxy for each service

**Features:**

- Automatic mTLS between services
- Service-to-service authorization via intentions
- Traffic management and routing
- Observability (metrics, tracing)

### 4. Consul API Gateway

**Configuration:**

- **Type**: Kubernetes Gateway API compliant
- **Service Type**: LoadBalancer (GCP Load Balancer)
- **Listeners**:
  - HTTP (port 80): Redirects to HTTPS
  - HTTPS (port 443): TLS termination

**Features:**

- Native Kubernetes Gateway API support
- TLS termination with cert-manager certificates
- Cross-namespace routing with ReferenceGrants
- HTTP to HTTPS automatic redirect

### 5. cert-manager

**Configuration:**

- **Version**: v1.17.1
- **Namespace**: cert-manager
- **Gateway API Support**: Enabled

**Features:**

- Automated certificate issuance and renewal
- Let's Encrypt integration (staging and production)
- DNS-01 challenge via Google Cloud DNS
- Workload Identity for GCP authentication
- 90-day certificates with 30-day renewal window

### 6. Workload Identity

**Purpose**: Secure authentication between Kubernetes and GCP services

**Bindings:**

- cert-manager → dns01-solver service account
- Enables DNS-01 challenges without storing credentials

**Benefits:**

- No service account keys stored in Kubernetes
- Automatic credential rotation
- Fine-grained IAM permissions

## Network Flow

### External Request Flow

1. **Client Request** → GCP Load Balancer (API Gateway)
2. **TLS Termination** → cert-manager managed certificate
3. **Gateway Routing** → HTTPRoute matches path
4. **Service Mesh Entry** → Envoy sidecar intercepts
5. **Intention Check** → Consul validates authorization
6. **mTLS Connection** → Encrypted service-to-service
7. **Service Processing** → Application handles request
8. **Response Path** → Reverse of above

### Service-to-Service Communication

1. **Service A** makes request to `localhost:9091`
2. **Envoy Sidecar** intercepts the request
3. **Consul** provides service discovery
4. **mTLS Handshake** establishes secure connection
5. **Intention Validation** checks authorization
6. **Service B Sidecar** receives encrypted traffic
7. **Service B** processes request on actual port

## Security Architecture

### Defense in Depth

1. **Network Layer**:
   - VPC-native networking
   - Private cluster option available
   - Network policies (optional)

2. **Transport Layer**:
   - TLS for all Consul communication
   - mTLS for service-to-service
   - TLS 1.2+ for external traffic

3. **Application Layer**:
   - ACL-based access control
   - Service intentions (authorization)
   - JWT validation (optional)

4. **Identity Layer**:
   - Workload Identity for GCP
   - Service accounts per service
   - Consul service identities

### ACL Model

```
Bootstrap Token (root)
    │
    ├─── Consul Server Tokens
    │
    ├─── Connect Inject Token
    │
    ├─── API Gateway Token
    │
    └─── Service Tokens (per service)
```

## Data Flow

### Certificate Issuance Flow

1. **Certificate Request** → cert-manager creates Certificate resource
2. **ACME Challenge** → cert-manager creates Order and Challenge
3. **DNS Record** → dns01-solver creates TXT record in Cloud DNS
4. **Validation** → Let's Encrypt validates DNS record
5. **Certificate Issued** → cert-manager stores in Kubernetes Secret
6. **Gateway Update** → API Gateway uses new certificate
7. **Auto-Renewal** → Process repeats 30 days before expiry

### Service Registration Flow

1. **Pod Creation** → Kubernetes creates pod
2. **Sidecar Injection** → Connect inject adds Envoy container
3. **Service Registration** → Consul registers service
4. **Health Checks** → Consul monitors service health
5. **Service Discovery** → Other services can discover it
6. **Intention Enforcement** → Authorization rules apply

## Scalability

### Horizontal Scaling

- **Consul Servers**: 3-5 recommended (odd number)
- **Application Services**: Scale via Kubernetes Deployments
- **API Gateway**: Multiple replicas supported
- **GKE Nodes**: Auto-scaling 1-3 per zone

### Vertical Scaling

- **Consul Servers**: Increase resources as catalog grows
- **Envoy Sidecars**: Adjust based on traffic volume
- **Application Pods**: Set appropriate resource limits

## High Availability

### Consul HA

- 3 server replicas across 3 zones
- Raft consensus for leader election
- Automatic failover on server failure
- Persistent storage for data durability

### GKE HA

- Regional cluster spans 3 zones
- Node auto-repair and auto-upgrade
- Pod anti-affinity spreads workloads
- Multiple replicas for each service

### Gateway HA

- Multiple gateway replicas (optional)
- GCP Load Balancer health checks
- Automatic traffic distribution

## Monitoring and Observability

### Metrics Collection

- **Consul Metrics**: Prometheus format
- **Envoy Metrics**: Per-sidecar statistics
- **Gateway Metrics**: Request/response metrics

### Logging

- **Consul Logs**: Server and agent logs
- **Sidecar Logs**: Envoy access and error logs
- **Application Logs**: Standard container logs

### Tracing (Optional)

- Distributed tracing via Envoy
- Integration with Jaeger/Zipkin
- Request correlation across services

## Disaster Recovery

### Backup Strategy

1. **Consul Snapshots**: Regular snapshots of Consul data
2. **Persistent Volumes**: Backed by GCP persistent disks
3. **Configuration**: Store in version control (GitOps)

### Recovery Procedures

1. **Consul Restore**: From snapshot
2. **Certificate Recovery**: cert-manager auto-reissues
3. **Service Recovery**: Kubernetes self-healing

## Cost Optimization

### Resource Efficiency

- Right-size node machine types
- Use node auto-scaling
- Set appropriate resource requests/limits
- Consider preemptible nodes for non-production

### Network Costs

- Use regional clusters to minimize cross-zone traffic
- Consider private clusters to reduce egress
- Optimize service mesh traffic patterns

## Future Enhancements

### Potential Additions

1. **Multi-Datacenter**: Consul federation across regions
2. **Service Mesh Observability**: Prometheus + Grafana
3. **Advanced Traffic Management**: Canary deployments, A/B testing
4. **API Gateway Features**: Rate limiting, authentication
5. **Secrets Management**: Vault integration
6. **GitOps**: ArgoCD or Flux for deployment automation

## References

- [Consul Architecture](https://developer.hashicorp.com/consul/docs/architecture)
- [Consul on Kubernetes](https://developer.hashicorp.com/consul/docs/k8s)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
