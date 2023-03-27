# Shiny_APP_Web_Scraping_Dash
Um aplicativo feito em Shiny no R onde foi utilizado Web Scraping para realizar uma busca das imagens das bandeiras dos paises presentes na base de dados e utiliza-las em uma tabela dinâmica.

O link para o APP/DASHBOARD: https://hkbragada.shinyapps.io/Shiny_Brands/?_ga=2.38400038.485725936.1679927793-534592504.1679676184

O scrip do APP se encontra em shiny_brands.R, nele temos as manipulações da base de dados, imagens e mapa utilizados.
A parte de Web Scraping para o download das imagens das bandeiras dos respectivos pasises presentes na base de dados estão em download_flag_imag.R (Devido ao baixo número de exceções, algumas imagens foram baixadas a parte em função dos nomes divergentes e complicações futuras com a base de dados do mapa em .js caso fossem feitas as alterações nos nomes para o download automatico)


O link para o APP/DASHBOARD: https://hkbragada.shinyapps.io/Shiny_Brands/?_ga=2.38400038.485725936.1679927793-534592504.1679676184

O aplicativo conta do diversas funções interativas e dinâmicas como:
- A Tabela dinâmica e interativa conta com Download em .csv, excel, .pdf; além de print e copia da tabela já tabulada (com divisões) para ser colado em um arquivo .txt
- A Tabela ainda possível filtro de pesquisa e range de valores
- Nos gráficos é possível acessar mais informações ao passar o mouse sobre as barras
- Mapa Interativo e Dinâmico 
- Gráficos intra-gráficos (ao clicar nas barras é possível acessar um novo gráfico com os elementos do respectivo grupo)

Segue uma sequência de imagens para ilustrar tal funcionalidade:

<img width="488" alt="Captura de tela 2023-03-27 114138" src="https://user-images.githubusercontent.com/80830247/227978212-c067e1e3-af55-41c2-8d1b-5e2616557a93.png">

Ao clicar na barra "Asia" por exemplo, o gráfico se altera, agora com os paises do respectivo grupo selecionado


<img width="586" alt="Captura de tela 2023-03-27 114217" src="https://user-images.githubusercontent.com/80830247/227978264-b93eb098-9e7a-406a-bce0-22e1244246b2.png">

Segue uma imagem do APP:

<img width="1614" alt="Captura de tela 2023-03-27 113503" src="https://user-images.githubusercontent.com/80830247/227978759-74535023-cfd4-4d38-a694-16531ef52cc3.png">

A base de dados pode ser encontrada em: https://www.kaggle.com/datasets/berkayalan/the-worlds-biggest-companies-2021

O link para o APP/DASHBOARD: https://hkbragada.shinyapps.io/Shiny_Brands/?_ga=2.38400038.485725936.1679927793-534592504.1679676184
