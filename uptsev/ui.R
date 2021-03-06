#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(rves)
library(DT)
#
dbHeader <- dashboardHeader(title = "UPTSE-V",
                            tags$li(a(href = 'http://www.uptc.edu.co',
                                      icon("power-off"),
                                      title = "Back to Apps Home"),
                                    class = "dropdown"),
                            tags$li(a(href = 'http://www.uptc.edu.co',
                                      img(src = 'uptc_jpg.jpg',
                                          title = "Company Home", height = "30px"),
                                      style = "padding-top:10px; padding-bottom:10px;"),
                                    class = "dropdown"))



#
dbSidebar <- dashboardSidebar(
  # DEFINE SIDEBAR ITEMS
  #uiOutput("selectModelName"),
  #uiOutput("resettableFileInput"),
  #uiOutput("selectSlotName"),
  sidebarMenu(
    menuItem("Home", tabName = "home", icon = icon("home")),
    menuItem("Data", tabName = "data", icon = icon("table")),
    menuItem("Filter Data", tabName = "filter", icon = icon("filter")),
    menuItem("Transform Data", tabName = "transformation", icon = icon("key")),
    menuItem("Graphical Inversion", tabName = "manual", icon = icon("hand-spock-o")),
    menuItem("Automatic Inversion", tabName = "automatic", icon = icon("fighter-jet")),
    menuItem("Automatic Stepwise Inversion", tabName = "automaticSeq",
             icon = icon("space-shuttle")),
    menuItem("Model Diagnostic", tabName = "diagnostic", icon = icon("wrench")),
    menuItem("Reports", tabName = "reports", icon = icon("cogs")),
    menuItem("Source Code", icon = icon("code"), href = "https://github.com/khaors/rves")
  )
)
#########################################################################################
#                                    homeTab
#########################################################################################
homeTab <- tabItem(
  tabName = "home",
  h1("UPTSE-V: Vertical Electrical Sounding Analyst"),
  fluidRow(
    tags$em(
      "Copyright (c) 2017 Oscar Garcia-Cabrejo <khaors@gmail.com>",
      br(),
      br(),
        "Permission to use, copy, modify, and distribute this software for any
      purpose with or without fee is hereby granted, provided that the above
      copyright notice and this permission notice appear in all copies.",
      br(),
      br(),
      'THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES',
      "WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF",
      "MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR",
      "ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES",
      "WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN",
      "ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF",
      "OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE."
    ),
    br(),br(),
    box(
      h2("Information"),
      "This interface allows users to load, plot and analyze VES acquired using Schlumberger arrays.",
      "This tool is primarily meant to support the teaching of Hydrogeology at School of Geological ",
      "Engineering, UPTC - Sogamoso, Boyaca, Colombia. Although the main target is only for educational",
      "purposes, this tool can be used by other users to analyze their VES but the accuracy ",
      "and the geological interpretation derived from these results are not warranted.",
      "Therefore its use for other purposes beyond education is discouraged.",
      br(),br(),
      "The dashboard uses the following R libraries below and is being developed in RStudio using ",
      " the packages ", tags$a(href="http://shiny.rstudio.com/", "shiny"),
      " and ",
      tags$a(href="https://rstudio.github.io/shinydashboard", "shinydashboard"),
      ". ",
      br(),br(),
      "The source code is available on ",
      tags$a(href="https://github.com/khaors/rves", "GitHub. "),
      "Contact the developer, Oscar Garcia-Cabrejo, via e-mail at khaors@gmail.com for
      questions or feedback."
    ),
    box(
      h2("Instructions"),
      "1. Load the results of the VES using the Data Tab on the right.",
      br(),br(),
      "2. If required, use the Filter Tab to remove noise in the apparent resistivity measurements ",
      "using different methodologies including smoothing spline, kernel polynomial regression, ",
      "and wavelet thresholding.",
      br(), br(),
      "3. Use the Transformation Tab to apply different resistivity-depth transformation to your ",
      "resistivity measurements. These transformation approaches can be conceived as heuristic ",
      "inversion methodologies and can be used in cases when a more realisitic initial solution is ",
      "needed for the automatic inversion routines or a fast multilayer model is required.",
      br(),br(),
      "4. Use the Graphical Inversion Tab to define a model using your 'Geophysical Skill'.",
      br(),br(),
      "5. Use the Automatic Inversion Tab to estimate the real resistivities and thicknesses using ",
      "different optimization techniques. The convential approach is based on linear inverse theory ",
      "and is called Nonlinear Least-Squares method. There are other methods to find the resitivities and ",
      "thicknesses based on optimization theory. These methods include Simulated Annealing, Genetic ",
      "Algorithms, Particle Swarm Optimization, Differential Evoluation, among others",
      br(),br(),
      "6. Evaluate the estimated model on the Model Diagnostic Tab and be more confident about the ",
      "estimated parameters."
    )
  )
)
#########################################################################################
#                                    dataTab
#########################################################################################
dataTab <- tabItem(
  tabName = "data",
  h2("Import VES Data"),
  br(),
  br(),
  fluidRow(
    tags$em("This tab is to import data. VES data must be in a text file and you can use
            all the options below to make sure that you can import your data.")
  ),
  br(),
  br(),
  checkboxInput('header', ' Header?', TRUE),
  checkboxInput('rownames', ' Row names?', FALSE),
  selectInput('sep', 'Separator:',
              c("Comma","Semicolon","Tab","Space"), 'Comma'),
  selectInput('quote', 'Quote:',
              c("None","Double Quote","Single Quote"),
              'Double Quote'),
  selectInput('dec', 'Decimal mark', c("Period", "Comma"),
              'Period'),
  numericInput('nrow.preview','Number of rows in the preview:',20),
  numericInput('ncol.preview', 'Number of columns in the preview:',
               10),
  fileInput('file1', 'Choose CSV/TXT File'),
  helpText("Note: Even if the preview only shows a restricted
                          number of observations, the VES object will be created
                          based on the full dataset."),
  tableOutput("view"),
  br()
  #downloadLink('downloadDump', 'Download source'),
  #br(),
  #downloadLink('downloadSave', 'Download binary')
)
#########################################################################################
#                                    Filter Tab
#########################################################################################
filterTab <- tabItem(
  tabName = "filter",
  h3("VES Filtering"),
  br(),
  fluidRow(
    tags$em("On this tab you can apply different smoothing techniques to the measured
            resitivity data.")
  ),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "filterMethod", label = "Filter Method ",
                  choices = c("None", "smooth.spline", "kernel.regression", "wavelet"),
                  selected = "None"),
      br(),
      conditionalPanel(
        condition = "input.filterMethod == 'kernel.regression'",
        textInput(inputId = "kernel_bw", label = "Bandwidth ", value = "0.1")
      ),
      br(),
      checkboxInput(inputId = "filter_show", label = "Show Results", value = FALSE),
      br(),
      actionButton(inputId = "filterRun", label = "Apply Filter", icon = icon("bullseye")),
      br(),
      br(),
      actionButton(inputId = "filterRestore", label = "Restore Original VES",
                   icon = icon("fast-backward"))
    ),
    mainPanel(
      plotOutput(outputId = "filterResultsPlot"),
      br(),
      dataTableOutput(outputId = "filterResultsTable")
    )
  )
)
#########################################################################################
#                                    Transformation Tab
#########################################################################################
transformationTab <- tabItem(
  tabName = "transformation",
  h3("Resistivity-Depth Transformation"),
  br(),
  fluidRow(
    tags$em("On this tab you can transform your apparent resistivity data measured at a
            given spacing into real resistivities at given depths. On the surface this
            seems like the inversion procedure but in this case this is a heuristic
            inversion. This means that this inversion is not based on optimization but
            instead this is calculated using ad-hoc rules. Once the trransformation is
            calculated, the results can be used as an initial model of an optimization-based
            inversion or just as exploratory tool to understand the variation of the resistivity
            with depth.")
  ),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      width = 4,
      selectInput(inputId = "transformation.type",
                  label = "Select the Transformation Type",
                  choices = c("None", "Direct", "Scaling", "Zohdy", "Smoothed.Zohdy"),
                  selected = "None"),
      br(),
      checkboxInput(inputId = "transform_results_plot", label = "Show Results", value = FALSE),
      br(),
      checkboxInput(inputId = "transform_sample_plot", label = "Sample Results 1 m", value = FALSE),
      br(),
      actionButton(inputId = "transformationRun", label = "Apply Transformation", icon = icon("bullseye"))
    ),
    mainPanel(
      # Add Plot
      plotOutput(outputId = "transformationPlot"),
      br(),
      dataTableOutput("transform_results"),
      br(),
      dataTableOutput(outputId = "transformSampleTable")

    )
  )
)
#########################################################################################
#                                    Graphical Inversion Tab
#########################################################################################
manualTab <- tabItem(
  tabName = "manual",
  h3("VES Inversion: Graphical Method"),
  br(),
  fluidRow(
    tags$em("On this tab you can specify an Earth model (real resisivities and thicknesses),
            calculate the apparent resisivities of this model, and compare them with the
            apparent resistivities measured on the field. The goal is to perform an inversion
            by hand/eye to help the students to get familiar with the interpretation of VES.
            Some fitness measures of the specified model are presented below the plot.")
  ),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      textInput(inputId = "manual_nlayers", label = "Number Layers", value = 1),
      textInput(inputId = "manual_res", label = "Real Resistivities", value = 10),
      textInput(inputId = "manual_thick", label = "Thicknesses", value = 10),
      uiOutput("manual_run")
    ),
    mainPanel(
      plotOutput(outputId="manual_plot"),
      br(),
      uiOutput("manual_results")
    )
  )
)
#########################################################################################
#                                    Automatic Inversion Tab
#########################################################################################
automaticTab <- tabItem(
  tabName = "automatic",
  h3("VES Inversion: Automatic Method"),
  br(),
  br(),
  fluidRow(
    tags$em("On this tab you can specify an initial Earth model (real resisivities and thicknesses),
             and using different optimization techniques an Earth model with minimum error is found.
            Some fitness measures of the estimated model are presented below the plot.")
  ),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      actionButton(inputId = "automatic_import", label = "Import Graphical Model"),
      br(),
      br(),
      selectInput(inputId = "automatic_method", label = "Optimization Method: ",
                  choices = c("None", "Nonlinear Least Squares",
                              "L-BFGS-B",
                              "Simulated Annealing",
                              "Genetic Algorithms",
                              "Particle Swarm Optimization",
                              "Differential Evolution"),
                  selected = "None"),
      checkboxInput(inputId = "automatic_options1", label = "Specify Optimization Options?", value = FALSE),
      uiOutput("automatic_options2"),
      br(),
      textInput(inputId = "automatic_nlayers", label = "Number Layers", value = "1"),
      textInput(inputId = "automatic_res", label = "Initial Solution: Real Resistivities", value = "10"),
      textInput(inputId = "automatic_thick", label = "Initial Solution: Thicknesses", value = "10"),
      actionButton(inputId = "automatic_plot", label = "Plot"),
      actionButton(inputId="auto_run",label= "run, SEV run", icon = icon("bullseye"))
    ),
    mainPanel(
      plotOutput(outputId = "automatic_plot"),
      br(),
      uiOutput(outputId = 'automatic_results'),
      br(),
      dataTableOutput(outputId = "automatic_table")
    )
  )
)
#########################################################################################
#                                    AutomaticSequentialTab
#########################################################################################
automaticSeqTab <- tabItem(
  tabName = "automaticSeq",
  h3("VES Inversion: Automatic Stepwise Method"),
  br(),
  br(),
  fluidRow(
    tags$em("On this tab you can estimate the Earth model (real resisivities and thicknesses),
             whithout specifying an initial model, using different optimization techniques an
             Earth model with minimum error is found.
            Some fitness measures of the estimated model are presented below the plot.")
  ),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "seqOptMethod", label = "Optimization Method",
                  choices = c("None","NLS", "SA", "GA", "DE", "PSO"),
                  selected = "None"),
      br(),
      textInput(inputId = "seqIterations", label = "Maximum Number of Iterations", value = "10"),
      br(),
      textInput(inputId = "seqReport", label = "Report Iterations", value = "2"),
      br(),
      textInput(inputId = "seqMaxlayers", label = "Maximum Number of Layers", value = "10"),
      br(),
      conditionalPanel(
        condition = "input.seqOptMethod != 'None' & input.seqOptMethod !='NLS' ",
        textInput(inputId = "seqLowerLim", label = "Resistivity,Thickness Lower limit",
                  value = "1.0,1.0"),
        textInput(inputId = "seqUpperLim", label = "Resistivity,Thickness Upper limit",
                  value = "1000.0,100.0")
      ),
      actionButton(inputId = "seq_plot", label = "Plot"),
      actionButton(inputId = "seqRun", label = "Run (a lot) VES Run (a lot)",
                   icon = icon("bicycle"))
    ),
    mainPanel(
      plotOutput(outputId = "seq_plot"),
      br(),
      uiOutput(outputId = 'seq_results'),
      br(),
      dataTableOutput(outputId = "seq_table")
    )
  )
)
#########################################################################################
#                                    diagnosticTab
#########################################################################################
diagnosticTab <- tabItem(
  tabName = "diagnostic",
  h3("VES Inversion: Estimated Model Diagnostic"),
  br(),
  fluidRow(
    tags$em("On this tab you can check if the assumptions behind the estimation procedure
            hold or are violated. If these assumption hold then there is a greater confidence
            in the model results, otherwise the estimated parameters (real resistivities and
            thicknesses) must be used with care.")
  ),
  br(),
  sidebarLayout(
    sidebarPanel(
      width = 4,
      selectInput(inputId = "diagnostic.type", label = "Select the Diagnostic Type",
                  choices = c("None", "Model Diagnostic"), selected = "None")
    ),
    mainPanel(
      # Add Plot
      plotOutput(outputId = "model_diagnostic") #, height = 500, width = 500*1.5)
    )
  )
)

#########################################################################################
#                                    reportsTab
#########################################################################################
reportsTab <- tabItem(
  tabName = "reports",
  h2("Reports"),
  br(),
  "This tab allows the automatic generation and download of some preconfigured reports with
  tables and graphs in English and Spanish.",
  br(),
  br(),br(),
  fluidRow(
    box(
      downloadButton(outputId = "report.html.eng", label = "Generate report: html - English"),
      br(),
      downloadButton(outputId = "report.word.eng", label = "Generate report: word - English"),
      br(),
      downloadButton(outputId = "report.html.spa", label = "Generate report: html - Spanish"),
      br(),
      downloadButton(outputId = "report.word.spa", label = "Generate report: word - Spanish")
    )
  ),
  br()
)
#
userInterface <- dashboardPage(
  skin = "blue",
  # DASHBOARD HEADER
  dbHeader,
  # DASHBOARD SIDEBAR
  dbSidebar,
  # DASHBOARD BODY
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "rdfTool.css")),
    tabItems(
      homeTab ,
      dataTab,
      filterTab,
      transformationTab,
      manualTab,
      automaticTab,
      automaticSeqTab,
      diagnosticTab,
      reportsTab
    )
  )
)
