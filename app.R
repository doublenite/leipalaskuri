#

library(shiny)
library(bslib)
jauhoaineisto <- read.csv("~/leipalaskuri/data/jauhot.csv")
jauhoVaihtoehdot <- jauhoaineisto$jauho
siemenaineisto <- read.csv("~/leipalaskuri/data/siemenet.csv")
siemenVaihtoehdot <- siemenaineisto$siemen
  

source("helpers.R")

ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "journal"),
  title = "Leipälaskuri",
  sidebar = sidebar(
    width = 325,
    helpText("Aseta alla olevat arvot haluamillesi tasoille."),
    selectInput(inputId = "jauhotEka",
                label = "Jauhotyyppi 1",
                choices = jauhoVaihtoehdot,
                selected = "Myllyn Paras Emännän täysjyväkaurajauho"
                ),
    sliderInput(inputId = "osuus",
                label = "Jauhotyypin 1 osuus",
                min = 0,
                max = 1,
                value = 0.6
                ),
    selectInput(inputId = "jauhotToka",
                label = "Jauhotyyppi 2",
                choices = jauhoVaihtoehdot,
                selected = "Viljatuote Gluteeniton Maissijauho 400g"
                ),
    numericInput(inputId = "jauhojenMaara",
                 label = "Jauhojen määrä (dl)",
                 value = 8
                ),
    numericInput(inputId = "hiivanMaara",
                 label = "Kuivahiivan määrä (pss)",
                 value = 1
                ),
    numericInput(inputId = "vedenMaara",
              label = "Veden määrä (dl)",
              value = 5.5
                ),
    numericInput(inputId = "siirapinMaara",
              label = "Siirapin määrä (rkl)",
              value = 2
              ),
    numericInput(inputId = "suolanMaara",
                 label = "Suolan määrä (tl)",
                 value = 1.2
              ),    
    numericInput(inputId = "psylliuminMaara",
              label = "Psylliumin määrä (ml)",
              value = 25
              ),
    numericInput(inputId = "ksantaaninMaara",
                 label = "Ksantaanikumin määrä (ml)",
                 value = 0
    ),
    selectInput(inputId = "siementyyppi",
                label = "Valitse siemen",
                choices = siemenVaihtoehdot,
                selected = "Salliselta Chia-siemen"
              ),
    numericInput(inputId = "siementenMaara",
              label = "Siementen määrä (rkl)",
              value = 0
              ),
    sliderInput(inputId = "haihtuvuus",
                label = "Haihtuvuus (%)",
                min = 0,
                max = 25,
                value = 14
                )
    ),
  
  card(
    max_height="475px",
    card_header("Resepti"),
    textOutput("teksti"),
    tags$style(type="text/css", "#teksti {white-space: pre-wrap;}"),  
    card_footer(
      textOutput("taikinanMassa"),
      textOutput("korjattuMassa")
    )
  ),
  
  
  card(
    card_header("Ravintosisältö",radioButtons(inputId = "uuni", label = NULL,inline = TRUE, choices = c("Taikina","Leipä"), selected = "Leipä"),),
    tableOutput("poistetaan"),
    card_footer(
      textOutput("kilohinta")
    )
  )

)

