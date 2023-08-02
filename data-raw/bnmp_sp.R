# lula livre: 08/09/2019

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


piggyback::pb_new_release(tag = "dados_sp")
piggyback::pb_upload("data-raw/rds/da_bnmp_sp.rds", tag = "dados_sp")
piggyback::pb_upload("data-raw/xlsx/da_bnmp_sp.xlsx", tag = "dados_sp")
