career_timeline <- function(lang = "en") {
  suppressPackageStartupMessages(library(ggplot2))

  since_word <- c(
    en = "since", it = "dal", es = "desde", pt = "desde",
    fr = "depuis", de = "seit"
  )[[lang]]

  stage_labels <- list(
    en = c(
      "Bachelor of Sciences\nUniversity of Barcelona",
      "Master of Sciences\nUFRGS, Brazil",
      "Ph.D.\nUFRN, Brazil",
      "Postdoc\nWSL, Switzerland",
      "Scientist\nEAWAG, Switzerland"
    ),
    it = c(
      "Laurea triennale in Scienze\nUniversità di Barcellona",
      "Laurea magistrale in Scienze\nUFRGS, Brasile",
      "Dottorato di ricerca\nUFRN, Brasile",
      "Postdoc\nWSL, Svizzera",
      "Ricercatore\nEAWAG, Svizzera"
    ),
    es = c(
      "Licenciatura en Ciencias\nUniversidad de Barcelona",
      "Máster en Ciencias\nUFRGS, Brasil",
      "Doctorado\nUFRN, Brasil",
      "Postdoctorado\nWSL, Suiza",
      "Científico\nEAWAG, Suiza"
    ),
    pt = c(
      "Bacharelado em Ciências\nUniversidade de Barcelona",
      "Mestrado em Ciências\nUFRGS, Brasil",
      "Doutorado\nUFRN, Brasil",
      "Pós-doutorado\nWSL, Suíça",
      "Cientista\nEAWAG, Suíça"
    ),
    fr = c(
      "Licence ès Sciences\nUniversité de Barcelone",
      "Master ès Sciences\nUFRGS, Brésil",
      "Doctorat\nUFRN, Brésil",
      "Postdoctorat\nWSL, Suisse",
      "Scientifique\nEAWAG, Suisse"
    ),
    de = c(
      "Bachelor of Science\nUniversität Barcelona",
      "Master of Science\nUFRGS, Brasilien",
      "Promotion (Ph.D.)\nUFRN, Brasilien",
      "Postdoc\nWSL, Schweiz",
      "Wissenschaftler\nEAWAG, Schweiz"
    )
  )[[lang]]

  events <- data.frame(
    stage = factor(seq_along(stage_labels), levels = seq_along(stage_labels)),
    label = stage_labels,
    start = as.Date(c("2008-01-01", "2015-01-01", "2017-01-01", "2023-05-01", "2025-06-01")),
    end   = as.Date(c("2014-01-01", "2017-01-01", "2021-01-01", "2025-05-01", NA))
  )
  is_ongoing <- is.na(events$end)
  events$end[is_ongoing] <- Sys.Date()
  events$years <- paste(format(events$start, "%Y"), format(events$end, "%Y"), sep = "–")
  events$years[is_ongoing] <- paste(since_word, format(events$start[is_ongoing], "%Y"))
  events$mid <- events$start + (events$end - events$start) / 2

  # stagger labels above/below-further so adjacent close entries don't collide
  stagger <- rep(c(0, 1), length.out = nrow(events))
  events$label_y <- 0.55 + stagger * 0.75
  events$years_y <- -0.25 - stagger * 0.55

  ggplot(events) +
    geom_segment(
      aes(x = start, xend = end, y = 0, yend = 0),
      linewidth = 6, lineend = "round", color = "#38A7BB"
    ) +
    geom_segment(
      aes(x = mid, xend = mid, y = 0, yend = label_y - 0.15),
      linewidth = 0.3, color = "#AAAAAA"
    ) +
    geom_point(aes(x = start, y = 0), size = 2.2, color = "#38A7BB") +
    geom_point(
      data = events[nrow(events), ],
      aes(x = end, y = 0), size = 2.2, color = "#38A7BB"
    ) +
    geom_text(
      aes(x = mid, y = label_y, label = label),
      size = 2.9, lineheight = 0.95, color = "#333333", vjust = 0
    ) +
    geom_text(
      aes(x = mid, y = years_y, label = years),
      size = 2.7, color = "#555555", vjust = 1
    ) +
    scale_y_continuous(limits = c(-1.1, 2.1)) +
    theme_void() +
    theme(plot.margin = margin(5, 15, 5, 15))
}