server <-  function(input, output) {

  output$teksti <- renderText({
    vesi <- paste(input$vedenMaara,"dl vettä","\n")
    jauho1 <- jauhoetsin(x = input$jauhotEka)[,2]
    jauho2 <- jauhoetsin(x = input$jauhotToka)[,2]
    jauhot <- paste0(input$jauhojenMaara," dl jauhoseosta ",
                     "(",round(jauhomassat()[3],digits = 1)," dl ",jauho1,"jauhoja, ",round(jauhomassat()[4],digits = 1)," dl ", jauho2,"jauhoja",")","\n")
    siirappi <- paste(input$siirapinMaara,"rkl siirappia","\n")
    psyllium <- paste(input$psylliuminMaara,"ml psylliumia","\n")
    ksantaani <- paste(input$ksantaaninMaara,"ml ksantaanikumia","\n")
    suola <- paste(input$suolanMaara,"tl suolaa","\n")
    siemen <- siemenetsin(x = input$siementyyppi)[,2]
    
    if (input$siementenMaara > 0) {
      siemenet <- paste0(input$siementenMaara," rkl ",siemen,"nsiemeniä")
    } else {
      siemenet <- ""
    }

    
    hiiva <- paste(input$hiivanMaara,"pss kuivahiivaa","\n")
    paste(vesi,jauhot,hiiva,psyllium,ksantaani,siirappi,suola,siemenet, sep="\n")
    
  })
  
  
  siementenMassa <- reactive({
    otos <- siemenetsin(input$siementyyppi)
    siementenMassa <- input$siementenMaara*15/100*otos$tiheys
    siementenMassa
  })
  
  siemenlaskut <- reactive({
    otos1 <- siemenetsin(input$siementyyppi)[6:pituus]/100
    otos1 <- siementenMassa() * otos1
    otos1
  })
  
  jauhomassat <- reactive({
    tiheysEka <- jauhoetsin(x = input$jauhotEka)[,3]
    tiheysToka <- jauhoetsin(x = input$jauhotToka)[,3]
    osuusValittuEka <- input$osuus
    kerroin <- osuusValittuEka / (1-osuusValittuEka)
    maaraValittu <- input$jauhojenMaara
    
    massa2 <- tiheysEka*tiheysToka*maaraValittu / (tiheysEka + kerroin*tiheysToka)
    tilavuusToka <- massa2 * tiheysToka^(-1)
    tilavuusEka <- maaraValittu - tilavuusToka
    massa1 <- tiheysEka * tilavuusEka
    c(massa1,massa2,tilavuusEka,tilavuusToka)
  })
  
  muuMassa <- reactive({
    
    vedenMassa <- 100*input$vedenMaara
    siirapinMassa <- 15*1.4*input$siirapinMaara
    psylliuminMassa <- 0.8*input$psylliuminMaara
    suolanMassa <- 6*input$suolanMaara
    ksantaaninMassa <- 0.5*input$ksantaaninMaara
    c(vedenMassa,siirapinMassa,psylliuminMassa,suolanMassa,ksantaaninMassa)
  })
  
  muu <- reactive({
    
    siirapinMassa <- muuMassa()[2]
    psylliuminMassa <- muuMassa()[3]
    suolanMassa <- muuMassa()[4]
    ksantaaninMassa <- muuMassa()[5]
    
    muu <- NULL
    muu$energia <- 3.18 * siirapinMassa + 1.74 * psylliuminMassa + 0.04*suolanMassa + 1.80 * ksantaaninMassa
    muu$rasva <- 0.01 * psylliuminMassa + 0 * ksantaaninMassa
    muu$hydraatit <- 0.79 * siirapinMassa
    muu$sokerit <- 0.74 * siirapinMassa
    muu$proteeini <- 0.001 * siirapinMassa + 0.015 * psylliuminMassa + 0.05 * ksantaaninMassa
    muu$kuitu <- 0.85 * psylliuminMassa + 0.8 * ksantaaninMassa
    muu$suola <- 0.55 * suolanMassa + 0.103 * ksantaaninMassa
    muu
    
  })
  

  kokonaismassa <- reactive({
    jauhomassat <- jauhomassat()
    kokonaismassa <- sum(jauhomassat[1:2]) + sum(muuMassa()) + siementenMassa() + input$hiivanMaara * 11
    kokonaismassa
  })
  
  output$taikinanMassa <- renderText({
    paste("Taikinan massa:",round(kokonaismassa()/1000, digits = 2),"kilogrammaa.", "\n")
  })
  
  
  output$korjattuMassa <- renderText({
    kokonaismassa <- kokonaismassa()
    
    paste("Paistetun leivän arvioitu massa:",round((1-input$haihtuvuus/100)*kokonaismassa/1000, digits = 2),"kilogrammaa.")
    
  })
  
  
  ravintotiedot <- reactive({
    kerroin <- switch(input$uuni,
                      "Taikina" = 1,
                      "Leipä" = 1-input$haihtuvuus/100
                      )
    kokonaismassa <- kerroin * kokonaismassa()
    massat <- jauhomassat()
    ravinto <- ravintolaskuri(input$jauhotEka, input$jauhotToka, massat[1], massat[2])
    ravinto <- ravinto + siemenlaskut()
    muut <- muu()
    ravinto$rasva <- ravinto$rasva + muut$rasva 
    ravinto$energia <- ravinto$energia + muut$energia
    ravinto$hiilihyd <- ravinto$hiilihyd + muut$hydraatit
    ravinto$hiilihydSok <- ravinto$hiilihydSok + muut$sokerit
    ravinto$kuitu <- ravinto$kuitu + muut$kuitu
    ravinto$proteeini <- ravinto$proteeini + muut$proteeini
    ravinto$suola <- ravinto$suola + muut$suola
    ravinto <- (100/kokonaismassa)*ravinto 
    ravinto <- t(ravinto)
    row.names(ravinto) <- c("Energia", "Rasva", "josta tyyd.", "Hiilihydraatit", "josta sokereita", "Kuitu", "Proteeini", "Suola")
    names(ravinto) <- c("per 100g")
    ravinto
  })
 
  output$poistetaan <- renderTable({
    ravintotiedot()
  },rownames=TRUE, colnames = FALSE, striped = TRUE, digits = 1)
  
  kilohinta <- reactive({
    hinnat <- NULL
    hinnat$jauho1 <- jauhomassat()[1] * jauhoetsin(input$jauhotEka)[,5] / 1000
    hinnat$jauho2 <- jauhomassat()[2] * jauhoetsin(input$jauhotToka)[,5] / 1000
    hinnat$siemen <- siementenMassa() * siemenetsin(input$siementyyppi)[,5] / 1000
    hinnat$siirappi <- 2.95 * muuMassa()[2] / 1000
    hinnat$psyllium <- 24.90  * muuMassa()[3] / 1000
    hinnat$suola <- 6.87 * muuMassa()[4] / 1000
    hinnat$ksantaani <- 65.83 * muuMassa()[5] / 1000
    hinta <- sum(as.numeric(hinnat)) / ((1-input$haihtuvuus/100)*kokonaismassa()/1000)
    hinta
  })
  
  output$kilohinta <- renderText({
    paste("Kilohinta:", round(kilohinta() + .12/2 + input$hiivanMaara * .225, digits = 2)) 
  })
}



shinyApp(ui = ui, server = server)
