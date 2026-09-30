# Enpal Analytics Engineering Assignment

A dbt project modelling the Pipedrive CRM data into reusable layers, with the
monthly sales funnel report (`rep_sales_funnel_monthly`) built on top.

The brief asks the layers to serve future KPIs, not just this report, so the
report is a thin model over a set of dimensions and facts. A different report
later shouldn't need any change underneath.

## Running it

1. Start Docker Desktop.
2. `docker compose up -d` — Postgres on `localhost:5432` (`admin`/`admin`, db
   `postgres`), loads the six CSVs.
3. `pip install dbt-core dbt-postgres` if needed.
4. Build and test:

```
   dbt seed
   dbt run
   dbt test
```

   Add `--profiles-dir .` if you don't keep a profile in `~/.dbt`.

Output lands in the `public_pipedrive_analytics` schema.

## Layout

```
models/
  staging/    one view per source table, rename + cast only
  marts/
    core/     dimensions and facts, reused across reports
    reporting/rep_sales_funnel_monthly
seeds/        seed_funnel_steps.csv (the funnel definition)
tests/        singular tests on the report
```

- **staging** — 1:1 with the sources. Only exception is
  `stg_pipedrive__lost_reasons`, which unnests the lost-reason labels from the
  `fields` JSON.
- **core** — the reusable pieces: `dim_stages`, `dim_users`,
  `dim_activity_types`, `dim_lost_reasons`; `fct_deal_stage_changes` (one row per
  stage entry, `is_first_entry` flagged); `fct_deal_activities` (one row per
  activity); `dim_deals` (one row per deal, current state from the change log).
- **reporting** — counts distinct deals per step per month off the facts and
  joins `seed_funnel_steps` for labels and ordering.

## Decisions

- **Funnel defined in a seed, not SQL.** `seed_funnel_steps.csv` maps each step
  to its KPI name, order, and source (a `stage_id` or activity key). Adding or
  renaming a step is a one-row edit, and joins are on keys, not stage-name
  strings.
- **`kpi_name` vs `funnel_step`.** The brief names the columns but doesn't define
  them, so `funnel_step` is the ordered label ("Step 2.1") and `kpi_name` the
  readable name ("Sales Call 1").
- **First entry only.** Deals can re-enter a stage (15 cases); the report counts
  first entry per deal per stage. The fact keeps every entry for other uses.
- **Calls counted when completed.** Steps 2.1/3.1 count completed (`is_done`)
  calls; `is_done` is on the fact if you'd rather count all.

## Data quality

- **`activity_id` isn't unique** (11 reused ids), so the activity model uses a
  surrogate key and keeps `activity_id` as an attribute.
- **`lost_reason` is set on ~every deal**, so it's an attribute, not a lost flag
  or funnel step.
- **Activities and deal_changes are near-disjoint deal populations** (8 of 4,572
  overlap), so the call steps count a different set of deals than the stage
  steps — each count is right on its own, but the rows aren't one sequential
  funnel.

## Tests

72 tests: not_null / unique / relationships / accepted_values across sources and
models, plus three singular tests on the report (grain uniqueness,
deals_count > 0, and Step 1 reconciling to the created-deal count in `dim_deals`).

## AI use

I built this myself. The architecture, modelling decisions, judgement calls
(first-entry counting, completed-call handling, the kpi_name reading), and the
data-quality investigation are all mine.

I used AI to speed up the mechanical parts and as a thought partner:

- The repetitive query and config code, mainly the staging models (rename/cast SELECTs) and the YAML
  files.
- A second pair of eyes while reasoning through the design and the data.

Every model was reviewed, run, and tested by me.