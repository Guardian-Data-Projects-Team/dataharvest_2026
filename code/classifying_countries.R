library(tidyverse)
library(ellmer)

#Read the data
recipients <- read_csv("https://raw.githubusercontent.com/Guardian-Data-Projects-Team/dataharvest_2026/refs/heads/main/data/country_classification_data.csv?token=GHSAT0AAAAAAD6HTL3ATDWZSR74KHCZ7SIU2QWDAOQ")

#Find the official UN names of the recipients

#set up an ai and give it a system prompt
chat <- chat_google_gemini(
  model = "gemini-flash-lite-latest",
  system_prompt = "You are given a list of names of countries and world regions. In some cases, each row contain a single country. 
  In some cases, there is no single country, but a world region: for instance, Latin America and the Caribbean or South East Asia.
  In some other cases, several countries appear in the same line separated by commas. 
  You can also find entries called 'multicountry'.
  Please, for each entry, identify the official name of the country as used by the United Nations.
  When you find several countries in the same line (separated by commas) write the name of each country as used by the United Nations.
  When you can't attribute an official UN names, please, write 'unknown'. 
  When you find the world 'multicountry' or a region of the world without any countries in bracket or continent, please, write 'region/continent/multicountry'.
  After identifying the official UN name, please, classify each country as developed or developing economies according to the UN classification found here: https://unctadstat.unctad.org/EN/Classifications.html
  When there are several countries in the same line separated by commas, check each of the countries. If all of them belong to one class, write that class (eg. developing or developed). If there are countries from both groups then write 'several UN groups'.
  After classifying performing the classification described above, check if the nation is also classed as LDCs (Least Developed Countries) as classified by the United Nations. If there are several countries in a row separated by commas, check each of them. If there is at least one country that is classified as and LDC by the UN, write 'at least one LDC'. If none of them are LDC, write 'none LDC'.
  After the LDC classification, check if the country is considered a SIDs (Small Island Developing States) by the UN. If there are several countries in a row separated by commas, check each of them. If there is at least one country that is classified as SIDs by the UN, write 'at least one SIDs'. If none of them are SID, write 'none SIDs'.
  Return the output as a table with four columns: 'input_name', 'un_official_name','un_classification', 'LDC_marker',, 'SID_marker'.")

#tell the AI the structure of the data we want
countries <- type_object(
  .description = "Name of countries or world regions.",
  input_name=type_string("The name as it appears in the dataset"),
  un_official_name=type_string("The official name of the country or region as used by the United Nations, or 'unknown' if you can't identify it", required = FALSE),
  iso3_code = type_string("The ISO3 country code. If more than one country, separate by a comma;"),
  un_classification=type_string("The UN classification of the country as developed or developing economies, or 'several UN groups' if there are several countries with different classifications.", required=FALSE),
  LDC_marker=type_string("If the country is considered as LDCs (Least Developed Countries) according to the UN classification, write LDC. If there is a list of countries and one is an LDCs, write 'at least one LDC'. If none of the countries belong to the LDC group, write 'none LDC'", required = FALSE),
  SID_marker=type_string("If the country is considered as SIDs (Small Island Developing States) according to the UN classification, write SIDs. If there is a list of countries and one is an SIDs, write 'at least one SIDs'. If none of the countries belong to the SIDs group, write 'none SIDs'", required = FALSE)
)

list_countries <- recipients$recipient %>% as.list()


#running in parallel

data <- parallel_chat_structured(
  chat = chat,
  prompts = list_countries,
  type = countries,
  rpm = 15 #For this free google gemini model we should set the rate limit
)