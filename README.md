# Cell phenotyping using CELESTA tailored to MCMICRO outputs, formatted for implementation in nf-core modules

mcmicro nf-core module for cell phenotyping using CELESTA

## CELESTA_CLI.R

[CELESTA](https://github.com/plevritis-lab/CELESTA) script with a CLI implementation using the [optparse](https://github.com/trevorld/r-optparse) R Package.

### Overview of changes compared to the original Script

- Added the [optparse](https://github.com/trevorld/r-optparse) R Package
- implemented CLI input options as a list
- Checking if mandatory inputs were provided
- Changing columns of image_data provided to fit requirements for CELESTA
- If optional vector inputs are not given, a custom vector is created that consists of only 1s
- Checking if folder output and a title were provided
- Surpressing the default `save_result` output from `AssignCells()`
- Creating the desired CSV output by getting `final_cell_type_assignment`, `coords`and `marker_exp_prob` from the `CelestaObj`

### Usage

| Option         | Description                                                                                                                                                         | Mandatory |
|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| -i/--image_data| Path to the quantification output as a .csv (e.g., after running MCMICRO). Includes marker intensities, CellID, and X/Y columns.                                      | Yes       |
| -s/--signature | Path to the signature matrix for cell type definition (prior marker info) as a .csv file. Description found [here](CELESTA).                                          | Yes       |
| --anchor_high  | Path to a 1 row .csv file (i.e., a vector) defining high thresholds for anchor cell identification. Examples can be found [here](https://example.com).             | Yes       |
| --index_high   | Path to a 1 row .csv file (i.e., a vector) defining high thresholds for index cell identification during iteration. Examples can be found [here](https://example.com).| Yes       |
| --anchor_low   | Path to a 1 row .csv file (i.e., a vector) defining low thresholds for anchor cell identification. Examples can be found [here](https://example.com).            | No        |
| --index_low    | Path to a 1 row .csv file (i.e., a vector) defining low thresholds for index cell identification during iteration. Examples can be found [here](https://example.com). | No        |
| -o/--output    | Path to the output folder. If not provided, the current working directory will be used.                                                                             | No        |
| -t/--title     | User-defined tag used to define the project title inside the CELESTA algorithm and provided in the result .csv file.                                                | No        |

### Docker Usage

To build the container:
```
git clone
```
