# library(dbmisc)
# library(RSQLite)
# library(DBI)
# conn <- DBI::dbConnect(RSQLite::SQLite(), "./data/reporte_zoom.db")

# conn <- dbConnect(RSQLite::SQLite(), "data/reporte_zoom.db")

# dbWriteTable(conn, "reporte_zoom_webinar_bd", reporte_zoom_webinar_bd)
# dbWriteTable(conn, "horas_webinar_bd", horas_webinar_bd)

# dbListTables(conn)
# bd_1 <- dbGetQuery(conn, "SELECT * FROM reporte_zoom_webinar_bd")
# bd_2 <- dbGetQuery(conn, "SELECT * FROM horas_webinar_bd")

# bd_1 %>% as.tibble() %>% 
#   mutate(fecha = as.Date(fecha))
 