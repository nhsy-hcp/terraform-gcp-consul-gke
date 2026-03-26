# Agent Mandates: Consul on GKE with Terraform

This document defines the foundational mandates and operational context for AI agents working on the `terraform-gcp-consul-gke` project.

## Project Mission

Provide a production-ready, automated deployment of HashiCorp Consul service mesh on GKE using Terraform and Helm.
Features include automated TLS via cert-manager and Google Cloud DNS.

## Technical Landscape

- **Infrastructure:** Terraform (latest stable version, minimum v1.5+), Google Cloud Platform (GCP).
- **Orchestration:** Google Kubernetes Engine (GKE) - Regional Clusters.
- **Service Mesh:** HashiCorp Consul (Connect, API Gateway, CNI).
- **Certificate Management:** cert-manager (DNS-01 solver with Google Cloud DNS).
- **Package Management:** Helm (v3.6+).
- **Automation:** Taskfile (go-task), Shell scripts.

## Foundational Mandates

### 1. Infrastructure Management (Terraform)

- **Modular Design:** Always organize new infrastructure into reusable modules within `terraform/modules/`.
- **State Integrity:** Never manually modify resources created by Terraform. Use `task apply` for all infrastructure changes.
- **Provider Standards:** Adhere to the provider versions specified in `terraform/main.tf`.
- **Latest Versions:** Always use the latest stable Terraform version (minimum v1.5+).
  When adding new providers, use the Terraform MCP server's `get_latest_provider_version` tool
  to check for the latest version before adding to configuration.
- **Variables:** Prefer `terraform.tfvars` for local configuration; ensure all new variables are documented in `variables.tf`.
- **Module Constraints:** Do not add `terraform` blocks or provider version constraints to individual modules.
  All provider versions and Terraform version requirements must be managed centrally in the root configuration (e.g., `terraform/terraform.tf`).

### 2. Kubernetes & Helm

