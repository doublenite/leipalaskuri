jauhoaineisto <- read.csv("~/leipalaskuri/data/jauhot.csv")
pituus <- length(jauhoaineisto)
jauhoVaihtoehdot <- jauhoaineisto$jauho
siemenaineisto <- read.csv("~/leipalaskuri/data/siemenet.csv")
siemenVaihtoehdot <- siemenaineisto$siemen

jauhoetsin <- function(x) {
  subset(jauhoaineisto, x == jauhoaineisto$jauho)

}

siemenetsin <- function(x) {
  subset(siemenaineisto, x == siemenaineisto$siemen)
}

ravintolaskuri <- function(jauho1,jauho2, massa1,massa2) {
  rivi1 <- massa1*jauhoetsin(jauho1)[6:pituus]/100
  rivi2 <- massa2*jauhoetsin(jauho2)[6:pituus]/100
  return(rivi1 + rivi2)
}

kuitulaskuri <- function(jauho1,jauho2,massa1,massa2){
  ravintolaskuri(jauho1,jauho2,massa1,massa2)[,6]
}
