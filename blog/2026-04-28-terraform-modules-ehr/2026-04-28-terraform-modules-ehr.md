---
layout: default
title: "Terraform Modules for a Cloud-Agnostic EHR"
date: 2026-04-28
tags: ["terraform", "devops", "healthcare", "aws", "azure", "infrastructure"]
image: "folium-ehr-tf.png"
is_new: true
excerpt: "Folium EHR’s Terraform implementation uses a lifecycle-based modules with small, stable outputs, because a flat “files + conditionals” setup don’t scale past one environment."
---

<div class="tldr">

Folium EHR’s Terraform implementation uses a lifecycle-based modules with small, stable outputs, because a flat “files + conditionals” setup don’t scale past one environment. The key win was making new environments and future cloud targets feel like config and state, not copy/paste and manual diffing.

</div>

Folium EHR is containerized and meant to stay portable: deploy to AWS or Azure when it makes sense, or run on‑prem as plain containers. That portability goal is what pushed me to clean up my Terraform.

In past projects I kept Terraform “organized” by splitting resources across files and using inline conditionals for dev vs prod. It worked until I had to change something across environments. Dev needed to be cheaper, prod needed more performance, and the same settings showed up in multiple places. Adding a third environment would’ve meant copy/paste and manual diffing.

So for Folium I switched to modules organized by lifecycle domain, with a small set of consistent outputs and a per-environment config/state approach. The goal was simple: adding environments and cloud targets should feel boring.

The Terraform pain that pushed me to refactor wasn’t “too many resources.” It was that the structure didn’t scale past one environment. I had a flat root split across `network.tf` / `db.tf` / `app.tf`, plus a bunch of inline conditionals for dev vs prod. It worked, but it was easy to miss a change because the same knob (CIDRs, SKUs, replica counts) lived in multiple places. If dev needed to be cheaper and prod needed to be faster, I ended up hunting through files to make sure everything stayed consistent.

So I reorganized Folium’s Terraform into lifecycle-based modules with a small, consistent set of outputs. Each module maps to a domain that changes together (network, monitoring, vault, database, runtime, app), and each exports the few outputs the next layer needs (IDs, names, hosts, identity, and logging workspace).

Environment handling also got simpler. I kept one root module, used a `default_config` plus per-environment overrides, and used one remote state file per environment. That made “add a new environment” feel like configuration work instead of a copy-and-diff exercise.

A few things got better immediately:

- Adding an environment stopped being a directory duplication problem.
- Module interfaces made refactors safer because dependencies were explicit.
- Secrets stayed in Key Vault, and runtime access was limited to the minimum roles the backend needs.
- The network can be toggled on for prod-style isolation without rewriting the stack.

It helped, but it came with tradeoffs. Modules don’t remove complexity, they move it. Cross-module wiring (especially secrets) can become its own abstraction layer, so I kept the few Key Vault secrets inline in the root because they sit between modules and didn’t earn reuse. Also, the typed `deployment_config` object works, but it gets verbose fast. Next time I’d keep module inputs flatter, even if it means a bit more repetition.

Splitting Terraform into files is organization, but it’s not architecture. The thing that scales is stable interfaces and a clean environment story.

## Resources

- [Terraform docs](https://developer.hashicorp.com/terraform/docs)
- [Terraform Modules overview](https://developer.hashicorp.com/terraform/language/modules)
- [Terraform Style Conventions](https://developer.hashicorp.com/terraform/language/style)
- [Terraform Backend (remote state)](https://developer.hashicorp.com/terraform/language/settings/backends)
- [AzureRM provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)