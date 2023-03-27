pacman::p_load(shinyWidgets,htmltools,tidyverse,shiny,DT,shinythemes,bslib,stringr,paletteer,waiter,highcharter,readr)

#setwd("HD_Externo/Portifolio/Shiny_Brands/")

#source("manipulacoes_brand.R")
##### Manipulações --------------------------------------------------------------------------------------------------
dados <- read.csv2("Biggest_Companies.csv") %>%
  mutate_at(vars(4:7),~str_remove(.,"(.*[$])")) %>% 
  mutate_at(vars(4:7),~str_replace(.," ","")) %>% 
  mutate_at(vars(4:7),~str_replace(.,",","")) %>% 
  mutate_at(vars(4:7),~gsub('M', 'e6',.)) %>%
  mutate_at(vars(4:7),~gsub('B', 'e9',.)) %>% 
  mutate_at(vars(4:7),~format(as.numeric(.), scientific = FALSE)) %>% 
  mutate_at(vars(4:7),~as.numeric(.)) %>% 
  mutate_at(vars(4:7), ~ round(./1e9,3)) %>% 
  rename("MarketValue"="Market.Value")

dados_mapa <- dados %>%
  filter(Country != c("Hong Kong","Bermuda")) %>%
  mutate(Country = case_when(
    Country == "United States" ~ "United States of America",
    TRUE ~ Country
  )) %>% 
  group_by(Country) %>% summarise(Vendas = mean(Sales),Lucro = mean(Profit),Ativos = mean(Assets),"Valor Mercado" = mean(MarketValue)) %>% rename(name = Country )

paises = dados %>% distinct(Country) %>% pull(Country)

img_uri <- function(x) { sprintf('<img src="%s" height="30"/>', knitr::image_uri(x)) }


pais = list()
for(i in 1:length(paises)){
  caminhos <- img_uri(paste0(paises[i],".jpg"))
  pais[[i]] <- caminhos
  
}

data_flag <- data.frame(Country = paises, "path" = unlist(pais))

dados  = dados %>% left_join(data_flag,by = "Country")



mapdata <- get_data_from_map(download_map_data("https://code.highcharts.com/mapdata/custom/world-highres.js")) %>%
  filter(name %in% dados_mapa$name) 

dados <- dados %>% left_join(mapdata[,c(6,14)],by = c("Country"="name")) %>%
  mutate(continent = case_when(
    Country %in% c("United States","Bermuda") ~ "North America",
    Country == "Hong Kong" ~ "Asia",
    TRUE ~ continent
  ))

dados_continente <- dados %>%
  group_by(continent) %>% 
  summarise_at(4:7,~round(mean(.),1)) %>% 
  arrange(continent) %>%
  mutate(continent = fct_inorder(continent))


dados_pais <- dados %>% group_by(Country,continent) %>% summarise_at(3:6,~round(mean(.),1)) %>% ungroup() %>% 
  mutate_at(vars("Country","continent"),as.factor)

dados_pais_continente = dados_pais %>%
  group_nest(continent) %>% 
  mutate(id = continent,
         type = "column",
         data = map(data,mutate,name = Country, y = Sales),
         data = map(data,list_parse))


x <- c("Vendas", "Lucro", "Ativos","Valor de Mercado")
y <- c("$ {point.Sales} Bilhões", "$ {point.Profit} Bilhões", "$ {point.Assets} Bilhões","$ {point.MarketValue} Bilhões")

tt <- tooltip_table(x, y)





colors <- c(
  "#d2fbd4","#a5dbc2","#7bbcb0","#559c9e","#3a7c89","#235d72","#123f5a"
)

