## code to prepare `AWS` dataset goes here
pool <- pool::dbPool(
  drv = RMariaDB::MariaDB(),
  dbname = "db_gp",
  host = 'mysql.cduzrgqgkfht.us-east-2.rds.amazonaws.com',
  username = 'root',
  password = '9Blw33caY',
  port = 3306
)

DBI::dbExecute(pool, "CREATE TABLE reporte_zoom_webinar (
  idReporte INT AUTO_INCREMENT PRIMARY KEY,
  num_webinar INT,
  fecha DATE,
  Asistio VARCHAR(10),
  Nombre VARCHAR(50),
  Apellido VARCHAR(50),
  Usuario VARCHAR(100),
  correo VARCHAR(50),
  telefono VARCHAR(50),
  hora_registro DATETIME,
  hora_entrada DATETIME,
  hora_salida DATETIME
);")

# DBI::dbRemoveTable(pool,"reporte_zoom_webinar")
# reporte_zum <- list.files("data",pattern = ".csv") %>%
#   imap(~read_csv(glue::glue("data/{.x}")) %>%
#   mutate(num_webinar = .y, fecha = ymd(gsub(".csv", "", .x)))) %>%
#   reduce(bind_rows) %>%
#   filter(!`Nombre de fuente` %in% c('AMIGOS', 'Amigos'), !Nombre %in% c('TEAM EMILIO', 'TEAM', 'test'))
# 
# bd_reporte_subir <- bind_rows(
# reporte_zum %>% filter(num_webinar < 3) %>%
# mutate(
#   hora_registro = gsub("mar.", "", `Hora de registro`),
#   hora_registro =  paste("March ", hora_registro) %>% mdy_hms() %>% floor_date(unit = "minute"),
#   hora_entrada = gsub("mar.", "", `Puesto de trabajo`),
#   hora_salida = gsub("mar.", "", `Hora de salida`),
#   hora_entrada = paste("March ", hora_entrada) %>% mdy_hms() %>% floor_date(unit = "minute"),
#   hora_salida = paste("March ", hora_salida) %>% mdy_hms() %>% floor_date(unit = "minute")),
# reporte_zum %>% filter(num_webinar >= 3) %>%
# mutate(
#   hora_registro = floor_date(mdy_hms(`Hora de registro`),unit = "minute"),
#   hora_entrada = floor_date(mdy_hms(`Puesto de trabajo`),unit = "minute"),
#   hora_salida =  floor_date(mdy_hms(`Hora de salida`),unit = "minute"))
# ) %>% select(
#   num_webinar, fecha, asistio = Asistió, Nombre, Apellido, telefono = Teléfono,
#   correo = `Correo electrónico`, usuario = `Nombre de usuario (nombre original)`,
#   hora_registro, hora_entrada, hora_salida)
# DBI::dbWriteTable(pool, "reporte_zoom_webinar", value = bd_reporte_subir, append = T)
# bd <- tbl(pool, "reporte_zoom_webinar") %>% collect()

DBI::dbExecute(pool, "CREATE TABLE horas_webinar (
  idHoras INT AUTO_INCREMENT PRIMARY KEY,
  num_webinar INT,
  webinar VARCHAR(50),
  historia_previa VARCHAR(50),
  tres_secretos VARCHAR(50),
  oferta VARCHAR(50),
  preguntas VARCHAR(50),
  hora_webinar DATETIME
);")

# DBI::dbRemoveTable(pool,"horas_webinar")
# bd_horas_webinar <- tibble::tibble(
#   num_webinar = c(1, 2, 3, 4, 5, 6),
#   webinar = c("Primer Webinar", "Segundo Webinar", "Tercer Webinar", "Cuarto Webinar", "Quinto Webinar", "Sexto Webinar"),
#   historia_previa = c('19:16:00', '12:20:00', '12:44:00', '19:30:00', '19:24:00', '19:30:00'),
#   tres_secretos = c('20:02:00', '13:25:00', '13:51:00', '20:30:00', '20:30:00', '20:30:00'),
#   oferta = c('20:22:00', '13:41:00', '14:20:00', '20:50:00', '20:45:00', '20:55:00'),
#   preguntas = c('20:47:00', '14:13:00', '14:42:00', '21:20:00', '21:15:00', '21:25:00'),
#   hora_webinar = c('2021/03/18 19:00:00', '2021/03/20 12:00:00', '2021/03/26 12:00:00', '2021/04/08 19:00:00', '2021/04/15 19:00:00', '2021/04/21 19:00:00') %>% as_datetime()
#   )
# DBI::dbWriteTable(pool, "horas_webinar", value = bd_horas_webinar, append = T)
#  tbl(pool, "horas_webinar")
#  