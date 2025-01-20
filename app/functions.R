library(yaml) # read config paths
library(shiny) # creating interactive app
library(plotly) # make plots interactive
library(writexl) # export to .xslx
library(shinycssloaders) # loading icon
library(RColorBrewer) # color palettes
library(DT) # make datatables
library(bslib) # used for layout/structuring of app
library(shinyjqui) # make plots resizable
library(ggplot2) # make plots
library(bsicons) # for clickable github icon

# Read paths to load saved R objects from pre-processing
config <- yaml::read_yaml("../config/config.yaml")

load(config$expression_rdata)
load(config$model_rdata)


#' Generate bar plot
#'
#' This function generates a bar plot using the merged data (tidy_expression + model)
#'
#' The generated bar plot shows the expression levels on the x-axis and the cell line name
#' on the y-axis.
#' 
#' @param data merged dataframe of tidy_expression and model
#' @param fill a column of the merged dataframe, depending on the filter options chosen by user
#' @return a ggplot2 bar plot object
#' @examples
#' generate_barplot(merged, merged$AgeCategory)

generate_barplot <- function(data, y, fill, fill_label){
    
    ggplot(data = data, 
           aes(x = expression,
               y = y,
               fill = fill)) +
        geom_bar(stat = "identity") + 
        ylab("Tumor Cell Line") +
        xlab("Expression level (log2 TPM)") +
        labs(fill = fill_label) +
        theme_minimal()
}


#' Generate box plot
#'
#' This function generates a box plot using the merged data (tidy_expression + model)
#'
#' The generated box plot shows the gene name on the x-axis and the expression levels
#' on the y-axis. This function is also used to generate violin plots (geom_violin()), because of the
#' similarity in parameters for boxplot/violin plot.
#' 
#' @param data merged dataframe of tidy_expression and model
#' @param parameter column from merged that serves as x-axis parameter
#' @param text_angle int that sets rotation for x-axis labels
#' @param xlab string that is displayed as x-axis lable
#' @return a ggplot2 box plot object
#' @examples
#' generate_box_plot(merged, parameter, text_angle, xlab) + geom_boxplot()

generate_box_plot <- function(data, parameter, text_angle, xlab, fill_label, 
                              boxplot_violinplot, individual_points_checkbox, 
                              merge_genes_checkbox){
    
    plot <- ggplot(data = data,
                   aes(x = parameter, 
                       y = expression,
                       fill = parameter)) +
        labs(x = xlab, 
             y = "Expression level(log2 TPM)") + 
        labs(fill = fill_label) +
        theme_minimal() + 
        theme(axis.text.x = element_text(angle = text_angle)) # Rotate gene names x-axis
    
    # If-statement for the two checkboxes, one where the user selects boxplot 
    # or violinplot and one where the user selects to (not) show individual points in the plot
    if (boxplot_violinplot == "Boxplot") {
        
        plot <- plot + geom_boxplot()
        
    }
    
    else {
        
        plot <- plot + geom_violin()
    }
    
    
    if (individual_points_checkbox == TRUE) {
        
        plot <- plot + geom_point()
    }
    
    else {
        plot
    }
    
    if (merge_genes_checkbox == FALSE) {
        plot + facet_wrap(~ gene)
    }
    
    else {
        
        plot
    }
    
}


#' Generate heat map
#'
#' This function generates a heat map using the merged data (tidy_expression + model)
#' 
#' The generated heat map shows the gene name on the x-axis, the cell line name on the
#' y-axis and shows the expression levels with colour (fill).
#' 
#' @param data merged dataframe of tidy_expression and model
#' @param text_angle int that determines rotation of x-axis labels
#' @param palette string that determines color palette of heatmap
#' @return a ggplot2 heat map object
#' @examples
#' generate_heatmap(merged, -90, "Blues")

generate_heatmap <- function(data, text_angle, palette){
    
    ggplot(data = data, 
           aes(x = gene, 
               y = StrippedCellLineName, 
               fill = expression)) +
        geom_tile() + 
        ylab("Tumor Cell Line") +
        xlab("Gene") +
        labs(fill = "Expression level (log2 TPM)") +
        theme_minimal() + 
        theme(axis.text.x = element_text(angle = text_angle)) +
        scale_fill_distiller(palette = palette)
}


#' Create hyperlink
#'
#' This function generates a hyperlink for genes, displayed in filtered_table.
#' The gene name is shown as the display text and by clicking it, it will bring the
#' user to a webpage containing more information about that gene.
#' 
#' 
#' @param gene column from merged dataframe
#' @return a hyperlink corresponding to the gene
#' @examples
#' create_link(gene)
create_link <- function(gene) {
    paste0("<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=", gene, 
           "' target='_blank'>", gene, "</a>") # target = '_blank' has to be added, 
    #to prevent the app from refreshing when a hyperlink is clicked.
}
