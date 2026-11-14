# Mallikarjuna-et-al-2026

### Title
Linking farm and laboratory records to identify risk patterns of large offspring syndrome-compatible events in bovine in vitro embryo production

### Summary
Large offspring syndrome (LOS) is a rare congenital epigenetic disorder of ruminants associated with assisted reproduction. Its risk factors in commercial herds are poorly known.

This repository contains the analysis code for a retrospective cohort study. The study links the routine records of a commercial dairy farm (calvings, cesarean sections, navel treatments, embryo transfers, donor and recipient records) to those of its ovum pick-up (OPU) and in vitro embryo production (IVP) laboratory. It then uses three model families, gradient boosting with Shapley values, LASSO-selected Firth logistic regression and classification trees, to identify factors present before embryo transfer that are associated with LOS-compatible events.

The analysis is exploratory. Its results are hypotheses for molecular and prospective studies.

### LOS overview
LOS is associated with assisted reproductive technologies. Its signs include fetal overgrowth, dystocia, abdominal wall and umbilical defects, and difficulty breathing and suckling. No standardized early diagnosis exists, and no single sign is present in every case.

Birth weight and a clinical diagnosis were not recorded on the study farm. The outcome is therefore a record-based case definition (below), not diagnosed LOS.

### Study data
- 6,223 calves are registered in the farm file. The laboratory records hold 1,390 donor-lot records from 778 OPU sessions at two laboratory sites.
- **Analysis set:** 652 singleton calves born from 1 January 2023 to 23 December 2024, with 54 LOS-compatible events (8.3%). They come from 51 laboratory lots, 65 donor clusters and 72 sires.
- **Outcome (LOS-compatible event):** at least one of the following:
  - a cesarean section within 3 d of birth;
  - a navel event within 30 d of birth (antibiotic treatment, ultrasonographic examination or surgical repair of the umbilicus);
  - a calving remark describing the calf as big or huge.
- **Candidate predictors:** 23 variables measured before embryo transfer, covering the donor, superovulation, OPU, maturation, fertilization, embryo production, frozen storage and transfer.

Earlier versions of this repository described 1,171 records with 65 cases. That file came from an earlier, conventional analysis of the same records. It is kept only as the comparator in the comparison with a conventional analysis (Supplementary Table S5).

### How the analysis set is built
| Step | Calves | Events |
|---|---:|---:|
| Calves registered in the farm file | 6,223 | – |
| With a recipient (dam) identity | 6,202 | 85 |
| Linked to a pregnancy-confirmed embryo transfer (implied gestation 250–310 d) | 1,638 | 65 |
| Genetic dam resolved; purchased/external embryos excluded | 1,501 | 61 |
| Linked to a laboratory lot | 1,386 | 57 |
| Born from 1 January 2023 | 1,030 | 57 |
| Singletons | 1,017 | 57 |
| Born within the outcome-recording window (to 23 December 2024) | 652 | 54 |

#### Record linkage
- **Embryo transfers.** Calves are linked by recipient identity to transfers diagnosed pregnant. The implied gestation (calving − transfer + 7 d) must be 250–310 d; if several transfers qualify, the one closest to 280 d is kept. Transfers recorded as open are not used.
- **Laboratory lots.** Calves are matched to laboratory lots of the genetic dam (or, for pooled lots, of the donors listed on the transfer record) and the sire, with a lot date on or before the transfer date. The most recent lot is kept, and matches with several candidate lots are flagged.
- **Linkage check.** Against the laboratory's embryo-level records, the linked lot contained a frozen embryo of the stage and quality recorded on the transfer sheet for 98.0% of calves, against 86.5% for randomly assigned lots.
- **Purchased embryos.** Calves with genetic dam 99999 come from embryos whose donors do not appear in the laboratory files. They are excluded.

#### Outcome-recording window
The three outcome sources cover different periods:
- navel events: 14 January 2023 – 23 December 2024;
- cesarean sections: 1 February 2023 – 27 September 2024;
- calving remarks: 1 January 2023 – 3 March 2025.

Calves born after the navel records ended cannot be classified, so the main analysis ends on 23 December 2024.

From July 2024, navel events were recorded far more often, and ultrasonographic and surgical entries appear for the first time. Every model therefore includes a recording-period indicator (before vs from 1 July 2024) as an adjustment, not as a candidate risk factor.

#### Verification of laboratory fields
- **Clock times, not durations.** The fields labelled maturation, fertilization and stripping "time" are the clock times (minutes after midnight) at which each step began. The analysis uses the separate duration fields. In every OPU session with complete fields:
  - IVM duration = 1,440 − IVM start + IVF start (range 22–29 h);
  - IVF duration, the time oocytes are co-incubated with sperm = 1,440 − IVF start + denudation start (range 18–24 h).
- **Denudation.** Only its start time is recorded, so its duration cannot be examined.
- **Superovulation protocol codes.** The older in-house codes P180F, P240F and P300F (total FSH dose in six injections: 180, 240 and 300 mg) are recoded to their equivalents, 1.5, 2 and 2.5 cc FSH × 6.
- **Embryo stage.** The transfer-sheet field "Stage" is the IETS stage code (4–8), not embryo age. Every embryo in the laboratory records was frozen on day 7.
- **Cumulus morphology.** It is expressed as the proportion of structures with ≥ 3 cumulus layers among all structures found in the OPU session.

#### Five checks before modeling
1. Laboratory fields are verified against the laboratory's definitions (clock times are not analyzed as durations).
2. Calves are linked only to transfers diagnosed pregnant.
3. The analysis is restricted to the period in which every outcome record was kept.
4. Every model includes the recording-period indicator.
5. Calves from the same donor are kept together in the same training, test or cross-validation fold.

