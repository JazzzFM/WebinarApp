retencion_atencion <- function(bd, horas){
  n_w <- pull(bd, num_webinar) %>% unique
  
  # browser()
  Asist <- bd %>% 
    dplyr::filter(hora_salida - hora_entrada > 0) %>% 
    dplyr::mutate(correo = as.factor(correo)) %>% 
    dplyr::group_by(correo) %>%
    dplyr::mutate(fecha_max = max(hora_salida)) %>% ungroup() %>% 
    dplyr::mutate(correo = forcats::fct_reorder(correo, fecha_max)) %>% 
    dplyr::select(correo, fecha, hora_entrada, fecha_max, hora_salida)
  
  y_0 <- pull(Asist, correo) %>% unique %>% length
  
  fechaWeb <- pull(Asist, fecha) %>% unique
  fechaCompleta <- paste(fechaWeb, horas, sep = " ")
  horas <- lubridate::as_datetime(fechaCompleta)
  
  #browser()
  
  Graph <- Asist %>% ggplot() +
      geom_segment(
        aes(y = correo, yend = correo, x = hora_entrada, xend = hora_salida),
        lineend = 'round', linejoin = 'round',
        size = 1, arrow = arrow(length = unit(0.05, "inches")))+ 
      geom_vline(xintercept = horas, linetype = "dotted", color = "blue", size = 1.0) +
      annotate(x = horas[4] - (7*60), y = y_0 - 3, geom = "label", hjust = 0.5, label = "Historia previa") +
      annotate(x = horas[7] + (15*60), y = y_0 - 8, geom = "label", hjust = 0.5, label = "Fin Webinar") +
      labs(title = "Retención de la audiencia") +
      xlab("Tiempo de Webinar") +
      ylab("Correo de personas") +
      theme_minimal()
  
    if(n_w <= 7){
      Graph <- Graph +
      annotate(x = horas[5] - (30*60), y = y_0 - 3, geom = "label", hjust = 0.5, label = "3 Secretos") +
      annotate(x = horas[6] - (7*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Oferta") +
      annotate(x = horas[7] - (15*60), y = y_0 - 5, geom = "label", hjust = 0.5, label = "Ronda de preguntas") 
    }else if (n_w == 8){
      Graph <- Graph +
        annotate(x = horas[9] - (3.0*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Reto") +
        annotate(x = horas[9] + (6.0*60), y = y_0 - 3, geom = "label", hjust = 0.5,label = "Preguntas") +
        annotate(x = horas[10] - (6.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 1") +
        annotate(x = horas[11] - (6.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 2") +
        annotate(x = horas[12] - (5.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 3") 
    }else{
      Graph <- Graph +
        annotate(x = horas[6] - (3.0*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Oferta") +
        annotate(x = horas[7] - (6.0*60), y = y_0 - 3, geom = "label", hjust = 0.5,label = "Preguntas") +
        annotate(x = horas[10] - (6.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 1") +
        annotate(x = horas[11] - (6.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 2") +
        annotate(x = horas[12] - (5.5*60) , y = y_0 - 3, geom = "label", hjust = 0.5,label = "Secreto 3")  
    }
  
  return(Graph)
}

timel_pct_audiencia <- function(bd_1, bd_2, horas){
  n_w <- pull(bd_1, num_webinar) %>% unique

  bd <- bd_1 %>% 
    dplyr::group_by(correo) %>% 
    dplyr::mutate(
      fecha_ini = min(lubridate::ymd_hms(hora_entrada)),
      fecha_fin = max(lubridate::ymd_hms(hora_salida))
      )
  
  df <- bd %>%
    tidyr::complete(fecha_fin = seq( 
      from=as.POSIXct(min(fecha_ini), tz="UTC"),
      to=as.POSIXct(max(fecha_fin), tz="UTC"),
      by="1 min"), fill = list(fecha_fin = NA)) %>% 
    ungroup %>% 
    distinct(correo, fecha_fin) %>% 
    count(fecha_fin) %>% 
    dplyr::mutate(max = n == max(n)) %>% 
    dplyr::mutate(pct = n/max(n), abs = n, 
      color_pct = cut(pct,c(0,.25,.5,.75,.9,1), 
      c("(0%-25%]","(25%-50%]","(50%-75%]","(75%-90%]","(90%-100%]")))
  

  fechaWeb <- pull(bd, fecha) %>% unique
  fechaCompleta <- paste(fechaWeb, horas, sep = " ")
  horas <- lubridate::as_datetime(fechaCompleta)
  
  x <- bd_1 %>% pull(correo) %>% unique %>% length
  z <- bd_2 %>% pull(correo) %>% unique %>% length
  
  Graph <- df %>% ggplot(aes(x = fecha_fin, y = n, fill=color_pct, color=color_pct)) +
    geom_bar(stat = "identity") +
    geom_vline(xintercept = horas, linetype="dotted", color = "blue", size = 1.0) +
    annotate(x = horas[4] - (15*60), y = x-1, geom = "label", hjust = 0.5, label = "Historia previa") +
    annotate(x = horas[7] + (15*60),  y = x - 3, geom = "label", hjust = 0.5, label = "Fin Webinar") +
    annotate(x = min(df$fecha_fin)-2, y = x + 4, geom = "label", hjust = 0,
      label = glue::glue("Asistentes máximos: {max(df$n)} ({count(df,max) %>% filter(max) %>% pull(n)} mins)")) +
    annotate(x = min(df$fecha_fin)-2, y = x + 1, geom = "label", hjust = 0, label = glue::glue("Asistentes únicos: {x}")) +
    annotate(x = min(df$fecha_fin)-2, y = x-2, geom = "label", hjust = 0, label = glue::glue("Registros únicos: {z}")) +
    theme_minimal() 
  
  if(n_w <= 7){
    Graph <- Graph +
      annotate(x = horas[5] - (30*60), y = x-1, geom = "label", hjust = 0.5, label = "3 Secretos") +
      annotate(x = horas[6] - (7*60) , y = x-1, geom = "label", hjust = 0.5,label = "Oferta") +
      annotate(x = horas[7] - (15*60), y = x-1, geom = "label", hjust = 0.5, label = "Ronda de preguntas") 
  }else if(n_w == 8){
    Graph <- Graph +
      annotate(x = horas[9] - (3.0*60) , y = x-1, geom = "label", hjust = 0.5,label = "Reto") +
      annotate(x = horas[9] + (6.0*60), y = x-1, geom = "label", hjust = 0.5,label = "Preguntas") +
      annotate(x = horas[10] - (6.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 1") +
      annotate(x = horas[11] - (6.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 2") +
      annotate(x = horas[12] - (5.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 3") 
  }else{
    Graph <- Graph +
      annotate(x = horas[6] - (3.0*60) , y = x-1, geom = "label", hjust = 0.5,label = "Oferta") +
      annotate(x = horas[7] - (6.0*60), y = x-1, geom = "label", hjust = 0.5,label = "Preguntas") +
      annotate(x = horas[10] - (6.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 1") +
      annotate(x = horas[11] - (6.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 2") +
      annotate(x = horas[12] - (5.5*60) , y = x-1, geom = "label", hjust = 0.5,label = "Secreto 3") 
  }
  
  return(Graph)
}

porcentaje_asistencia_vs_no <- function(bd){
  hcoptslang <- getOption("highcharter.lang")
  hcoptslang$weekdays<- c("Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado")
  hcoptslang$shortMonths <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic")
  hcoptslang$months <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
  hcoptslang$thousandsSep <- c(",")
  options(highcharter.lang = hcoptslang)
  
  Registros <- bd %>%
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('Registrados' = n())
  
  MAXWEB <- bd %>%
    dplyr::filter(Asistio != 'No') %>% 
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('Sí asistieron' = n())
  
  NOWEB <- bd %>%
    dplyr::filter(Asistio == 'No') %>% 
    dplyr::group_by(correo, fecha) %>%
    dplyr::summarise('a' = n()) %>%
    dplyr::group_by(fecha) %>%
    dplyr::summarise('No asistieron' = n())
  
  historico <- dplyr::left_join(Registros, MAXWEB, by = "fecha") %>% dplyr::left_join(NOWEB, by = "fecha")
  longer_historico <- tidyr::pivot_longer(historico, Registrados:`No asistieron`, names_to = "categoria", values_to = "count")

 Graph <- longer_historico %>%
    filter(categoria != "Registrados") %>%
    group_by(fecha) %>%  mutate(perc = round(100*count/sum(count), 2)) %>%
    hchart(
    'column', hcaes(x = 'fecha', y = 'perc', group = 'categoria'), stacking = "normal") %>%
    hc_tooltip(sort = F,
            shared = T,
            borderWidth= 0,
            split = T,
            pointFormat = "<b>{point.categoria}:</b> {point.perc} %",
            headerFormat = '<span style="font-size: 15px">{point.key}</span>',
            style = list(fontSize = "14px", color = "#41657A"),
            useHTML = F) %>%
   hc_title(text = "<b> Comparación de registro de asistencia</b>",
            align = "left", style = list(fontSize = "15px", color = "#13384D")) %>% 
    hc_colors(c("#FF0000", "#008F39", "#0099FF")) 
    #hc_add_series(longer_historico %>% filter(categoria != "Registrados") %>%
    #  group_by(fecha) %>%  mutate(perc = round(100*count/sum(count), 2)) %>%
    #  filter(categoria != "No asistieron" ), "line",
    #  hcaes(x = fecha, y = perc, grouping = FALSE)) %>% 
   #hc_plotOptions(column = list(grouping = TRUE))
 
 return(Graph)
}
  
historico_asistencia_vs_no <- function(bd_webinar, horas){
  df <- bd_webinar %>%
    dplyr::select(Asistio, hora_registro) %>% dplyr::filter(!is.na(hora_registro)) %>% 
    dplyr::mutate(categoria = case_when(Asistio != "No" ~ "Sí Asistieron", Asistio == "No" ~ "No Asistieron")) %>% 
    dplyr::mutate(registro = lubridate::as_date(hora_registro)) %>% 
    tidyr::complete(registro = seq.Date(min(registro), max(registro), by="day"), categoria) %>% 
    dplyr::mutate(n = case_when(is.na(hora_registro) ~ 0, !is.na(hora_registro) ~ 1)) %>% 
    dplyr::group_by(registro, categoria, n) %>% 
    dplyr::summarise(n = sum(n)) 
  
  df_2 <- bd_webinar %>% 
    dplyr::select(hora_registro) %>% dplyr::filter(!is.na(hora_registro)) %>% 
    dplyr::mutate(categoria = "Registrados") %>% 
    dplyr::mutate(registro = lubridate::as_date(hora_registro)) %>% 
    tidyr::complete(registro = seq.Date(min(registro), max(registro), by="day"), categoria) %>% 
    dplyr::mutate(n = case_when(is.na(hora_registro) ~ 0, !is.na(hora_registro) ~ 1)) %>% 
    dplyr::group_by(registro, categoria, n) %>% 
    dplyr::summarise(n = sum(n)) 
  
  fechas <- horas %>% select(hora_webinar) %>% pull

Graph <- df %>% 
    hchart('area', rangesOpacity = 0.1, hcaes(x = 'registro', y = 'n', group = "categoria")) %>% 
    hc_plotOptions(area = list(stacking = F)) %>%
    hc_colors(c("#FF0000", "#008F39", "#0099FF")) %>% 
    hc_tooltip(sort = F,
             shared = T,
             borderWidth= 0,
             split = T,
             pointFormat = "<b>{point.categoria}:</b> {point.n}",
             headerFormat = '<span style="font-size: 15px">{point.key}</span>',
             style = list(fontSize = "14px", color = "#41657A"),
             useHTML = F) %>%
    hc_title(text = "<b> Comparación de registro de asistencia puntual</b>",
      align = "left", style = list(fontSize = "15px", color = "#13384D")) %>% 
    hc_add_series(df_2, "line",
    hcaes(x = 'registro', y = 'n', group = "categoria")) %>% 
    hc_plotOptions(column = list(grouping = TRUE)) %>% 
    hc_annotations(
      list(
        labels = list(
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[1])), y =10, xAxis = 0, yAxis = 0), text = "Webinar 1"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[2])), y =15, xAxis = 0, yAxis = 0), text = "Webinar 2"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[3])), y =20, xAxis = 0, yAxis = 0), text = "Webinar 3"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[4])), y =25, xAxis = 0, yAxis = 0), text = "Webinar 4"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[5])), y =30, xAxis = 0, yAxis = 0), text = "Webinar 5"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[6])), y =35, xAxis = 0, yAxis = 0), text = "Webinar 6"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[7])), y =40, xAxis = 0, yAxis = 0), text = "Webinar 7"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[8])), y =45, xAxis = 0, yAxis = 0), text = "Webinar 8"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[9])), y =48, xAxis = 0, yAxis = 0), text = "Webinar 9"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[10])), y =48, xAxis = 0, yAxis = 0), text = "Webinar 10"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[11])), y =50, xAxis = 0, yAxis = 0), text = "Webinar 11"),
          list(point = list(x = datetime_to_timestamp(as.Date(fechas[12])), y =60, xAxis = 0, yAxis = 0), text = "Webinar 12")
        )
      )
    )
  
  return(Graph)
}

graficar_pautas <- function(bd){
  p1 <- ggplot(bd, aes(x = Fecha, y = `Total Publicidad`)) + geom_path() + geom_point() + theme_minimal()
  p2 <- ggplot(bd, aes(x = Fecha, y = `Pauta Branding`)) + geom_path() + geom_point() + theme_minimal()
  p3 <- ggplot(bd, aes(x = Fecha, y = `Pauta Marketing`)) + geom_path() + geom_point() + theme_minimal()
  Graph <- p3 / p2 / p1 + plot_layout(heights = c(3,3,3))
  return(Graph)
}

graficar_registros <- function(bd){
  bd <- bd %>% select(Fecha, Registros, '$Ganancia')
  
  Graph <- ggplot() + 
    geom_line(data = bd, aes(x = Fecha, y = `$Ganancia`), color = "green") +
    theme_minimal()
  
  return(Graph)
}