colors_sales <- c("#123F5A", "#14445E" ,"#174962" ,"#1A4E66", "#1D536A" ,"#20586E" ,"#235D72", "#266275" ,"#2A6779" ,"#2E6C7D", "#327181", "#367685", "#3A7C89", "#3E818C" ,"#438690" ,"#478C93" ,
                  "#4B9197", "#50969A" ,"#559C9E" ,"#5BA1A1" ,"#61A6A4" ,"#68ACA7", "#6EB1AA", "#74B6AD", "#7BBCB0" ,"#82C1B3",
                  "#89C6B6", "#90CBB9" ,"#97D0BB" ,"#9ED5BF" ,"#A5DBC2" ,"#ACE0C4", "#B4E5C8" ,"#BBEBCB" ,"#C3F0CE" ,"#CAF5D1", "#D2FBD4")
##### --------------------------------------------------------------------------------------------------


##### Dashboard --------------------------------------------------------------------------------------------------

main <- layout_column_wrap(
  width = 1,
  heights_equal = "row",
  layout_column_wrap(
    #width = 1/2,
    #class = "my-3",
    width = NULL,
    style = css(grid_template_columns  = "2fr 1fr"),
    card(full_screen = T,
         card_body_fill(dataTableOutput("tab_ranking"))
    ),
    navs_tab_card(full_screen = TRUE,
                  #height = "fit-content",
                  nav("Vendas",
                      card_body_fill(highchartOutput("empresa_venda"))
                      ),
                  nav("Lucro",
                      card_body_fill(highchartOutput("empresa_lucro"))
                      ),
                  nav("Ativos",
                      card_body_fill(highchartOutput("empresa_ativos"))
                      ),
                  nav("Valor de Mercado",
                      card_body_fill(highchartOutput("empresa_valor"))
                      )
    )
    
  ),
  layout_column_wrap(
    width = 1/3,
    navs_tab_card(full_screen = TRUE,
                  #height = "fit-content",
                  nav("Vendas",
                      card_body_fill(highchartOutput("vendas_med_c"))
                      ),
                  nav("Lucro",
                      card_body_fill(highchartOutput("lucro_med_c"))
                      ),
                  nav("Ativos",
                      card_body_fill(highchartOutput("ativos_med_c"))
                      ),
                  nav("Valor de Mercado",
                      card_body_fill(highchartOutput("valor_merc_med_c"))
                      )
    ),
    navs_tab_card(full_screen = TRUE,
                  #height = "fit-content",
                  nav("Vendas",
                      card_body_fill(highchartOutput("vendas_med"))
                      ),
                  nav("Lucro",
                      card_body_fill(highchartOutput("lucro_med"))
                      ),
                  nav("Ativos",
                      card_body_fill(highchartOutput("ativos_med"))
                      ),
                  nav("Valor de Mercado",
                      card_body_fill(highchartOutput("valor_merc_med"))
                      )
    ),
    navs_tab_card(full_screen = T,
                  #height = "fit-content",
                  nav("Vendas",         
                      card_body_fill(highchartOutput("mapa_venda"))
                      ),
                  nav("Lucro",         
                      card_body_fill(highchartOutput("mapa_lucro"))
                      ),
                  nav("Ativos",         
                      card_body_fill(highchartOutput("mapa_ativo"))
                      ),
                  nav("Valor de Mercado",         
                      card_body_fill(highchartOutput("mapa_valor"))
                      )
    )
    
  )
)




layout_dash <-  layout_column_wrap(
  height = "100%",
  #height = "calc(100vh - 90px)",
  width = "calc(100vh - 90px)" ,
  main
)

