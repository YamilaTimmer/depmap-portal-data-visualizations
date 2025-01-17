# DepMap Visualiser (V. 0.1)

## Authors: 

- Yamila Timmer ([https://github.com/YamilaTimmer](https://github.com/YamilaTimmer))


## Description

The [Dependency Map](https://depmap.org/portal/) (DepMap) portal offers large batches of open-access cancer research data, in order to support new scientific discoveries within the field. However visualising large amounts of data has proven to be difficult. DepMap Visualiser is a tool that allows users to visualise DepMap data in various ways, such as barplots, boxplots and heatmaps. Users can do all of this while filtering on specific metadata to include/exclude the data, as the user wishes.


### Key-features
- Visualise large batches of DepMap data,
- Allows selecting different metadata parameters, to fine-tune data,
- The ability to save the generated visuals (.png) and the table data (.csv/.xlsx),
- User-friendly dashboard interface.

## System requirements and installation

### System requirements

- OS: Linux
- R: 4.0 or higher

### Installing tools
Download the following DepMap datasets from [https://depmap.org/portal/data_page/?tab=allData](https://depmap.org/portal/data_page/?tab=allData):

- `OmicsExpressionProteinCodingGenesTPMLogp1`
- `Model.csv`

Navigate to the top of the page and enter the two dataset names in the search bar.

![](media/download_data.png)


**Clone the repository**

```bash

git clone git@github.com:YamilaTimmer/depmap-portal-data-visualizations.git

```

**Install the required R packages**

```r
install.packages(c(
  "shiny", 
  "plotly", 
  "writexl", 
  "shinycssloaders", 
  "RColorBrewer", 
  "shinyjs", 
  "DT", 
  "shinyBS", 
  "bslib", 
  "shinyjqui", 
  "ggplot2",
  "yaml",
  "tidyr"
))
```

### Version details
The application is made using R version [4.4.2](https://cran.r-project.org/bin/windows/base/) (Pile of Leaves) and the following R packages are integrated into DepMap Visualiser and/or have been used in the development:

| Package Name        | Description                                                 | Version   |
|---------------------|-------------------------------------------------------------|-----------|
| [Shiny](https://github.com/rstudio/shiny) | Package that allows creating interactive R applications |1.9.1|
| [plotly](https://github.com/plotly/plotly.R)| Package that allows creating interactive graphs |4.10.4|
| [writexl](https://github.com/ropensci/writexl) | For converting dataframe to excel (.xslx)-format |1.5.1|
| [shinycssloaders](https://github.com/daattali/shinycssloaders)| Used for adding loading icons in application |1.1.0|
| [RColorBrewer](https://github.com/cran/RColorBrewer)| Used for adding color palettes to heat map  |1.1.3|
| [DT](https://github.com/rstudio/DT)| Used for interactive datatable output in application |0.33|
| [bslib](https://github.com/rstudio/bslib/) | Used for layout/structuring of application  |0.8.0|
| [shinyjqui](https://github.com/Yang-Tang/shinyjqui)| Used for making plots resizable |0.4.1|
| [ggplot2](https://github.com/tidyverse/ggplot2)| Used for making all plots (bar plot, boxplot, violin plot, heatmap)|3.5.1|
| [naniar](https://github.com/njtierney/naniar)| Used for visualising missing data in EDA|1.1.0|
| [tidyr](https://github.com/tidyverse/tidyr)| Used for making raw data tidy (horizontal -> vertical), in the data pre-processing|1.3.1|



### Pre-processing

Before the datasets can be used in the application, a little pre-processing will have to take place. First, open `config.yaml` and change the paths for expression_csv and model_csv to the paths where the datasets have been saved on your computer. Next choose where you want the resulting R data objects to be saved on your pc. This will be the same path that is used for retrieving the data again for the app, so make sure to not move the data afterwards, or change the path accordingly!

Next, run the R-script `pre-processing_data.R` (note: this step can take up to a few minutes, this is caused by the size of the dataset. This step will only have to be performed **once**):

```r
source("path/to/pre-processing_data.R")
```

### Launch the app

Now that the R data objects are created, the app itself can be run as following:

```r
library(shiny)
runApp('app')
```

## Usage
### Select Parameters
Use the sidebar to select the wanted genes, cancer types and additional demographic filters, including patient sex, race and age category.

- **Genes**: include a total of 19194 humane genes
- **Cancer types** (OncotreePrimaryDisease): contains a plethora of different cancer diseases of which the cell lines were extracted 
- **Sex**: biological sex the patient was born with, contains 3 options, 'Female', 'Male' and 'unknown' (due to some missing values). 'Male' and 'Female' are selected by default.
- **Race**: patient race, contains the following options: 'caucasian', 'asian', 'black_or_african_american', 'african', 'american_indian_or_native_american', 'east_indian', 'north_african' and unknown (due to some missing values)
- **Age category**: age category of patient, contains 4 options: 'Fetus', 'Pediatric', 'Adult' and unknown (due to some missing values)

![](media/select_parameters.PNG)

After selecting the parameters, the side bar can be collapsed to allow more space for the visualisation and datatable.


## Generate Visualizations

![](media/generate_visualisations.PNG)

1. Select type of plot to generate in the tabs menu (options: barplot, boxplot/violinplot and heatmap)
2. View the visualization in full screen by pressing the 'expand' button in the bottom right of the tab
3. Further options can be selected, in the sidebar on the left, options differ per plot type
4. The visualization can be resized by hovering over the edges of the plot and dragging the mouse
5. The visualization can be saved by pressing the 'save as .png' button

![](media/resize_plot.PNG)


## Explore data
View the data that is generated for the selected parameters, in the table on the right side. The datatable can be viewed in full screen by pressing the 'expand' button in the bottom right of the tab. What columns will be displayed can be chosen in the column selector at the top. The data can be sorted on columns from low/high, or you can perform do a specific search using the search bar in the top right.

### Saving the data
Using the download buttons, the data can be saved as either a comma-seperated-value (.csv) file, or an excel file (.xslx)

# Examples of visualisations
Bar Plot

Boxplot/violinplot

Heatmap
![](media/example_heatmap.png)

## Support
In case of any bugs or needed support, open up an issue at [my repo](https://github.com/YamilaTimmer/depmap-portal-data-visualizations/issues).

## License
This project is licensed under the MIT License. See the [LICENSE file](https://github.com/YamilaTimmer/depmap-portal-data-visualizations/blob/main/LICENSE) for details.

