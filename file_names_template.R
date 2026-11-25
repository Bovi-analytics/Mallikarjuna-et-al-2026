# Template: copy this file to BASE_DIR/file_names.R (next to raw_data/) and replace each placeholder.
# file_names.R holds the names of the files, sheets and fields that identify the farm, the laboratory and the
# embryo-transfer providers. It stays with the data and is not shared.

# Embryo-transfer workbook (raw_data/farm_frozen_embryo_transfers2017.xlsx): one sheet per embryo-transfer provider
ET_SHEETS <- c(et_a = "<sheet name of provider A>",
               et_b = "<sheet name of provider B>",
               et_c = "<sheet name of provider C>",
               et_d = "<sheet name of provider D>")

# Laboratory OPU-IVP summary exports, one per laboratory site (paths relative to BASE_DIR)
LAB_SUMMARY <- c(site_1 = "raw_data/lab_data/<site 1 summary>.xlsx",
                 site_2 = "raw_data/lab_data/<site 2 summary>.xlsx")

# Laboratory embryo-level ("Details") exports, one per laboratory site
LAB_DETAILS <- c(site_1 = "raw_data/lab_data/<site 1 details>.xlsx",
                 site_2 = "raw_data/lab_data/<site 2 details>.xlsx")

# Name of the laboratory's dam-number column after the column names are cleaned (lower case, spaces as "_")
LAB_DAM_NUMBER_COL <- "<dam number column>"
