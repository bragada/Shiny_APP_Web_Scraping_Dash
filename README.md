# Shiny_APP_Web_Scraping_Dash
Um aplicativo feito em Shiny no R onde foi utilizado Web Scraping para realizar uma busca das imagens das bandeiras dos paises presentes na base de dados e utiliza-las em uma tabela dinâmica.

O link para o APP/DASHBOARD: https://hkbragada.shinyapps.io/Shiny_Brands/?_ga=2.38400038.485725936.1679927793-534592504.1679676184

O scrip do APP se encontra em shiny_brands.R, nele temos as manipulações da base de dados, imagens e mapa utilizados.

A parte de Web Scraping para o download das imagens das bandeiras dos respectivos pasises presentes na base de dados estão em download_flag_imag.R (Devido ao baixo número de exceções, algumas imagens foram baixadas a parte. A questões ocorreu devido a ocorrência de nomes divergentes e complicações futuras com a base de dados do mapa em .js caso fossem feitas as alterações nos nomes)


O aplicativo conta do diversas funções interativas e dinâmicas como:
- A Tabela dinâmica e interativa conta com Download em .csv, excel, .pdf; além de print e copia da tabela já tabulada (com divisões) para ser colado em um arquivo .txt
- A Tabela ainda possível filtro de pesquisa e range de valores
- Nos gráficos é possível acessar mais informações ao passar o mouse sobre as barras
- Mapa Interativo e Dinâmico 
- Gráficos intra-gráficos (ao clicar nas barras é possível acessar um novo gráfico com os elementos do respectivo grupo)

Segue uma sequência de imagens para ilustrar tal funcionalidade:

Com o mouse sobre a barra é possível ver mais informações

<img width="556" alt="Captura de tela 2023-03-27 121159" src="https://user-images.githubusercontent.com/80830247/227983926-07194042-20cf-41f0-8019-a63683e9eb50.png">


Ao clicar na barra "Europe" por exemplo, o gráfico se altera, agora com os paises do respectivo grupo selecionado

<img width="559" alt="Captura de tela 2023-03-27 121300" src="https://user-images.githubusercontent.com/80830247/227983974-23c05d4b-b703-4192-8bf8-5f64a5576e6e.png">


Segue uma imagem do APP:

<img width="1703" alt="Captura de tela 2023-03-27 121139" src="https://user-images.githubusercontent.com/80830247/227984052-b2af770e-e634-45a5-9670-d000ab63c9b1.png">

A base de dados pode ser encontrada em: https://www.kaggle.com/datasets/berkayalan/the-worlds-biggest-companies-2021

O link para o APP/DASHBOARD: https://hkbragada.shinyapps.io/Shiny_Brands/?_ga=2.38400038.485725936.1679927793-534592504.1679676184
