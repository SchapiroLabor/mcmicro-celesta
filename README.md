# Cell phenotyping using CELESTA tailored to MCMICRO outputs, formatted for implementation in nf-core modules

mcmicro nf-core module for cell phenotyping using CELESTA

## CELESTA_CLI.R

[CELESTA](https://github.com/plevritis-lab/CELESTA) script with a CLI implementation using the [optparse](https://github.com/trevorld/r-optparse) R Package.

### Overview of changes compared to the original Script

    - Added the [optparse](https://github.com/trevorld/r-optparse) R Package
    - implemented CLI input options as a list
    - Checking if mandatory inputs were provided
    - Changing columns of image_data provided to fit requirements for CELESTA
    - If optional vector inputs are not given, a custom vector is created that consists of only `1`
    - Checking if folder output and a title were provided
    - Surpressing the default `save_result` output from `AssignCells()`
    - Creating the desired CSV output by getting `final_cell_tyoe_assignment`, `coords`and `marker_exp_prob` from the `CelestaObj`

### How to use CELESTA_CLI

    - `-i` `--image_data` which should provide the path to the quantification output as a .csv (e.g. after running MCMICRO). The file should include marker intensities, CellID and X/Y columns. This input is mandatory.
    - `-s`/`--signature` which shoould provide the path to the signature matrix for cell type definition (also known as prior marker info) as a .csv file. Description found here [CELESTA](https://github.com/plevritis-lab/CELESTA). This input is mandatory.
    - `--anchor_high` which should provide the path to a 1 row .csv file (i.e. a vector) to define high thresholds for anchor cell identification. Examples can be found [here](https://github.com/plevritis-lab/CELESTA/tree/main/data). This input is mandatory.
    - `--index_high`which should provide the path to a 1 row .csv file (i.e. a vector) to define high thresholds for index cell identification during iteration. Examples can be found [here](https://github.com/plevritis-lab/CELESTA/tree/main/data). This input is mandatory.
    - `--anchor_low` which should provide the path to a 1 row .csv file (i.e. a vector) to define low thresholds for anchor cell identification. Examples can be found [here](https://github.com/plevritis-lab/CELESTA/tree/main/data). This input is optional. If not provided, a vector consisting of only `1`, with length equal to input from `--anchor_high`, will be created.
    - `--index_low`which should provide the path to a 1 row .csv file (i.e. a vector) to define low thresholds for index cell identification during iteration. Examples can be found [here](https://github.com/plevritis-lab/CELESTA/tree/main/data). This input is optional. If not provided, a vector consisting of only `1`, with length equal to input from `--anchor_high`, will be created.
    - `-o`/`--output`, which should provide the path to the output folder. This input is optional. If not provided, the current working directory will be used.
    - `-t`/`--title`, which should be a user-defined tag that will be used to define the project title inside the CELESTA algorithm and will be provided in the result .csv file
