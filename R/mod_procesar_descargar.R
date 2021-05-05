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
    column(width = 6, class = "shadowBox", 
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
           textInput(ns("tres_secretos"), "Termino de tres secretos:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("oferta"), "Termino de oferta:", value = "00:00 (formato 24 hrs)")
    ),
    column(width = 3, class = "shadowBox",
           textInput(ns("preguntas"), "Termino de ronda de preguntas:", value = "00:00 (formato 24 hrs)")
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
mod_procesar_descargar_server <- function(input, output, session, bd = bd){
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
            row.names = NULL, skip = 11) %>% 
            tibble::as_tibble()
    
    colnames(df) <- colnames(df)[2:ncol(df)]     
    df <- df[ , - ncol(df)] 
    num <- bd$zum %>% select(num_webinar) %>% as.vector() %>% max()
    
    df <- df %>%   
    filter(!Nombre.de.fuente %in% c('AMIGOS', 'Amigos'),
           !Nombre %in% c('TEAM EMILIO', 'TEAM', 'test')) %>% 
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
    # shinyjs::disable("guardar")

    horas_w(
      tibble::tibble(
        num_webinar = df_reporte_zoom() %>% select(num_webinar) %>% as.vector() %>% max(),
        historia_previa = paste(input$historia_previa, "00", sep = ":"),  
        tres_secretos = paste(input$tres_secretos, "00", sep = ":"),
        oferta = paste(input$oferta, "00", sep = ":"),
        preguntas = paste(input$preguntas, "00", sep = ":"),
        hora_webinar = paste(input$fecha_webinar, 
                       paste(input$hora_inicio, "00", sep = ":"), sep = "") %>%
                       lubridate::ymd_hms()
      ))
    
    # DBI::dbWriteTable(pool, bd_horas_webinar, horas_w(), append = T)(
    
  
    # DBI::dbWriteTable(pool, bd_reporte_zoom, df_reporte_zoom(), append = T)
    Si_Asistieron(
      df_reporte_zoom() %>% procesar_segmentacion(horas = horas_w(), hora_inicio = input$hora_inicio) 
      )
    
    #print(Si_Asistieron())
    
    No_Asistieron(
      procesar_no_asistio(base_historico = bd$zum, bd = df_reporte_zoom())
      )
    #print(No_Asistieron())
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
 
