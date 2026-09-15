# Phase 01 — Multi-cloud connection model

**P0 · PARTIAL**

One canonical connection model across AWS, Azure, GCP and OCI.

## Done

`cloud_connections` is already multi-provider and carries tenant, org,
provider, native account id, display name, scan scope, billing scope,
timestamps, last validation, last sync, and error state.

Bounding is enforced server-side: reads are intersected with the caller's
grants **and** the active folder/project scope, and by-id reads return **404**
rather than 403 so an unseen id is never confirmed to exist.

## Missing — the state machine

Statuses remain `connected` / `disconnected` / `error`. The required model is:

```
PENDING -> VALIDATING -> CONNECTED
              |              |
           ERROR        DEGRADED / PAUSED -> DISCONNECTED
```

`DEGRADED` matters most: a connection whose collection partly failed is not
healthy and not disconnected, and today it has nowhere to live.

## Invariant already enforced

A disconnected connection must not count as connected, appear healthy, start a
sync, or produce current cost, health or posture. The UI already removes Sync
Now / Validate / Disconnect for disconnected connections and explains why —
the server 409s those anyway, so the controls guaranteed an error.

## Missing

- `DEGRADED` and `PAUSED` states and their transitions
- disconnect **impact preview** — what is lost, before it is lost
- management-group (Azure) and folder/organization (GCP) scope as
  first-class connection scope
