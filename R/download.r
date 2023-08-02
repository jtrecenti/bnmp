#' Gerar codigo de captcha
#'
#' Gera um codigo do reCaptcha utilizado em outras requisicoes
#' posteriores. Talvez seja necessario gerar um novo codigo
#' caso o anterior tenha expirado.
#'
#' @return codigo do reCaptcha
captcha_code_get <- function() {
  paste0(
    "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJndWVzdF9wb3J0YWxibm1wIiwiY",
    "XV0aCI6IlJPTEVfQU5PTllNT1VTIiwiZXhwIjoxNjkxMDY3OTg2fQ.Y8ik",
    "VKDh_TEs42LSeopVErnfjdDO7XravweZUXROL_WwvTQFh7Cn90Nre9pIQkL",
    "UkuuBTfzkf8uNVIm6a_cQQg"
  )
}

buscar_pag <- function(pag, id_muni, captcha_code, orgao) {
  params <- list(page = pag, size = "100000", sort = "")
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
    usethis::ui_oops("Erro ao buscar pagina {pag + 1} no municipio {id_muni}")
    return(tibble::tibble(erro = "erro"))
  }

  result_list <- httr::content(res, simplifyDataFrame = TRUE) |>
    purrr::compact()

  result_list$content <- tibble::as_tibble(result_list$content)

  result_list
}


#' Buscar mandados a partir de um municipio
#'
#' Busca todos os mandados de prisao de um municipio.
#'
#' @param id_muni codigo do municipio
#' @param captcha_code codigo do reCaptcha
#' @param orgao codigo do orgao expedidor. Por padrao, busca todos os
#' orgaos. E necessario somente em municipios que retornam mais de
#' 10.000 resultados. Nesse caso, e necessario buscar os orgaos
#' individualmente. Para isso, utilize a funcao listar_orgaos().
#'
#' @return tibble com os mandados de prisao
#' @export
buscar_muni <- function(id_muni,
                        captcha_code = captcha_code_get(),
                        orgao = NULL) {

  page <- 0

  result_page <- buscar_pag(page, id_muni, captcha_code, orgao)

  result_data <- result_page$content |>
    dplyr::mutate(page = 1, .before = 1)

  while (!result_page$last) {
    page <- page + 1
    usethis::ui_info("Buscando pagina {page + 1}")
    result_page <- buscar_pag(page, id_muni, captcha_code, orgao)
    result_data <- dplyr::bind_rows(
      result_data,
      result_page$content |> dplyr::mutate(page = page + 1, .before = 1)
    )
  }
  result_data
}

#' Listar orgaos expedidores de um municipio
#'
#' Lista todos os orgaos expedidores de um municipio
#'
#' @param id_muni codigo do municipio
#' @param captcha_code codigo do reCaptcha
#'
#' @return tibble com os orgaos expedidores
#' @export
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

#' Listar municipios de um estado
#'
#' Lista todos os municipios de um estado
#'
#' @param id_uf codigo do estado
#' @param captcha_code codigo do reCaptcha
#'
#' @return tibble com os municipios
#' @export
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