- **Namespace Isolation:** Deploy Consul to the `consul` namespace and application services to their respective namespaces (defaulting to `default` or `services`).
- **Terraform-Only Deployments:** ALL Kubernetes workloads and Helm charts MUST be deployed via Terraform modules. NEVER use `helm install` or `helm upgrade` commands directly.
- **Helm Integration:** Helm charts in `helm/` directory are deployed exclusively through Terraform's `helm_release` resources in the `modules/consul-gateway/` and `modules/consul-services/` modules.
- **Values Templating:** Use `terraform/templates/consul-values.yaml.tpl` for dynamic Consul configuration.
- **Validation:** Always validate `consul-values.yaml.tpl` against the schema [official Consul Helm chart values.yaml](https://github.com/hashicorp/consul-helm/blob/master/values.yaml)
  to ensure structure and compatibility.
- **LoadBalancer IP Wait:** The `consul-gateway` module includes a `null_resource` that automatically waits up to 120 seconds for GCP to assign a LoadBalancer external IP. This ensures the `apigw_lb_address` output is always populated on successful deployment, eliminating race conditions. The wait is triggered via `scripts/wait-for-lb-ip.sh` and re-runs only when the gateway Helm release is recreated.

### 3. Security & Identity

- **Workload Identity:** Always use GKE Workload Identity for GCP service account authentication. Avoid using static service account keys.
- **mTLS & ACLs:** Ensure Consul Connect mTLS and ACLs remain enabled in all production-like configurations.
- **Secret Protection:** Never commit secrets, terraform state files, or sensitive `.tfvars` to source control.

### 4. Automation & Tooling

- **Task-First Workflow:** Use the `Taskfile.yml` commands as the primary interface for project operations.
- **Scripting:** Place utility or maintenance scripts in `scripts/`. Ensure they are idempotent and include error handling.

#### Primary Task Commands

| Category | Command | Description |
| :--- | :--- | :--- |
| **Setup** | `task init` | Initialize Terraform and download providers |
| | `task validate` | Validate Terraform configuration |
| | `task plan` | Show Terraform execution plan |
| **Deploy** | `task apply` | Staged deployment (prereqs → gke → consul → cert-manager → helm-charts) |
| | `task apply:prereqs` | Stage 1 - Deploy VPC, APIs, etc. |
| | `task apply:gke` | Stage 2 - Deploy GKE cluster |
| | `task apply:consul` | Stage 3 - Deploy Consul service mesh |
| | task apply:cert-manager | Stage 4 - Deploy cert-manager |
| | task apply:helm-charts | Stage 5 - Deploy initial app helm charts via Terraform |
| | task apply:helm-charts:gateway | Deploy API Gateway and TLS certificate |
| | task apply:helm-charts:services | Deploy sample services and HTTPRoutes |
| | task apply:helm-charts:verify | Verify complete deployment and connectivity |
| **Kubernetes** | task gke:credentials | Get GKE cluster credentials (configure kubectl) |
| | `task deploy:services` | Deploy sample services (backend/frontend) via Helm |
| | `task deploy:gateway` | Deploy API Gateway, routes, and TLS via Helm |
| | `task deploy:all` | Deploy all sample services and API Gateway |
| **Status & Ops** | `task status` | Show status of all components |
| | `task consul:get-token` | Retrieve Consul bootstrap ACL token |
| | `task consul:port-forward` | Port-forward Consul UI to localhost:8501 |
| | `task gateway:get-ip` | Get API Gateway external IP |
| | `task gateway:test` | Test API Gateway endpoints |
| **UI Operations** | `task ui` | Open frontend, backend, and Consul UI in browser |
| | `task ui:consul` | Open Consul UI only |
| | `task ui:gateway` | Open API Gateway URL |
| **Logs** | `task consul:logs` | Show Consul server logs |
| | `task cert-manager:logs` | Show cert-manager logs |
| **Cleanup** | `task destroy` | Destroy all Terraform-managed infrastructure |
| | `task clean` | Clean up temporary files and caches |

### 5. Source Control

- **Explicit Staging:** NEVER use `git add .` or `git add -A`. Always explicitly stage files by naming them individually or using targeted glob patterns.
- **Selective Commits:** Prefer smaller, logical commits over large, monolithic ones.

## Operational Workflows

### Infrastructure Updates

1. Modify Terraform modules or root configuration.
2. Run `task plan` to verify changes.
3. Run `task apply` to execute updates.
4. Verify with `task status`.

### Service Deployment

1. Update Helm charts in `helm/`.
2. Deploy using `task deploy:services` or `task deploy:gateway`.
3. Test connectivity using `task gateway:test`.

## Neo4j Terraform Validation

This project integrates with a Neo4j database containing Terraform provider schemas for validation and discovery.

### Common Neo4j Queries

**Find all resources for a specific provider:**

```cypher
MATCH (p:TF_Provider {name: 'google'})-[:TF_HAS_RESOURCE]->(r:TF_Resource)
RETURN r.full_name, r.description
LIMIT 10;
```

**Count resources per provider:**

```cypher
MATCH (p:TF_Provider)-[:TF_HAS_RESOURCE]->(r:TF_Resource)
RETURN p.name, count(r) AS resource_count
ORDER BY resource_count DESC;
```

**Find all attributes of a specific resource:**

```cypher
MATCH (r:TF_Resource {full_name: 'google_container_cluster'})-[:TF_HAS_ATTRIBUTE]->(a:TF_Attribute)
RETURN a.name, a.type, a.required, a.description;
```

**Find all required attributes for a resource:**

```cypher
MATCH (r:TF_Resource {full_name: 'google_compute_network'})-[:TF_HAS_ATTRIBUTE]->(a:TF_Attribute {required: true})
RETURN a.name, a.type, a.description;
```

**Find resources with a specific attribute:**

```cypher
MATCH (r:TF_Resource)-[:TF_HAS_ATTRIBUTE]->(a:TF_Attribute {name: 'project'})
WHERE r.provider = 'google'
RETURN r.full_name, r.name
LIMIT 20;
```

**Find data sources for a provider:**

```cypher
MATCH (p:TF_Provider {name: 'google'})-[:TF_HAS_DATASOURCE]->(d:TF_DataSource)
RETURN d.full_name, d.description
LIMIT 10;
```

### Validation Workflow

1. **Resource Discovery:** Query Neo4j to verify all Terraform resources exist in the provider schema
2. **Attribute Validation:** Check that required attributes are configured in Terraform files
3. **Relationship Mapping:** Validate resource dependencies using `TF_REFERENCES` relationships
4. **Schema Compliance:** Ensure attribute types and constraints match Neo4j schema definitions

## Terraform MCP Server Integration

This project integrates with the Terraform MCP (Model Context Protocol) server for provider version management, module discovery, and documentation access.

### Available Tools

#### Version Management

##### get_latest_provider_version

- Fetches the latest version of a Terraform provider from the public registry
- Parameters: `name` (provider name, e.g., 'aws', 'google'), `namespace` (publisher, e.g., 'hashicorp')
- Use case: Check for provider updates, validate version constraints

##### get_latest_module_version

- Fetches the latest version of a Terraform module from the public registry
- Parameters: `module_name`, `module_provider`, `module_publisher`
- Use case: Discover latest module versions before adding dependencies

#### Module Discovery & Documentation

##### search_modules

- Searches for Terraform modules based on a query string
- Returns: List of matching modules with metadata (name, description, verification status, downloads)
- Use case: Find reusable modules for infrastructure components
- **Important:** Must be called before `get_module_details` to obtain valid `module_id`

##### get_module_details

- Fetches detailed documentation for a specific Terraform module
- Parameters: `module_id` (exact ID from `search_modules` results)
- Returns: Complete module documentation including inputs, outputs, examples
- Use case: Review module usage before integration

#### Provider Documentation

##### search_providers

- Searches provider documentation for specific services or resources
- Parameters: `service_slug`, `provider_name`, `provider_namespace`, `provider_version`, `provider_document_type`
- Document types: `resources`, `data-sources`, `functions`, `guides`, `overview`, `actions`, `list-resources`
- **Important:** Must be called before `get_provider_details` to obtain valid `provider_doc_id`

##### get_provider_details

- Fetches detailed documentation for a specific provider service
- Parameters: `provider_doc_id` (from `search_providers` results)
- Returns: Complete resource/data source documentation
- Use case: Review resource attributes and configuration options

##### get_provider_capabilities

- Analyzes provider capabilities and available resource types
- Parameters: `name`, `namespace`, `version` (optional)
- Returns: Summary of resources, data sources, functions, guides
- Use case: Discover what a provider can do before using it

#### Policy Management

##### search_policies

- Searches for Terraform policies (e.g., CIS benchmarks, security policies)
- Returns: List of matching policies with metadata
- **Important:** Must be called before `get_policy_details` to obtain valid `terraform_policy_id`

##### get_policy_details

- Fetches detailed documentation for a specific policy
- Parameters: `terraform_policy_id` (from `search_policies` results)
- Returns: Complete policy documentation and implementation guidance
- Use case: Implement compliance and security policies

### Operational Workflows (MCP)

#### Provider Version Auditing

1. List all providers from `terraform/terraform.tf`
2. For each provider, call `get_latest_provider_version` with name and namespace
3. Compare current constraints against latest versions
4. Document findings with upgrade recommendations
5. Prioritize updates: minor versions (safe) → major versions (breaking changes)

**Example workflow:**

```bash
# Current: google provider ~> 6.0
# Check latest: get_latest_provider_version(name='google', namespace='hashicorp')
# Result: 7.24.0
# Action: Plan major version upgrade with testing
```

#### Module Integration

1. Use `search_modules` to find candidate modules for a requirement
2. Review search results for verification status and popularity
3. Call `get_module_details` with the selected `module_id`
4. Review inputs, outputs, and examples
5. Integrate module into Terraform configuration
6. Document module source and version in `terraform.tf`

#### Provider Resource Discovery

1. Use `search_providers` to find specific resource documentation
2. Specify `provider_document_type` based on need (resources, data-sources, etc.)
3. Call `get_provider_details` with the returned `provider_doc_id`
4. Review resource schema and required attributes
5. Cross-reference with Neo4j schema validation if available

### Best Practices (MCP)

#### Version Management (MCP)

- **Regular Audits:** Check provider versions quarterly or before major deployments
- **Staged Updates:** Update minor versions first, then plan major version upgrades
- **Testing:** Always test major version upgrades in non-production environments
- **Documentation:** Document breaking changes and migration steps in `.plans/`

#### Module Usage

- **Verification:** Prefer verified modules from trusted publishers
- **Popularity:** Consider download counts as a signal of community trust
- **Version Pinning:** Always pin module versions in production configurations
- **Documentation:** Document module purpose and configuration in module README

#### Provider Documentation (MCP)

- **Discovery First:** Use `search_providers` before `get_provider_details`
- **Type Selection:** Choose correct `provider_document_type` for your need
- **Schema Validation:** Cross-reference with Neo4j for comprehensive validation
- **Examples:** Review provider examples before implementing new resources

#### Tool Call Sequencing

- **Search → Details:** Always call search tools before detail tools
- **One at a Time:** Execute tool calls sequentially, not in parallel
- **Error Handling:** If a detail tool fails, re-run the search tool to verify the ID

### Integration with Existing Workflows

#### Pre-Deployment Validation

```bash
# Before running `task apply`
1. Audit provider versions using MCP tools
2. Validate resource schemas against Neo4j
3. Review module documentation for updates
4. Check for security policies to implement
```

#### Module Addition Workflow

```bash
# When adding a new module
1. Search modules using MCP tools
2. Review module details and examples
3. Validate compatibility with current providers
4. Add module to terraform configuration
5. Run `task init` to download module
6. Run `task plan` to verify integration
```

#### Provider Upgrade Workflow

```bash
# When upgrading a provider
1. Check latest version using MCP tools
2. Review provider changelog and upgrade guide
3. Update version constraint in terraform.tf
4. Run `task init` to download new version
5. Run `task plan` to identify breaking changes
6. Test in non-production environment
7. Document changes in .plans/
```

## Contextual Precedence

The instructions in this file are foundational. If conflict arises:
`Project AGENTS.md` > `Task-specific instructions` > `General LLM knowledge`.