ui <- page_navbar(title = '',window_title = "Dashboard",collapsible = T,
                  selected = "Dashboard",
                  nav("Dashboard",layout_dash,
                      tags$style(HTML(
                        "
 .highcharts-tooltip {
    font-weight: 800;
 }
 .form-control {
 line-height:0.5;
 font-size: x-small;
 }
.nav-item {
font-size: x-small;
}
.card-header {
background-color: #000000;
font-weight: bold;

}
.card-header-tabs .nav-link.active, .card-header-tabs .nav-tabs>li>a.active, .card-header-tabs .nav-pills>li>a.active, .card-header-tabs ul.nav.navbar-nav>li>a.active{
    background-color: #ffffff;
    border-bottom-color: #20618ca8;
}

.nav-link, .nav-tabs > li > a, .nav-pills > li > a, ul.nav.navbar-nav > li > a {
color: #ffffff;
}

.btn{
padding: revert;
}

.div.dts tbody th, div.dts tbody td{
    white-space: break-spaces;
}
")),useWaiter(), 
    waiterShowOnLoad(html = spin_6(),color = "rgba(13,32,43,0.27)"),
    waiterOnBusy(html = spin_6(),color = "rgba(13,32,43,0.27)")),
                  nav("Mais Informações",
                      card(
                        card_header("Informações Sobre o APP/Dashboard",class = "bg-dark"),
                        card_body(markdown("Esse APP foi desenvolvido por: [https://www.linkedin.com/in/henrique-bragada-6a5967222/](https://www.linkedin.com/in/henrique-bragada-6a5967222/).
                                           Mais projetos em:  [https://github.com/bragada](https://github.com/bragada)"))
                      ))
                  
)

server <- function(input, output, session) {
 
  waiter_hide()
  # TABELA
  output$tab_ranking <- renderDataTable({
    datatable(dados %>% mutate(flag = dados$path) %>% 
                select(Rank,Name,Country,flag,Sales,Profit,Assets,MarketValue),
              filter = "top",
              escape = F,
              rownames = FALSE,
              colnames = c("Rank","Empresa","Pais","Nação","Vendas (em Bilhões)","Lucro (em Bilhões)","Ativos (em Bilhões)","Valor de Mercado (em Bilhões)"),
              extensions = c('Buttons','Scroller'),
              options = list(
                initComplete = JS("
                        function(settings, json) {
                          $(this.api().table().header()).css({
                          'font-size': '12px',
                          });
                        }
                       
                    "),
                searching = FALSE,
                dom = 'Bfrtip',
                buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                deferRender = TRUE,
                scrollY = 500,
                scroller = TRUE,
                columnDefs = list(list(className = 'dt-left', targets = "_all"))
              )) %>%
      formatStyle(
        "Sales",
        background = styleColorBar(dados$Sales, '#96bfcf', angle = -90),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>%
      formatStyle(
        "Profit",
        background = styleColorBar(dados$Profit, '#96bfcf', angle = -90),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>%
      formatStyle(
        "Assets",
        background = styleColorBar(dados$Assets, '#96bfcf', angle = -90),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      )%>%
      formatStyle(
        "MarketValue",
        background = styleColorBar(dados$MarketValue, '#96bfcf', angle = -90),
        backgroundSize = '100% 90%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center'
      ) %>% 
      formatStyle(c(4:8), `border-right` = "solid 1px") %>% 
      formatStyle(c(1:500), `border-top` = "solid 1px") %>% 
      formatStyle(columns = colnames(.$x$data), `font-size` = "12px") %>% 
      formatCurrency(c("Sales","Profit","Assets","MarketValue")) %>% 
      formatStyle(c(1,2:4:8), fontWeight = 'bold') %>% 
      formatStyle(columns =names(dados %>% mutate(flag = dados$path) %>% 
                          select(Rank,Name,Country,flag,Sales,Profit,Assets,MarketValue)),padding  = "2px" )
      
    

    
    
  })
  
  # MÉDIAS
  output$vendas_med <- renderHighchart({
    hchart(dados %>% group_by(Country) %>% summarise_at(3:6,~round(mean(.),1)) %>% arrange(desc(Sales)),
           "bar",hcaes(x =  Country, y = Sales)) %>% 
      hc_yAxis(title = list(text = "Média de Vendas (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat = tt,
        #"<span <span style='font-size:15px'> <b> Média de Vendas </b> </span> : <b>$ {point.y:.1f} Bilhões</b> </span><br>",
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      )%>% 
      hc_scrollbar(enabled = T) %>% 
      hc_colors("#367086") %>% 
      hc_title(text ="Média de Vendas por Pais de Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  output$lucro_med <- renderHighchart({
    hchart(dados %>% group_by(Country) %>% summarise_at(3:6,~round(mean(.),1)) %>% arrange(desc(Profit)),
           "bar",hcaes(x =  Country, y = Profit
                       #color = highcharter::colorize(Profit, colors)
           )) %>% 
      hc_yAxis(title = list(text = "Média de Lucro (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold',color = "black")), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat = tt,
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Média de Lucro por Pais de Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  output$ativos_med <- renderHighchart({
    hchart(dados %>% group_by(Country) %>% summarise_at(3:6,~round(mean(.),1)) %>% arrange(desc(Assets)),
           "bar",hcaes(x =  Country, y = Assets)) %>% 
      hc_yAxis(title = list(text = "Média de Ativos (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat = tt,
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Média de Ativos por Pais de Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  output$valor_merc_med <- renderHighchart({
    hchart(dados %>% group_by(Country) %>% summarise_at(3:6,~round(mean(.),1)) %>% arrange(desc(MarketValue)),
           "bar",hcaes(x =  Country, y = MarketValue)) %>% 
      hc_yAxis(title = list(text = "Média de Valor de Mercado (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat = tt,
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Média de Valor de Mercado por Pais de Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  # Empresas
  output$empresa_venda <- renderHighchart({
    hchart(dados %>% select(Name,Sales,Profit,Assets,MarketValue) %>% arrange(desc(Sales)),
           "bar",hcaes(x =  Name, y = Sales)) %>% 
      hc_yAxis(title = list(text = "Vendas (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '10px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat=tt,
        #pointFormat= "<span <span style='font-size:15px'> <b> Vendas </b> </span> : <b>$ {point.y:.1f} Bilhões </b> </span><br>",
        style = list(fontSize = '14px',fontWeight= 'bold'),
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Vendas por Empresa",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
    
  })
  
  output$empresa_lucro <- renderHighchart({
    hchart(dados %>% select(Name,Sales,Profit,Assets,MarketValue) %>% arrange(desc(Profit)),
           "bar",hcaes(x =  Name, y = Profit)) %>% 
      hc_yAxis(title = list(text = "Lucro (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat=tt,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Lucro por Empresa",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
    
  })
  
  output$empresa_ativos <- renderHighchart({
    hchart(dados %>% select(Name,Sales,Profit,Assets,MarketValue) %>% arrange(desc(Assets)),
           "bar",hcaes(x =  Name, y = Assets)) %>% 
      hc_yAxis(title = list(text = "Ativos (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat=tt,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Ativos por Empresa",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
    
  })
  
  output$empresa_valor <- renderHighchart({
    hchart(dados %>% select(Name,Sales,Profit,Assets,MarketValue) %>% arrange(desc(MarketValue)),
           "bar",hcaes(x =  Name, y = MarketValue)) %>% 
      hc_yAxis(title = list(text = "Valore de Mercado (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>%
      hc_xAxis(min = 0 , max = 15,title = list(text = "",style = list(fontSize = '13px',fontWeight= 'bold')), labels = list(style = list(fontSize = '11px',fontWeight= 'bold',color = "black")),type = 'category') %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,pointWidth = 10,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y}',style = list(fontSize = '10px')))) %>% 
      hc_tooltip( 
        useHTML  =TRUE,
        headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
        pointFormat=tt,
        style = list(fontSize = '14px',fontWeight= 'bold'),
        #backgroundColor = "#ffffff",
        borderColor= '#000000',
        table = T
      ) %>% 
      hc_scrollbar(enabled = T)%>% 
      hc_colors("#367086")%>% 
      hc_title(text ="Valor de Mercado por Empresa",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
    
  })
  
  # MÉDIAS AGRUPADO
  output$vendas_med_c <-renderHighchart({
    hchart(dados_continente,
           "column",
           hcaes(x = continent,y = Sales, name = continent,drilldown = continent),
           name = "Vendas",
           colorByPoint = TRUE) %>% 
      hc_drilldown(allowPointDrilldown = TRUE,
                   series = list_parse(dados_pais_continente)) %>% 
      hc_tooltip(useHTML = TRUE,
                 valueDecimals = 0,
                 #table = T,
                 style = list(fontSize = '14px',fontWeight= 'bold'),
                 headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
                 pointFormat = tt
                 #"<span <span style='font-size:15px'> <b> Média de Vendas: </b> </span> : <b> $ {point.Sales} Bilhões</b> </span><br> "
      ) %>% 
      hc_yAxis(title = list(text = "Média de Vendas (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y} Bi',style = list(fontSize = '11px')))) %>% 
      hc_colors(c("#dab629","#367086","#c12e34","#2b821d","#9026be")) %>% 
      hc_title(text ="Média de Vendas por Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
    
    
  })  
  
  output$lucro_med_c <- renderHighchart({
    hchart(dados_continente,
           "column",
           hcaes(x = continent,y = Profit, name = continent,drilldown = continent),
           name = "Vendas",
           colorByPoint = TRUE) %>% 
      hc_drilldown(allowPointDrilldown = TRUE,
                   series = list_parse(dados_pais_continente)) %>% 
      hc_tooltip(useHTML = TRUE,
                 valueDecimals = 0,
                 style = list(fontSize = '14px',fontWeight= 'bold'),
                 headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
                 pointFormat = tt) %>% 
      hc_yAxis(title = list(text = "Média de Lucro (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y} Bi',style = list(fontSize = '11px')))) %>% 
      hc_colors(c("#dab629","#367086","#c12e34","#2b821d","#9026be")) %>% 
      hc_title(text ="Média de Lucro por Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  output$ativos_med_c <- renderHighchart({
    hchart(dados_continente,
           "column",
           hcaes(x = continent,y = Assets, name = continent,drilldown = continent),
           name = "Vendas",
           colorByPoint = TRUE) %>% 
      hc_drilldown(allowPointDrilldown = TRUE,
                   series = list_parse(dados_pais_continente)) %>% 
      hc_tooltip(useHTML = TRUE,
                 valueDecimals = 0 ,
                 style = list(fontSize = '14px',fontWeight= 'bold'),
                 headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
                 pointFormat = tt) %>% 
      hc_yAxis(title = list(text = "Média de Ativos (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>% 
      hc_xAxis(title = list(text = "")) %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y} Bi',style = list(fontSize = '11px')))) %>% 
      hc_colors(c("#dab629","#367086","#c12e34","#2b821d","#9026be")) %>% 
      hc_title(text ="Média de Ativos por Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  output$valor_merc_med_c <- renderHighchart({
    hchart(dados_continente,
           "column",
           hcaes(x = continent,y = MarketValue, name = continent,drilldown = continent),
           name = "Vendas",
           colorByPoint = TRUE) %>% 
      hc_drilldown(allowPointDrilldown = TRUE,
                   series = list_parse(dados_pais_continente)) %>% 
      hc_tooltip(useHTML = TRUE,
                 valueDecimals = 0, 
                 style = list(fontSize = '14px',fontWeight= 'bold'),
                 headerFormat= "<span style='font-size:20px;'><b>{point.key}</b></span><br>",
                 pointFormat = tt)%>% 
      hc_yAxis(title = list(text = "Média de Valor de Mercado (em Bilhões)",style = list(fontSize = '14px',fontWeight= 'bold',color = "black"))) %>% 
      hc_xAxis(title = list(text = ""))  %>% 
      hc_plotOptions(series = list(centerInCategory= TRUE,borderWidth = 1,borderColor = "black", dataLabels = list(enabled = T,format = '$ {y} Bi',style = list(fontSize = '11px')))) %>% 
      hc_colors(c("#dab629","#367086","#c12e34","#2b821d","#9026be")) %>% 
      hc_title(text ="Média de Valor de Mercado por Origem das Empresas",
               style = list(color = "black", useHTML = TRUE,fontSize = '15px',fontWeight= 'bold'))
  })
  
  # MAPA
  output$mapa_venda <- renderHighchart({
    hcmap(
      "https://code.highcharts.com/mapdata/custom/world-highres.js",
      data =  dados_mapa,
      value = "Vendas",
      joinBy = c("name"),
      name = "Média de Vendas",
      dataLabels = list(enabled = TRUE, format = "{point.name}"),
      borderColor = "#FAFAFA",
      borderWidth = 0.1,
      #states = list(hover = list(color = "#3b99af")),
      tooltip = list(
        valueDecimals = 2,
        #style = list(fontWeight= 'bold', color= 'blue'),
        valuePrefix = "$ ",
        valueSuffix = " Bilhões",
        headerFormat= "<span style='font-size:15px;'><b>{point.key}</b></span><br>",
        pointFormat= "<span <span style=font-size:15px'>{series.name} </span> : <b> {point.value}</b> </span><br>"
      )
    ) %>%
      hc_mapNavigation( enabled= TRUE,buttonOptions = list(verticalAlign = "bottom")) %>%
      hc_colorAxis(min= 1,
                   max= 75,
                   minColor= '#e6e696',
                   maxColor= '#003700') %>% 
      hc_chart(backgroundColor = list(linearGradient = list(x1 = 0,y1= 1,x2 = 0,y2= 0),
                                      stops = list(c(0,'#C8DEE6'),
                                                   c(1,'#3b99af')))) %>% 
      hc_title(text = "As 500 Maiores Empresas do Mundo",
               style = list(color = "black",fontWeight= 'bold',
                            useHTML = TRUE,
                            fontSize = "17px")) |> 
      hc_subtitle(text = "A intensidade das cores denotam as quantidades de vendas médias segundo os paises de origem",
                  style = list(color = "black",fontWeight= 'bold',
                               useHTML = TRUE,
                               fontSize = "12px")) %>% 
      hc_legend(title = list(text = "Média de Vendas em Bilhões de $"))
  })
  
  output$mapa_lucro <- renderHighchart({
    hcmap(
      "https://code.highcharts.com/mapdata/custom/world-highres.js",
      data =  dados_mapa,
      value = "Lucro",
      joinBy = c("name"),
      name = "Média de Lucro",
      dataLabels = list(enabled = TRUE, format = "{point.name}"),
      borderColor = "#FAFAFA",
      borderWidth = 0.1,
      #states = list(hover = list(color = "#3b99af")),
      tooltip = list(
        valueDecimals = 2,
        #style = list(fontWeight= 'bold', color= 'blue'),
        valuePrefix = "$ ",
        valueSuffix = " Bilhões",
        headerFormat= "<span style='font-size:15px;'><b>{point.key}</b></span><br>",
        pointFormat= "<span <span style=font-size:15px'>{series.name} </span> : <b> {point.value}</b> </span><br>"
      )
    ) %>%
      hc_mapNavigation( enabled= TRUE,buttonOptions = list(verticalAlign = "bottom")) %>%
      hc_colorAxis(min= 1,
                   max= 10,
                   minColor= '#e6e696',
                   maxColor= '#003700') %>% 
      hc_chart(backgroundColor = list(linearGradient = list(x1 = 0,y1= 1,x2 = 0,y2= 0),
                                      stops = list(c(0,'#C8DEE6'),
                                                   c(1,'#3b99af')))) %>% 
      hc_title(text = "As 500 Maiores Empresas do Mundo",
               style = list(color = "black",
                            useHTML = TRUE,
                            fontSize = "17px")) |> 
      hc_subtitle(text = "A intensidade das cores denotam as quantidades médias de Lucro segundo os paises de origem",
                  style = list(color = "black",
                               useHTML = TRUE,
                               fontSize = "12px")) %>% 
      hc_legend(title = list(text = "Média de Lucro em Bilhões de $"))
  })
  
  output$mapa_ativo <- renderHighchart({
    hcmap(
      "https://code.highcharts.com/mapdata/custom/world-highres.js",
      data =  dados_mapa,
      value = "Ativos",
      joinBy = c("name"),
      name = "Média de Ativos",
      dataLabels = list(enabled = TRUE, format = "{point.name}"),
      borderColor = "#FAFAFA",
      borderWidth = 0.1,
      #states = list(hover = list(color = "#3b99af")),
      tooltip = list(
        valueDecimals = 2,
        #style = list(fontWeight= 'bold', color= 'blue'),
        valuePrefix = "$ ",
        valueSuffix = " Bilhões",
        headerFormat= "<span style='font-size:15px;'><b>{point.key}</b></span><br>",
        pointFormat= "<span <span style=font-size:15px'>{series.name} </span> : <b> {point.value}</b> </span><br>"
      )
    ) %>%
      hc_mapNavigation( enabled= TRUE,buttonOptions = list(verticalAlign = "bottom")) %>%
      hc_colorAxis(min= 1,
                   max= 640,
                   minColor= '#e6e696',
                   maxColor= '#003700') %>% 
      hc_chart(backgroundColor = list(linearGradient = list(x1 = 0,y1= 1,x2 = 0,y2= 0),
                                      stops = list(c(0,'#C8DEE6'),
                                                   c(1,'#3b99af')))) %>% 
      hc_title(text = "As 500 Maiores Empresas do Mundo",
               style = list(color = "black",
                            useHTML = TRUE,
                            fontSize = "17px")) |> 
      hc_subtitle(text = "A intensidade das cores denotam as quantidades médias de Ativos segundo os paises de origem",
                  style = list(color = "black",
                               useHTML = TRUE,
                               fontSize = "12px")) %>% 
      hc_legend(title = list(text = "Média de Ativos em Bilhões de $"))
  })
  
  output$mapa_valor <- renderHighchart({
    hcmap(
      "https://code.highcharts.com/mapdata/custom/world-highres.js",
      data =  dados_mapa,
      value = "Valor Mercado",
      joinBy = c("name"),
      name = "Média de Valor de Mercado",
      dataLabels = list(enabled = TRUE, format = "{point.name}"),
      borderColor = "#FAFAFA",
      borderWidth = 0.1,
      #states = list(hover = list(color = "#3b99af")),
      tooltip = list(
        valueDecimals = 2,
        #style = list(fontWeight= 'bold', color= 'blue'),
        valuePrefix = "$ ",
        valueSuffix = " Bilhões",
        headerFormat= "<span style='font-size:15px;'><b>{point.key}</b></span><br>",
        pointFormat= "<span <span style=font-size:15px'>{series.name} </span> : <b> {point.value}</b> </span><br>"
      )
    ) %>%
      hc_mapNavigation( enabled= TRUE,buttonOptions = list(verticalAlign = "bottom")) %>%
      hc_colorAxis(min= 1,
                   max= 380,
                   minColor= '#e6e696',
                   maxColor= '#003700') %>% 
      hc_chart(backgroundColor = list(linearGradient = list(x1 = 0,y1= 1,x2 = 0,y2= 0),
                                      stops = list(c(0,'#C8DEE6'),
                                                   c(1,'#3b99af')))) %>% 
      hc_title(text = "As 500 Maiores Empresas do Mundo",
               style = list(color = "black",
                            useHTML = TRUE,
                            fontSize = "17px")) |> 
      hc_subtitle(text = "A intensidade das cores denotam as quantidades de médias de Valor de Mercado segundo os paises de origem",
                  style = list(color = "black",
                               useHTML = TRUE,
                               fontSize = "12px")) %>% 
      hc_legend(title = list(text = "Média de Valor de Mercado em Bilhões de $"))
  })
  
}

shinyApp(ui, server)