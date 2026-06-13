# jenner-check

These bundles run your SAS code on [Jenneranalytics.com](https://jenneranalytics.com),
an API that executes SAS — more than 200 procedures supported. Each bundle is a
small, self-contained example adapted from a script in this repository, paired
with a frozen snapshot of the output it produced.

## Run them

You need `bash` and `curl` (both ship with macOS 12+ and every mainstream
Linux distro). No SAS or Jenner license required — the runner POSTs to the
hosted API.

```sh
cd jenner-check
./run_jenner.sh --list      # list the bundles
./run_jenner.sh --all       # run every bundle, print a pass/fail summary
./run_jenner.sh t001_compare_datasets_merge   # run just one
```

On Windows without WSL, use `run_jenner.bat <bundle>\script.sas` (single-file
mode). Or paste a `script.sas` straight into the hosted workspace at
[jenneranalytics.com](https://jenneranalytics.com).

## What's in a bundle

```
tNNN_<slug>/
├── script.sas        # the SAS that runs (adapted from a repo script)
├── autoexec.sas      # options + any setup, prepended before script.sas
├── expected.json     # stable fields pinned from a passing run
└── expected/
    ├── log.txt       # the SAS log from that run, verbatim
    ├── output.txt    # the listing output, verbatim
    └── files.md      # links to any files / datasets the run produced
```

`run_jenner.sh <bundle>` concatenates `autoexec.sas` and `script.sas`, submits
them together, and prints `status`, `exit_code`, and the first lines of the log
so you can eyeball the result against `expected/`.

## The bundles

| Bundle | From | What it shows |
|--------|------|---------------|
| `t001_compare_datasets_merge`   | `SAS/compare_datasets.sas`            | A merge that flags rows present in one dataset, the other, or both |
| `t002_macro_repeat_over_records`| `SAS/%repeat_over_records_dataset`    | Walking a dataset record-by-record with the SAS function interface (`OPEN`/`ATTRN`) and `CALL SYMPUTX` |
| `t003_transpose_long2wide`      | `SAS/transpose_long2wide`             | `PROC TRANSPOSE` reshaping long measurements to one row per subject |
| `t004_format_from_dataset`      | `SAS/formats_working_with_formats.sas`| Building a numeric format from a dataset with an `OTHER` catch-all (`cntlin`, `hlo='o'`) |
| `t005_proc_tabulate_categorical`| `SAS/proc_tabulate_categorical_vars`  | `PROC TABULATE` of a categorical outcome by arm, with mean / sum / n / nmiss |

Bundles that read external libraries or local paths in the original scripts use
small inline sample data here so each one runs in isolation; the SAS logic is
otherwise unchanged from the repo.
