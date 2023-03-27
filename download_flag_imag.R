pacman::p_load(tidyverse,RSelenium,netstat,purrr)

# Cria um servidor para o "bot" navegar
rD <- rsDriver(browser=c("chrome"),chromever = "111.0.5563.64",verbose = T, port=free_port())
remDr <- rD$client


remDr$navigate("https://www.worldometers.info/geography/flags-of-the-world/")


data_imag <- remDr$findElements(using = "xpath","//div[@class='col-md-4']/div")
link_imag <- remDr$findElements(using = "xpath","//div[@class='col-md-4']/div/a")



paises = dados %>% distinct(Country) %>% pull(Country)

data_imag_names <- lapply(data_imag,function(x){
  x$getElementText() %>% unlist()
}) %>% flatten_chr()


data_imag_link <-  lapply(link_imag,function(x){
  x$getElementAttribute("href") %>% unlist()
}) %>% flatten_chr()

for (i in which(data_imag_names %in% paises)) {
  download.file(
    url = data_imag_link[i],mode = "wb",
    # Como existem arquivos .csv e .zip
    # foi extraido a extenssão dos arquivos e adicionado ao nome dos arquivos salvo.
    destfile = paste0(data_imag_names[i],".jpg")
  )
}




download.file(
  url = data_imag_link[which(data_imag_names == "U.S.")],mode = "wb",
  # Como existem arquivos .csv e .zip
  # foi extraido a extenssão dos arquivos e adicionado ao nome dos arquivos salvo.
  destfile = paste0("United States",".jpg"))

download.file(
  url = data_imag_link[which(data_imag_names == "U.K.")],mode = "wb",
  # Como existem arquivos .csv e .zip
  # foi extraido a extenssão dos arquivos e adicionado ao nome dos arquivos salvo.
  destfile = paste0("United Kingdom",".jpg"))

download.file(
  url = data_imag_link[which(data_imag_names == "U.A.E.")],mode = "wb",
  # Como existem arquivos .csv e .zip
  # foi extraido a extenssão dos arquivos e adicionado ao nome dos arquivos salvo.
  destfile = paste0("United Arab Emirates",".jpg"))
