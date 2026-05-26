#example guinness records script
library(httr2)
library(tidyverse)

#set up an ai and give it a system prompt
chat <- chat_google_gemini(
  model = "gemini-flash-lite-latest",
  system_prompt = "You are an archivist at the Guinness World Records whose job is to clean and extract structured data from record descriptions.",
)

#tell the AI the structure of the data we want
type_guinness_record <- type_object(
  #this will give us a clean country code
  iso3_country_code = type_string("The ISO3 country code of the record location",required = FALSE),
  #this will categorise the record as one of the following (scraped from the Guinness site)
  record_category = type_enum(values = c(
    "Art","Animals",
    "Audio records","Big stuff",
    "Careers","Collections & displays",
    "Company endorsement records","Extreme sports",
    "Food", "Human Body", "Journeys", "Literature, books and publishing, comics",
    "Longest Lines", "Mass Participation",
    "Non – Sport marathon", "Online/social media",
    "Plants", "Product testing (endorsement) records",
    "Quick Challenges", "Science",
    "Small stuff", "Speed vehicles/stunts",
    "Sports", "Strength",
    "Structures", "Technology",
    "Videogames"),
    #these descriptions were also scraped from the Guinness site
    description = "Examples for Art include: Largest/longest painting, Largest/longest drawing, Largest/longest mural, Largest/longest collage, Largest sculpture made of ‘x’, Largest mosaic made of ‘x’, Most contributions to ‘x’, Largest X word/sentence, Most expensive art
Examples for Animals include: Anatomy, Tallest, Shortest, Longest, Oldest, Gatherings, Tricks, Fastest time over a distance, Most in 'x' time, Fastest, Largest enclosures
Examples for Audio records include: Loudest, Individual, Crowd, Longest duration sound, Vocal, On an instrument, Highest/lowest pitch, Vocal, On an instrument
Examples for Big stuff include: Large manufactured items (Large replicas of existing items), Tallest item, Heaviest item, Longest outstretched item, Large objects made from a particular material, Large structures, Large civil engineering projects (walkways, bridges, cable cars), Large buildings, Large projections, Large contraptions, Large puzzles
Examples for Careers include: Longest careers, Youngest professional /oldest professional
Examples for Collections & displays include: Largest collection of ‘x’ related memorabilia, Largest collection of ‘x’ item type, Largest display of ‘x’ item type, Largest display of ‘x’ related items
Examples for Company endorsement records include: Bestselling, In a year, Cumulative, Highest revenue, In a year, Cumulative
Examples for Extreme sports include: Aerial records, Highest trick/jump, Longest trick/jump, Most somersaults in a trick, Most consecutive tricks, Most tricks in a timeframe, Fastest speed achieved skating/skiing/sailing etc, Longest wave surfed on a x
Examples for Food include: Largest, Single item, Serving, Container, Largest container (e.g. popcorn), Largest bag (e.g. candy, rice), Mosaic, Sculpture, Longest, Single item, Iconic food (e.g. sausage), LINE of items, Most expensive food / drink, food, drink, Most food items made in …(individual or team), 1 minute, 3 minutes, 1 hour, 8 hours, 12 hours, 24 hours, Most food served in …, 1 hour, 8 hours, 12 hours, 24 hours, Longest marathon, cooking, barbecue, Most people making food simultaneously, single location, multiple locations, Fastest time to consume, three items of food, one serving of food, one drink, Most consumed in …, 30 seconds, One minute
Examples for Human Body include: Body Modifications, Most overall, Most in a time, Largest modification e.g. flesh tunnel, Largest gatherings, Hair, Longest, Biggest e.g. afro, perm, Hair shaved in a time frame, Hair styling in a time frame, Hair donation – individual and team, Anatomy, Tallest, Shortest, Heaviest, Organs removed – largest/heaviest, Longest, Oldest, People, To achieve something, In a career
Examples for Journeys include: Fastest, Place to place, On foot, Non-motorised vehicles (e.g. bicycles), , Longest, Journey in a single country, Journey internationally, Motorised and non-motorised vehicles, , Lowest fuel consumption, Place to place, Petrol, Diesel, Battery power, , Greatest distance (Motorised and non-motorised – must be undertaken on a closed racetrack), In 12 hours, In 24 hours, In 48 hours, Greatest vertical distance, In 12 hours, In 24 hours, In 48 hours, Highest altitude on land, Defined activity, Defined permanent structure, Deepest, Defined activity underwater, Fastest to visit all stations in an underground network' , Youngest and oldest journey
Examples for Literature, books and publishing, comics include: Longest running, Most books/issues in a series, Most prolific author, artist, Most syndicated, Most translated, Most published, Longest time in charts
Examples for Longest Lines include: Longest chains, Longest line of people, Performing a skill, Relay (non-federated sport), Costumed, Object to include records like longest line of surf boards, pallets etc.
Examples for Mass Participation include: Largest lessons, Largest dance lessons, Largest instructional and/or school subject lesson, Largest dances, Style/genre, Traditional/Cultural, Simultaneous performance of popular dance phenomenon, Largest gatherings, Costumed, Professional impersonators, Shared trait, Largest human image, Musical performance, Largest ensemble, Most people playing “x”, Most performances of a skill by a group, Consecutively, Simultaneously, Mass participation in x hours, Largest audience/crowds, Largest tournament (non-federated sport), Most people performing an activity simultaneously in multiple venues
Examples for Non – Sport marathon include: Longest marathon performing ‘x’ activity.
Examples for Online/social media include: Largest online photo album, Largest online video album, Largest online photo competition, Largest online video competition, Most followers, Most likes, Most retweets/flips/shares, Most [live] views, Most [archived] views, Largest online lesson, Longest online lesson, Longest stream of ‘x’
Examples for Plants include: Heaviest, Fruit, Vegetable, Nut, Largest by size, Fruit, Vegetable, Nut, Flower head, Leaf, Tallest, Tree, Plant, Productivity, Highest crop yield, Most fruit/vegetables on one plant at the same time, Most fruit/vegetables from one plant in a year, Most blooms on one plant at the same time
Examples for Product testing (endorsement) records include: Toughest/strongest, Longest lasting, Thinnest/smallest, Vehicles, Most powerful, Most capacious, Fastest
Examples for Quick Challenges include: GWR Live!, Fastest over a set distance (up to 10 km), Fastest riding ‘x’, Fastest while controlling “x”, Fastest while balancing “x”, Fastest in a “x” (position, posture, or method), Fastest to complete an activity, Fastest time to “sort” items, Fastest time to perform a task “x” times, Longest time to records [excluding marathons (under 24 hours)], Longest time performing unstable/volatile skill, Most in x time, Most times to complete an activity (individual), Most times to complete an activity (in a team), Relay (non-federated sport), Dance moves, Most items sorted in x time, Most connected in x time (LEGO, paperclips, etc.)
Examples for Science include: Published academic achievements, Most electricity generated in x time
Examples for Small stuff include: Smallest functional item, Smallest representation
Examples for Speed vehicles/stunts include: Fastest contraption, Fastest speed achieved, Fastest speed FIA
Examples for Sports include: Gym based, Exercises in a time frame:, 1 minute, 3 minutes, 1 hour, 12 hour, 24 hour, Most weight lifted:, 1 hour, 12 hour, 24 hour, Farthest distance in a time frame:, Cycled, Rowed, On a treadmill, Ski ergometer, Duration, Static hold, , Federated Sport, Longest match, Most people in a match, Largest Tournament, Largest Championship, Sports Skills, Targets hit, Completed in a time frame, Consecutive, Marathons, Fastest, Most completed, Completed in different continents, Costumes
Examples for Strength include: Heaviest weight lifted/held/pulled, Heaviest vehicle pulled, Farthest distance to pull a vehicle, Breaking blocks
Examples for Structures include: Tallest/largest structure/tower/pyramid, Tallest/largest structure/tower/pyramid in ‘x’ time
Examples for Technology include: Telecommunications records, Power plant records, Remote control toys/technology, Highest resolution image, Robotics records
Examples for Videogames include: Fastest completion (monitored through Speedrun.com), Highest score (sourced from Twin Galaxies), Challenge type – time frames, modifiers, Longest marathon", required = FALSE),
  #This will give us another column with the verb, which might give us another news line
  measurement = type_string("The measurement of the record, if applicable - e.g. biggest, longest, tallest, oldest, most people etc",required = FALSE),
  is_human_individual = type_boolean("Is the record held by an individual human being or not?",required = TRUE),
  is_doable = type_boolean("Is the record realistically achievable by a non-professional layperson?",required = TRUE)
)

#read in our prompts
original_data <- read_csv("https://github.com/Guardian-Data-Projects-Team/dataharvest_2026/raw/refs/heads/main/data/guinness_sample_data.csv")
prompts <- original_data |>
  pluck("snippet") |> 
  as.list()

#this uses the batch chat to make it cheaper to run
#https://ellmer.tidyverse.org/reference/batch_chat.html
#Since batched requests can take a long time to complete, batch_chat() requires a file path that is used to store information about the batch so you never lose any work. 
#You can either set wait = FALSE or simply interrupt the waiting process, then later, either call batch_chat() to resume where you left off or call batch_chat_completed() to see if the results are ready to retrieve.
data <- batch_chat_structured(
  chat = chat,
  prompts = prompts,
  path = "guinness-data.json", #with batch chats, you set a json file to use as a key to help you upload and retrieve the data
  type = type_guinness_record,
  include_tokens = TRUE,
  include_cost=TRUE
)

data_complete <- bind_cols(original_data,data)