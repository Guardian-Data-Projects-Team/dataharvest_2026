#extract employees number using ellmer
library(tidyverse)
library(ellmer)

chat <- chat_google_gemini(
  model = "gemini-flash-lite-latest",
  system_prompt = "You are an expert in corporate accounts and interpreteting text extracted from PDF documents. You can extract the number of employees from text. 
  You are given a text excerpt from a UK Companies House annual report. This text contains a snipped of information about the employees of a company, usually including the number in recent years.
  Sometimes this is from a table which has been OCRed as a string, so interpreting the order of numbers correctly is very important.
  Your task is to extract the number of employees, where available, and return it as a structured data object. If the number of employees is not mentioned in the text, return 0."
)

#set our schema
type_employees <- type_object(
  .description = "The number of employees in the most recent year of the accounts, if known.",
  employees = type_number("The number of employees in the most recent year of the accounts, if known. 
                          You are very careful about understanding the semantics and meaning from OCRed pdf text. For example, a snipped that said '2022: nil). 6 employees the company did not employ any personnel during the year (2022' would return nill employees, because you would judge that the 6 is a page or section number, and the text says no-one was employed.
                          In this example 'average number of employees employed by the company (including executive directors) was: 2023 2022 number number administration 7 1 their aggregate remuneration comprised: 2023 2022 £000 £000 wages and salaries 233 224 social security costs 24 30 other pension costs 19 12' the number of employees is 7, because you understand this was OCRed from a table and the years are given in order of 2023 first then 2022, and the number 7 is the next number and comes before the number 1, meaning  it corresponds to 2023 (the most recent year) and the number 1 to 2022.
                          In this example '2,990 employees the company had no employees during the year (2022 - £nil). no' you would return 0 because you understand that the 2,990 is referring to something else before this snippet.
                          In this example 'average number of people employed during the period including directors, was: 2024 2023 average average administration and management - 61 selling and distribution - 267 - 328 2024 2023 fte* fte* administration and management - 57 selling and distribution - 222 - 279' you understand the number is 0 because a hyphen '-' is often used to represent zeros in financial accounts.
                          ",required = FALSE)
)

#get our prompting texts
original_data <- read_csv("https://github.com/Guardian-Data-Projects-Team/dataharvest_2026/raw/refs/heads/main/data/company_employee_snippets.csv")
prompts <- original_data |> 
  pluck("employees_text") |> 
  as.list()

data <- parallel_chat_structured(chat, prompts, 
                                 type = type_employees,
                                 rpm = 15) |> #for free google gemini
  #join back our prompts, for checking:
  mutate(prompts=unlist(prompts))