### Models
- **Gradient boosting (H2O AutoML).** 40 models are compared using 5-fold cross-validation, with folds grouped by donor cluster. The best tree-based model is interpreted with SHAP values, permutation importance, calibration and decision curves.
- **LASSO-selected Firth logistic regression.** Recording period is unpenalized. Confidence intervals use donor-cluster-robust standard errors. Pre-specified exposures are each fitted with recording period on all 652 calves, and these estimates are used for inference.
- **Classification and regression tree (CART).** Case weights 1:5. A conditional inference tree (partykit) is fitted as a check.

Calves are split into a training set (547 calves, 42 events) and a test set (105 calves, 12 events) by donor cluster, so calves sharing a donor or OPU lot never appear in both. Models are compared on cross-validated PR-AUC, and the test set is used once.

### Validation and sensitivity analyses
- **Comparison with a conventional analysis.** The main analysis is compared with a conventional analysis of the same records, adding the five checks one at a time.
- **Single-split selection.** The optimism of choosing a model on a small validation set is quantified.
- **Permutation test.** The cross-validated signal is tested against chance, with the outcome permuted completely and within recording period.
- **Sensitivity analyses:**
  - alternative outcome definitions, analysis sets and recording windows;
  - alternative donor-age cut-points;
  - every stimulation protocol by recording period;
  - donor starting state;
  - bootstrap stability of the LASSO selection.
- **Record checks:**
  - linkage against embryo-level records and alternative linkage rules;
  - clustering of events within lots and donors;
  - types of navel records over time;
  - cumulus scores over time;
  - registration of calves in the calf file (only 35% of embryo-transfer bull calves and almost no calves dead at birth are registered).
- **Further analyses:**
  - a multiverse (specification-curve) analysis of 72 specifications;
  - sibling and within-session comparisons;
  - gestation length as a second outcome, and by event type;
  - time of day of laboratory procedures.

### Main results (exploratory)
- **Discrimination was modest.** The cross-validated PR-AUC was 0.16 (no-skill value 0.08), and the test-set PR-AUC 0.42 (no-skill 0.11; 12 events). The cross-validated signal exceeded chance when the outcome was permuted completely (P = 0.005), but not clearly when it was permuted within recording period (P = 0.070).
- **The sample was far below what a stable model needs.** There were 2.3 events per variable; about 28,600 calves (about 2,400 events) would be needed for a stable model (pmsampsize).
- **One donor and oocyte signal.** A higher proportion of oocytes with ≥ 3 cumulus layers was the only variable selected by every model (OR 1.20 per 10 percentage points, 95% CI 1.07–1.35). It overlapped with donor age ≤ 9 months and the 1.5 cc FSH × 6 protocol, used mainly in these donors, so the three are read as one donor and stimulation signal. All three associations weakened when antibiotic-only navel treatments (25 of the 54 events) were excluded: OR 1.28 (0.60–2.73) for donor age ≤ 9 months, 1.51 (0.60–3.76) for the 1.5 cc FSH × 6 protocol and 1.07 (0.90–1.28) for cumulus morphology.
- **No association** was found for IVM and IVF durations, heparin concentration, semen type or season of transfer.
- **Gestation length differed by event type.** Calves with a cesarean or a "big" remark (n = 19) were born 2.9 d later than calves without an event (281.3 vs 278.4 d; 95% CI 1.1–4.7), whereas calves with only navel events were not (278.6 d). No calf was born after 288 d of gestation, although linkage allowed up to 310 d.
- **Male calves** had lower odds of an event (OR 0.27). This more likely reflects recording than biology: all "big" remarks and cesareans were recorded for heifers, navel events occurred at similar rates in both sexes, and only 35% of embryo-transfer bull calves were registered in the calf file.
- **The checks mattered.** Without them, the same records suggested laboratory-timing and seasonal effects that did not persist.

### Repository contents
- `LOS_Analysis.ipynb`: the complete analysis, from the raw files to every figure and table in the paper and its Supplement. Outputs that display raw farm or laboratory records have been cleared.
- `Figures/`, `Tables/`, `Outputs/`: written by the notebook. Figures are saved as PDF, 600-dpi TIFF and 300-dpi PNG; tables as CSV and XLSX.

### How to run
- **Environment.** The notebook runs in Google Colab with R through `rpy2`. Set `BASE_DIR` in the *Paths and packages* cell to the folder holding `raw_data/` (farm and laboratory files) and `conventional_analysis_dataset.csv`.
- **Running it.** Run all cells in order (*Runtime → Run all*). H2O AutoML and the permutation test take several hours.
- **Software.** The analysis was run in R 4.6.1 with h2o 3.44.0.3, glmnet, brglm2, sandwich, rpart, partykit, survival, gbm, pROC, PRROC, pmsampsize, ResourceSelection, dcurves and ggplot2 (full versions in `Outputs/sessionInfo.txt`).
- **Reproducibility.** R results are reproducible with the seeds set in the cells. H2O AutoML results can differ slightly between H2O versions and machines.
- **Reporting.** Reporting follows STROBE-Vet and RECORD, with elements of TRIPOD+AI.

### Data availability
The farm and laboratory records belong to the commercial farm and the embryo-production laboratory. They are not included in this repository and are not publicly available.

Requests for the laboratory data should be directed to the laboratory and are subject to its permission. Requests for the farm data should be directed to the corresponding author and are subject to the farm's permission.

### Citation
Linking farm and laboratory records to identify risk patterns of large offspring syndrome-compatible events in bovine in vitro embryo production. Theriogenology [year; volume; pages; DOI – to be added on publication].

### Contact
Lipika Mallikarjuna, Department of Animal Science, Cornell University – lm2225@cornell.edu
