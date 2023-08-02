# lula livre: 08/09/2019

buscar_pag <- function(pag, id_muni, captcha_code, orgao) {
  params <- list(`page` = pag, `size` = "100000", `sort` = "")
  body <- list(
    buscaOrgaoRecursivo = FALSE,
    orgaoExpeditor = list(id = orgao),
    idEstado = 26L,
    idMunicipio = id_muni
  ) |> purrr::compact()

  if (is.null(orgao)) body$orgaoExpeditor <- NULL

  res <- httr::POST(
    url = "https://portalbnmp.cnj.jus.br/bnmpportal/api/pesquisa-pecas/filter",
    query = params,
    httr::set_cookies(portalbnmp = captcha_code),
    httr::accept_json(),
    encode = "json",
    body = body
  )

  if (res$status_code != 200) {
    usethis::ui_oops("Erro ao buscar página {pag + 1} no município {id_muni}")
    return(tibble::tibble(erro = "erro"))
  }

  result_list <- httr::content(res, simplifyDataFrame = TRUE) |>
    purrr::compact()

  result_list$content <- tibble::as_tibble(result_list$content)

  result_list
}

buscar_muni <- function(id_muni,
                        captcha_code = captcha_code_get(),
                        orgao = NULL) {

  page <- 0

  result_page <- buscar_pag(page, id_muni, captcha_code, orgao)

  result_data <- result_page$content |>
    dplyr::mutate(page = 1, .before = 1)

  while (!result_page$last) {
    page <- page + 1
    usethis::ui_info("Buscando página {page + 1}")
    result_page <- buscar_pag(page, id_muni, captcha_code, orgao)
    result_data <- dplyr::bind_rows(
      result_data,
      result_page$content |> dplyr::mutate(page = page + 1, .before = 1)
    )
  }
  result_data
}

listar_orgaos <- function(id_muni, captcha_code = captcha_code_get()) {
  u <- paste0(
    "https://portalbnmp.cnj.jus.br/bnmpportal/api/",
    "pesquisa-pecas/orgaos/municipio/",
    id_muni
  )
  r <- httr::GET(u, httr::set_cookies(portalbnmp = captcha_code))
  r |>
    httr::content(simplifyDataFrame = TRUE) |>
    tibble::as_tibble() |>
    with(id)
}

listar_municipios <- function(id_uf, captcha_code = captcha_code_get()) {
  u <- paste0(
    "https://portalbnmp.cnj.jus.br/bnmpportal/api/dominio/por-uf/",
    id_uf
  )
  r <- httr::GET(u, httr::set_cookies(portalbnmp = captcha_code))
  r |>
    httr::content(simplifyDataFrame = TRUE) |>
    tibble::as_tibble() |>
    dplyr::select(-uf) |>
    janitor::clean_names()
}

captcha_code_get <- function() {
  paste0(
    "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJndWVzdF9wb3J0YWxibm1wIiwiY",
    "XV0aCI6IlJPTEVfQU5PTllNT1VTIiwiZXhwIjoxNjkxMDY3OTg2fQ.Y8ik",
    "VKDh_TEs42LSeopVErnfjdDO7XravweZUXROL_WwvTQFh7Cn90Nre9pIQkL",
    "UkuuBTfzkf8uNVIm6a_cQQg"
  )
}


# código captcha para acessar os documentos



## são paulo: precisa ser diferente porque tem mais de 10 mil linhas

captcha_code <- captcha_code_get()
id_muni <- 9422

orgaos <- listar_orgaos(id_muni)

dados_sp <- purrr::map(orgaos, \(x) {
  Sys.sleep(2)
  buscar_muni(id_muni, captcha_code, orgao = x)
}, .progress = TRUE)

dados_sp_bind <- dados_sp |>
  purrr::list_rbind()

readr::write_rds(dados_sp_bind, "data-raw/rds/dados_sp_muni.rds")

## outros municípios
captcha_code <- captcha_code_get()
id_uf <- 26 # SP
aux_municipios <- listar_municipios(id_uf)

aux_municipios_sem_sp <- aux_municipios |>
  dplyr::filter(nome != "Sao Paulo")

dados_municipios_sem_sp <- purrr::map(aux_municipios_sem_sp$id, \(x) {
  Sys.sleep(2)
  buscar_muni(x, captcha_code)
}, .progress = TRUE) |>
  purrr::list_rbind()

readr::write_rds(dados_municipios_sem_sp, "data-raw/rds/dados_sp.rds")

dados_sp <- dplyr::bind_rows(dados_municipios_sem_sp, dados_sp_bind) |>
  janitor::clean_names()

readr::write_rds(dados_sp, "data-raw/rds/da_bnmp_sp.rds")

# descritiva
dados_sp |>
  dplyr::count(descricao_status)

dados_sp |>
  dplyr::filter(descricao_peca == "Mandado de Prisão") |>
  writexl::write_xlsx("data-raw/xlsx/da_bnmp_sp.xlsx")

dados_sp |>
  dplyr::filter(descricao_peca == "Mandado de Prisão") |>
  dplyr::mutate(data_expedicao = lubridate::ymd(data_expedicao)) |>
  dplyr::mutate(ano = lubridate::year(data_expedicao)) |>
  dplyr::count(ano) |>
  dplyr::mutate(prop = n/sum(n), prop_cum = cumsum(prop)) |>
  print(n = 100)


