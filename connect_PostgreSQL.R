require(rJava)
require(RJDBC)


pw <- {
  "Amadeus-2010"
}

drv <- JDBC(driverClass = "org.postgresql.Driver", classPath="~/postgresql-42.1.4.jar")
con <- dbConnect(drv, "jdbc:postgresql://switch-db2.erg.berkeley.edu:5433/apl_cec?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory",
                 "jdlara",
                 pw)
test <- dbGetQuery(con, "SELECT * FROM lemmav2.lemma_total LIMIT 5")
