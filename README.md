
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bnmp

<!-- badges: start -->
<!-- badges: end -->

The goal of bnmp is to download and process data from the ‘Banco
Nacional de Monitoramento de Prisões’ (BNMP) of the Brazilian National
Council of Justice (CNJ).

## Installation

You can install the development version of bnmp from GitHub:

``` r
remotes::install_github("jtrecenti/bnmp")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(bnmp)

id_uf <- 26

listar_municipios(id_uf)
#> # A tibble: 935 × 5
#>       id nome                     cod_ibge flg_distrito id_corporativo
#>    <int> <chr>                       <int> <lgl>                 <int>
#>  1  8610 Adamantina                3500105 FALSE                    30
#>  2  8611 Adolfo                    3500204 FALSE                    32
#>  3  8612 Agisse - Distrito              NA TRUE                     NA
#>  4  8613 Agua Vermelha - Distrito       NA TRUE                     NA
#>  5  8614 Aguai                     3500303 FALSE                    62
#>  6  8615 Aguas Da Prata            3500402 FALSE                    65
#>  7  8616 Aguas De Lindoia          3500501 FALSE                    67
#>  8  8617 Aguas De Santa Barbara    3500550 FALSE                    68
#>  9  8618 Aguas De Sao Pedro        3500600 FALSE                    69
#> 10  8619 Agudos                    3500709 FALSE                    76
#> # ℹ 925 more rows
```

``` r
# adamantina
id_muni <- 8610
buscar_muni(id_muni) |>
  dplyr::glimpse()
#> Rows: 44
#> Columns: 20
#> $ page                    <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
#> $ id                      <int> 194561480, 181671946, 174642273, 96146346, 193…
#> $ numeroPeca              <chr> "0000482642021826008110000120", "1500276392022…
#> $ numeroProcesso          <chr> "00004826420218260081", "15002763920228260081"…
#> $ nomePessoa              <chr> "Everton Golfeto da Silva", "Jebberson Barreir…
#> $ alcunha                 <chr> "Não Informado", "Não informado", "Não informa…
#> $ descricaoStatus         <chr> "Pendente de Cumprimento", "Pendente de Cumpri…
#> $ dataExpedicao           <chr> "2023-07-03", "2022-02-24", "2021-11-03", "201…
#> $ nomeOrgao               <chr> "01 CUMULATIVA DE ADAMANTINA", "03 CUMULATIVA …
#> $ descricaoPeca           <chr> "Mandado de Internação", "Mandado de Prisão", …
#> $ idTipoPeca              <int> 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ nomeMae                 <chr> "Maria Lucia Golfeto", "Não informado", "Não i…
#> $ nomePai                 <chr> "Nelsinho Pereira da Silva", "Não informado", …
#> $ descricaoSexo           <chr> "Masculino", "Masculino", "Masculino", "Mascul…
#> $ descricaoProfissao      <chr> "Pedreiro", "Não informado", "Não informado", …
#> $ dataNascimento          <chr> "1988-04-22", NA, NA, "1986-06-15", NA, NA, "1…
#> $ numeroPecaAnterior      <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ numeroPecaFormatado     <chr> "0000482-64.2021.8.26.0081.10.0001-20", "15002…
#> $ dataNascimentoFormatada <chr> "22/04/1988", " ", " ", "15/06/1986", " ", " "…
#> $ dataExpedicaoFormatada  <chr> "03/07/2023", "24/02/2022", "03/11/2021", "12/…
```

## License

MIT
