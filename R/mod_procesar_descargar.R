#' procesar_descargar UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import DT dplyr dbplyr

mod_procesar_descargar_ui <- function(id){
  ns <- NS(id)
  tagList(
    h4("Formato de tiempo en 24 hrs."),
    fluidRow(
    column(width = 3, class = "shadowBox",
      dateInput(ns("fecha_webinar"), "Fecha del Webinar:", language = "es", weekstart = 1)
    ),
    column(width = 3, class = "shadowBox",
      textInput(ns("hora_inicio"), "Hora de inicio del webinar:", value = "00:00 (formato 24 hrs)")
          ),
    column(width = 3, class = "shadowBox",
      numericInput(ns("skip_df"), "Cortar headers desde:", 10, min = 1, max = 100)
    ),
    column(width = 3, class = "shadowBox", 
      fileInput(ns('reporte_zoom'), 'Suba el reporte de zoom',
      accept = c('text/csv', 'text/comma-separated-values','.csv'))
    ),
    fluidRow(
      column(width = 12, class = "shadowBox",
        br()
    ),
      column(width = 12, class = "shadowBox",
        hr()
      ),
    
    column(width = 3, class = "shadowBox",
           textInput(ns("historia_previa"), "Termino de historia previa:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("secreto_1"), "Termino del primer secreto:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("secreto_2"), "Termino del segundo secreto:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("secreto_3"), "Termino del tercer secreto:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("oferta"), "Termino de oferta:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("preguntas"), "Termino de preguntas:", value = "00:00 (formato 24 hrs)")
    )
   )),
    fluidRow(
      column(10, offset = 1,
             actionButton(inputId = ns("guardar"),label = "Guardar y procesar")
      )
    ),
    tags$hr(),
    selectInput(ns("filtro_2"), label = "Seleccione...",
                choices = c("Sí asistió", "No asistió"),
    ),
    fluidRow(
      column(width = 12, class = "shadowBox",
        DT::dataTableOutput(ns("Table"))
    )),
    tags$hr(),
   fluidRow(
     column(width = 12, class = "shadowBox",
     downloadButton(ns('download'),"Descargar datos")),
    )
  )
}
    
#' procesar_descargar Server Function
#'
#' @noRd 
mod_procesar_descargar_server <- function(input, output, session, BD){
  ns <- session$ns
  
  Si_Asistieron <- reactiveVal(NULL)
  No_Asistieron <- reactiveVal(NULL)
  horas_w <- reactiveVal(NULL)

  df_reporte_zoom <- reactive({
    req(input$reporte_zoom)
    
    inFile <- input$reporte_zoom
    
    if (is.null(inFile))
      return(NULL)
    
    df <- read.csv(inFile$datapath, header = T,
            row.names = NULL, skip = input$skip_df) %>% 
            tibble::as_tibble()
    
    colnames(df) <- colnames(df)[2:ncol(df)]     
    df <- df[ , - ncol(df)] 
    num <- BD$zum %>% select(num_webinar) %>% as.vector() %>% max()
    #browser()
    
    df <- df %>%   
    #filter(!Nombre.de.fuente %in% c('AMIGOS', 'Amigos'),
    #       !Nombre %in% c('TEAM EMILIO', 'TEAM', 'test')) %>% 
    mutate(num_webinar = num + 1, fecha = lubridate::as_date(input$fecha_webinar),
           hora_registro = lubridate::floor_date(lubridate::mdy_hms(Hora.de.registro), unit = "minute"),
           hora_entrada = lubridate::floor_date(lubridate::mdy_hms(Puesto.de.trabajo), unit = "minute"),
           hora_salida =  lubridate::floor_date(lubridate::mdy_hms(Hora.de.salida), unit = "minute")) %>%
    select( num_webinar, fecha, Asistio = Asistió, Nombre, Apellido, telefono = Teléfono,
    correo = Correo.electrónico, usuario = Nombre.de.usuario..nombre.original. ,
    hora_registro, hora_entrada, hora_salida)
    
    return(df)
  })
  
  observeEvent(input$guardar, {
    shinyjs::disable("guardar")
    horas_w(
      tibble::tibble(
        num_webinar = df_reporte_zoom() %>% select(num_webinar) %>% as.vector() %>% max(),
        historia_previa = paste(input$historia_previa, "00", sep = ":"),  
        tres_secretos = paste(input$tres_secretos, "00", sep = ":"),
        secreto_1 = paste(input$secreto_1, "00", sep = ":"),
        secreto_2 = paste(input$secreto_2, "00", sep = ":"),
        secreto_3 = paste(input$secreto_3, "00", sep = ":"),
        oferta = paste(input$oferta, "00", sep = ":"),
        preguntas = paste(input$preguntas, "00", sep = ":"),
        hora_webinar = paste(input$fecha_webinar, 
                       paste(input$hora_inicio, "00", sep = ":"), sep = "") %>%
                       lubridate::ymd_hms()
      ))
    
    Si_Asistieron(
      df_reporte_zoom() %>% procesar_segmentacion(horas = horas_w(), hora_inicio = input$hora_inicio) 
      )

    No_Asistieron(
      procesar_no_asistio(base_historico = BD$zum, bd = df_reporte_zoom())
      )
  
    horas_webinar_bd <- dplyr::bind_rows(horas_webinar_bd, horas_w())
    usethis::use_data(horas_webinar_bd, overwrite = TRUE)
    
    reporte_zoom_webinar_bd <- dplyr::bind_rows(reporte_zoom_webinar_bd, df_reporte_zoom())
    usethis::use_data(reporte_zoom_webinar_bd, overwrite = TRUE)
  
    })
  
  
  datasetInput <- reactive({
  if(input$filtro_2 == "Sí asistió"){
    Si_Asistieron()
    }else{
    No_Asistieron()
    }
  })
  
  output$Table <- DT::renderDataTable(datasetInput())
  
  
  # Downloadable csv of selected dataset ----
  output$download <- downloadHandler(
    filename = function() {
      paste("Categorizacion", input$filtro_2, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetInput(), file, row.names = FALSE)
    }
  )
  
}
    
## To be copied in the UI
# mod_procesar_descargar_ui("procesar_descargar_ui_1")
    
## To be copied in the server
# callModule(mod_procesar_descargar_server, "procesar_descargar_ui_1")
 
