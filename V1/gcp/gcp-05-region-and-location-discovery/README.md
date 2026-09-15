# GCP-05 — Region / location discovery

**Status: NOT STARTED**

**Depends on:** GCP-02

## Runtime evidence

`provider_regions` contains **only AWS rows**; GCP regions appear in `cloud_resources` (`us-central1`, `asia-southeast1`, `europe-west8`) but are catalogued nowhere.

## Missing

- GCP region and **zone** discovery — GCP has a zone layer AWS's model does not represent
- Global resource representation
- GCP has no partition concept; the AWS partition model does not transfer
