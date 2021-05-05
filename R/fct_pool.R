pool <- pool::dbPool(
  drv = RMariaDB::MariaDB(),
  dbname = "db_gp",
  host = 'mysql.cduzrgqgkfht.us-east-2.rds.amazonaws.com',
  username = 'root',
  password = '9Blw33caY',
  port = 3306
)

onStop(function() {
  pool::poolClose(pool)
})

pins::board_register("rsconnect", server = "https://datos.morant.com.mx",
                     key = "Hgq4orUGFI75uZCxeeP1xjq7ce5eUlUG")

bd_reporte_zoom <- "reporte_zoom_webinar"
bd_horas_webinar <- "horas_webinar"
