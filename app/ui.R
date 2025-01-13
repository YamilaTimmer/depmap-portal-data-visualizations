source("functions.R")

ui <- page_fillable(
  
  page_navbar(
    
    title = "DepMap Visualiser", sidebar = sidebar(
      
      tags$style(HTML("

        .selectize-input, .bslib-sidebar {
          width: 280px; /* Adjust sidebar width */
        }
        
      ")),
      
      
      h4("Select parameters:"),
      # input dropdown menus for all list variables
      selectizeInput('gene_name', label = "Select gene of interest", 
                     choices = NULL, multiple = TRUE),
      selectizeInput('cell_line_name', label = "Select cell line of interest", 
                     choices = NULL, multiple = TRUE),
      selectizeInput("onco_type", label = "Select type of cancer", 
                     choices = NULL, multiple = TRUE),
      selectizeInput("sex", label = "Select sex", choices = NULL, 
                     multiple = TRUE),
      selectizeInput("race", label = "Select race", choices = NULL,
                     multiple = TRUE),
      selectizeInput("age_category", label = "Select age category", 
                     choices = NULL, multiple = TRUE),
      
      submitButton(text = "Apply settings")
    )
    ,
    
    
    # Output for generated plot(s)
    layout_columns(
      card(full_screen = TRUE, 
           navset_card_tab(
             nav_panel("Bar plot", 
                       layout_sidebar(
                         sidebar = sidebar(
                           radioButtons("barplot_x_axis_parameter", 
                                        label = "Choose x-axis parameter", 
                                        choices = c("Gene", "Cell line"), 
                                        selected = "Gene"),
                           radioButtons("barplot_parameter", 
                                        label = "Choose parameter to visualise",
                                        choices = c("Sex", "Age Category", "Race", "Cancer Type"), 
                                        selected = "Sex",
                           ),
                           submitButton(text = "Apply settings")
                         ),
                         shinycssloaders::withSpinner(jqui_resizable
                                                      (plotlyOutput("barplot_per_gene")))
                       )
             ),
             
             
             nav_panel("Boxplot/Violin plot", 
                       layout_sidebar(
                         sidebar = sidebar(
                           radioButtons("boxplot_parameter", 
                                        label = "Choose parameter to visualise",
                                        choices = c("Sex", "Age Category", "Race", "Cancer Type"), 
                                        selected = "Sex",
                           ),
                           checkboxInput("individual_points_checkbox", 
                                         label = "Show individual points?", 
                                         value = TRUE),
                           radioButtons("boxplot_violinplot", 
                                        label = "Display as boxplot or violin plot?",
                                        choices = c("Boxplot", "Violin plot"), 
                                        selected = "Boxplot",
                           ),
                           submitButton(text = "Apply settings")),
                         
                         shinycssloaders::withSpinner((jqui_resizable(plotlyOutput("boxplot_per_gene"))))
                       )
                       
             ),
             
             
             nav_panel("Heatmap", 
                       layout_sidebar(
                         
                         sidebar = sidebar(
                           radioButtons("palette", 
                                        label = "Choose color palette",
                                        choices = c("Purple-Green", "Red-Blue", "Blue", "Grayscale"), 
                                        selected = "Blue",
                           ),
                           submitButton(text = "Apply settings")),
                         shinycssloaders::withSpinner((jqui_resizable(plotlyOutput("heatmap_per_gene"))))
                       ),
             )
           )
      ),
      
      
      
      card(full_screen = TRUE, 
           navset_card_tab
           (nav_panel("Filtered Data",
                       selectizeInput('table_columns', label = "Select table columns to be displayed", 
                                      choices = NULL, multiple = TRUE),
                       submitButton(text = "Apply settings"),
                       shinycssloaders::withSpinner(DT::DTOutput("filtered_table")), 
                       downloadButton("download_csv", "Download .csv"),
                       downloadButton("download_excel", "Download .xlsx")
             ),
             
           )
      ),
      col_widths = c(6, 6)),
    
    nav_item(
      input_dark_mode(id = "dark_mode", mode = "light")
    )
  )
)

