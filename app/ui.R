source("functions.R")

ui <- page_fillable(
    
    page_navbar(
        
        title = "DepMap Visualiser", sidebar = sidebar(width = 350,
                                                       
                                                       
                                                       h4("Select parameters:"),
                                                       
                                                       # Input dropdown menus for all list variables
                                                       
                                                       accordion(  
                                                           accordion_panel("Select gene",
                                                                           selectizeInput('gene_name', 
                                                                                          label = NULL, 
                                                                                          choices = NULL, 
                                                                                          multiple = TRUE
                                                                           )),
                                                           
                                                           accordion_panel("Select cancer type",
                                                                           selectizeInput("onco_type", 
                                                                                          label = NULL, 
                                                                                          choices = NULL, 
                                                                                          multiple = TRUE
                                                                           )),
                                                           accordion_panel("Select other metadata",
                                                                           selectizeInput("sex", 
                                                                                          label = "Select sex", 
                                                                                          choices = NULL, 
                                                                                          multiple = TRUE),
                                                                           
                                                                           selectizeInput("race", 
                                                                                          label = "Select race", 
                                                                                          choices = NULL,
                                                                                          multiple = TRUE),
                                                                           
                                                                           selectizeInput("age_category", 
                                                                                          label = "Select age category", 
                                                                                          choices = NULL, 
                                                                                          multiple = TRUE),
                                                                           
                                                                           #actionButton("submit_button", label = "Apply settings")
                                                           )))
        ,
        
        
        # Output for generated plot(s)
        layout_columns(
            card(full_screen = TRUE, 
                 navset_card_tab(
                     
                     # Tab for barplot
                     nav_panel("Bar plot", 
                               layout_sidebar(
                                   sidebar = sidebar(
                                       
                                       accordion(  
                                           accordion_panel("Choose x-axis parameter",
                                                           radioButtons("barplot_x_axis_parameter", 
                                                                        label = NULL, 
                                                                        choices = c("Gene", "Cell line"), 
                                                                        selected = "Gene"
                                                           )
                                           ),
                                           accordion_panel("Choose parameter to visualise",
                                                           radioButtons("barplot_parameter", 
                                                                        label = NULL,
                                                                        choices = c("Sex", "Age Category", "Race", "Cancer Type"), 
                                                                        selected = "Sex"
                                                           )
                                           ),
                                           
                                           #submitButton(text = "Apply settings")
                                       )
                                   ),
                                   
                                   # Output: resizable, interactive ggplot barplot (with loading icon)
                                   shinycssloaders::withSpinner(jqui_resizable(plotlyOutput("barplot_per_gene")))
                               )
                     ),
                     
                     
                     # Tab for boxplot/violin plot
                     nav_panel("Boxplot/Violin plot", 
                               layout_sidebar(
                                   sidebar = sidebar(
                                       
                                       accordion(  
                                           accordion_panel("Choose parameter to visualise",
                                                           radioButtons("boxplot_parameter", 
                                                                        label = NULL,
                                                                        choices = c("Sex", "Age Category", "Race", "Cancer Type"), 
                                                                        selected = "Sex"
                                                           )
                                           ),
                                           
                                           
                                           accordion_panel("Display as boxplot or violin plot?",
                                                           radioButtons("boxplot_violinplot", 
                                                                        label = NULL,
                                                                        choices = c("Boxplot", "Violin plot"), 
                                                                        selected = "Boxplot"
                                                           )
                                           ),
                                           
                                           checkboxInput("individual_points_checkbox", 
                                                         label = "Show individual points?", 
                                                         value = TRUE
                                           )
                                       )
                                   ),
                                   
                                   # Output: resizable, interactive ggplot boxplot/violinplot (with loading icon)
                                   shinycssloaders::withSpinner((jqui_resizable(plotlyOutput("boxplot_per_gene"))))
                               )
                     ),
                     
                     # Tab for heatmap
                     nav_panel("Heatmap", 
                               layout_sidebar(
                                   
                                   sidebar = sidebar(
                                       accordion(
                                           accordion_panel("Choose color palette",
                                                           radioButtons("palette", 
                                                                        label = NULL,
                                                                        choices = c("Purple-Green", "Red-Blue", "Blue", "Grayscale"), 
                                                                        selected = "Blue"
                                                           )
                                           )
                                       )
                                   ),
                                   
                                   # Output: resizable, interactive ggplot heatmap (with loading icon)
                                   shinycssloaders::withSpinner((jqui_resizable(plotlyOutput("heatmap_per_gene"))))
                               ),
                     )
                 )
            ),
            
            card(full_screen = TRUE, 
                 navset_card_tab(
                     
                     # Tab for filtered data table
                     (nav_panel("Filtered Data",
                                
                                selectizeInput('table_columns', 
                                               label = "Select table columns to be displayed", 
                                               choices = NULL, 
                                               multiple = TRUE),
                                
                                # Download buttons merged data (.csv/.xslx)
                                downloadButton("download_csv", "Download .csv"),
                                downloadButton("download_excel", "Download .xlsx"),
                                
                                # Output: filtered datatable (with loading icon)
                                shinycssloaders::withSpinner(DT::DTOutput("filtered_table"))
                                
                                
                     )
                     ),
                     
                     (nav_panel("About the data",
                                "The data used in this application originates from the DepMap Portal which contains a lot of (expression)data on genes over different
                                cancer cell lines. 
                                https://depmap.org/portal/"
                     )
                     )
                     
                 )
            ),
            
            # Column width for card 1 (plot output) and card 2 (table output)
            col_widths = c(6, 6)),
        
        # Dark mode button, clicking switches between light/dark mode
        nav_item(input_dark_mode(id = "dark_mode", 
                                 mode = "light")
        ),
        
        # Adds github logo to navbar that links to repo
        nav_item(tags$a(
            href = "https://github.com/YamilaTimmer/depmap-portal-data-visualizations", 
            target = "_blank", 
            bsicons::bs_icon("github", size = "2rem")
        )
        )
        
    )
)

