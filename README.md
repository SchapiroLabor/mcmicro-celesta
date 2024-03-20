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
- Creating the desired CSV output by getting `final_cell_type_assignment` from the `CelestaObj` and binding it to the input from `--image_data'
- Creating a quality inspection .csv file from `marker_exp_prob` of the `CelestaObj`.

### Usage

| Option         | Description                                                                                                                                                         | Mandatory |
|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| -i/--image_data| Path to the quantification output as a .csv (e.g., after running MCMICRO). Includes marker intensities, CellID, and X/Y columns.                                      | Yes       |
| -s/--signature | Path to the signature matrix for cell type definition (prior marker info) as a .csv file. Description can be found [here](https://github.com/plevritis-lab/CELESTA).  | Yes       |
| --high         | Path to a .csv file with 2 rows defining high thresholds for anchor cell (row 1) and index cells (row2).                                                              | Yes       |
| --low          | Path to a .csv file with 2 rows defining low thresholds for anchor cell (row 1) and index cells (row2).                                                               | No        |
| -o/--output     | User-defined path to a output file, if not provided the result files will be saved in the current workingdirectory                                                    | No        |
| -t/--title     | User-defined tag used to define the project title inside the CELESTA algorithm and provided in the result .csv file.                                                  | No        |

## Docker Usage

To build the container:
```
git clone https://github.com/SchapiroLabor/mcmicro-celesta.git
docker build -t mcmicro_celesta:latest .
```

To run the docker container: 
```
## Note: Mount the local volume to the local folder in the directory
docker run --platform linux/amd64 -it --rm -v $(pwd):/local celesta Rscript /local/CELESTA_CLI.R <input_parameters>

```

To pull the container from the Github container registry (ghcr.io):
```
## Login to ghcr.io
docker login ghcr.io

## Pull container
docker pull ghcr.io/schapirolabor/mcmicro-celesta:v0.0.2
```
