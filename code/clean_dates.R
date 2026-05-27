library(tidyverse)
library(ellmer)

#set up an ai and give it a system prompt
chat <- chat_google_gemini(
  model = "gemini-flash-lite-latest",
  system_prompt = "You have been given a list of dates that comes from emails. The emails were in PDF format and have been applied an OCR process to transform them into txt documents. 
  Some of them include the date of the week and most of them include the day, month, year and the time. 
  Some of the dates are not well formatted. 
  Your task is to clean the dates and the time for each of them and put them in the format yyyy-mm-dd hh:mm:ss.
  All of the cleaned dates should fall between the year 2000 and August 2019.
  If the date is not available, please return NA",
)

#get our prompting texts
prompts_dates <- read_csv("https://raw.githubusercontent.com/Guardian-Data-Projects-Team/dataharvest_2026/refs/heads/main/data/epstein_correspondence_sample_data.csv?token=GHSAT0AAAAAAD6HTL3AR7RXKPH7H6N4CA4G2QXE3MQ")$Date %>% 
  as.list()

#tell the AI the structure of the data we want
date_type <- type_object(
  .description = "A cleaned date in the form of yyyy-mm-dd hh:mm:ss",
  llm_date = type_string("A cleaned date in the form of yyyy-mm-dd hh:mm:ss
                          You are very careful about understanding the output after an OCR process of the emails into a txt document. 
                          For example, a date 'Wed, 08 Dec 2010 18:15:40 +0000' would be transformed into '2010-12-08 18:15:40'.
                          You are aware that the cleaned date should fall between the year 2000 and August 2019. So the date 2026-01-14 would be invalid - it is more likely this is an OCR error for 2016-01-14.
                          In this example, 'Monday, November 04, 2002 9:42 PM<br>, the final date would be '2002-11-04 21:42:00'.
                          In this example, '12/1/2009 2:11:44 PM', the final date would be '2009-12-01 14:11:44'.
                          In this example, 'Fri, 9 Sep 201 1.20:19:53 -0400', the final date would be '2011-09-09 20:19:53'. If you cannot extract a date with a reasonable level of confidence, return NA",
                         required = FALSE)
)


#running in parallel

dates_cleaned <- parallel_chat_structured(
  chat = chat,
  prompts = prompts_dates,
  type = date_type,
  rpm = 15 #For this free google gemini model we should set the rate limit
)
