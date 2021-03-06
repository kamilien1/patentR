# test cleaning data


# clean names 
test_that("Imported Sumobrain csv to data frame has names standardized",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  expect_identical(names(df),names(acars))
  
})


# same length when extracting country code
test_that("Country code extracted from document number, and all country codes are chars of length 2-4",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  expect_length(extractCountryCode(df$docNum),dim(df)[1])
})

# same length when extracting publication number
test_that("Publication number, numeric portion extracted from document number properly",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  # should return the same length
  expect_length(extractPubNumber(df$docNum),dim(df)[1])
})


# same length when extracting kind code
test_that("Kind code extracted returns same length as number of rows of data frame",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  # should return the same length
  expect_length(extractKindCode(df$docNum),dim(df)[1])
})


# same length when extracting kind code
test_that("Office doc length extracted returns same length as number of rows of data frame",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  df$pubName <- extractPubNumber(df$docNum)
  df$countryCode <- extractCountryCode(df$docNum)
  df$officeDocLength <- extractDocLength(countryCode = df$countryCode, pubNum = df$pubNum)
  # should return the same length
  expect_length(df$officeDocLength ,dim(df)[1])
})


# Dates converted properly
test_that("Dates converted properly from characters",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  df$pubDate <- extractCleanDate(df$pubDate)
  # should return the same length
  expect_equal(inherits(df$pubDate, "Date") ,TRUE)
})

# same length when extracting kind code
test_that("Google URL vector returns same length as number of rows of data frame",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  df$pubNum <- extractPubNumber(df$docNum)
  df$countryCode <- extractCountryCode(df$docNum)
  df$kindCode <- extractKindCode(df$docNum)
  # should return the same length
  expect_length(createGoogleURL(countryCode = df$countryCode, 
                                pubNum = df$pubNum, 
                                kindCode =df$kindCode) ,dim(df)[1])
})


# duplicates are removed if exist
test_that("Removing dups is a logical vector",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  # should be of type logical
  expect_type(removeDups(df$docNum) ,"logical")
})


# duplicates are shown
test_that("Showing all duplicates and showDups is a logical vector",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  # should be of type logical
  expect_type(showDups(df$appNum) ,"logical")
})


# same length when generating the type of document
test_that("generateDocType returns same length as number of rows of data frame",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  df$pubNum <- extractPubNumber(df$docNum)
  df$countryCode <- extractCountryCode(df$docNum)
  df$kindCode <- extractKindCode(df$docNum)
  df$officeDocLength <- extractDocLength(countryCode = df$countryCode, pubNum = df$pubNum)
  df$countryAndKindCode <- with(df, paste0(countryCode, kindCode))
  # should return the same length
  temp <- generateDocType(officeDocLength = df$officeDocLength,
                          countryAndKindCode = df$countryAndKindCode,
                          cakcDict = patentr::cakcDict,
                          docLengthTypesDict = patentr::docLengthTypesDict)
  expect_length(temp ,dim(df)[1])
})



# names returns the same length
test_that("Google URL vector returns same length as number of rows of data frame",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = 1)
  df <- cleanHeaderNames(patentData = df)
  expect_length(cleanNames(df$assignee), dim(df)[1])
})


# sumobrain full clean returns data frame
test_that("Sumobrain data cleanPatentData returns a data frame.",{
  df <- importPatentData(rprojroot::find_testthat_root_file("testData","sumobrain_autonomous_search1.xlsx"), skipLines = skipSumobrain)
  df <- cleanPatentData(patentData = df, columnsExpected = sumobrainColumns,
                        cleanNames = sumobrainNames, dateFields = sumobrainDateFields,
                        dateOrders = sumobrainDateOrder, deduplicate = TRUE,
                        cakcDict = cakcDict, docLengthTypesDict = docLengthTypesDict,
                        keepType = "grant",firstAssigneeOnly = TRUE, assigneeSep = ";",
                        stopWords = assigneeStopWords)
  # should be of type logical
  expect_is(df ,"data.frame")
})

# google patent data full clean returns data frame
test_that("Google patent data cleanPatentData returns a data frame.",{
  df <- read.csv(rprojroot::find_testthat_root_file("testData","google_autonomous_search.csv"), 
                 skip = skipGoogle, stringsAsFactors = FALSE)
  df <- data.frame(lapply(df,function(x){iconv(x, to = "ASCII")}), stringsAsFactors = FALSE)
  
  df <- cleanPatentData(patentData = df, columnsExpected = googleColumns,
                        cleanNames = googleNames, dateFields = googleDateFields,
                        dateOrders = googleDateOrder, deduplicate = TRUE,
                        cakcDict = cakcDict, docLengthTypesDict = docLengthTypesDict,
                        keepType = "grant",firstAssigneeOnly = TRUE, assigneeSep = ",",
                        stopWords = assigneeStopWords)
  # should be of type logical
  expect_is(df ,"data.frame")
})


# lens.org data file 
test_that("Lens.org patent data cleanPatentData returns a data frame.",{
  df <- read.csv(rprojroot::find_testthat_root_file("testData","lens_autonomous_search.csv"), 
                 skip = skipLens, stringsAsFactors = FALSE)
  df <- data.frame(lapply(df,function(x){iconv(x, to = "ASCII")}), stringsAsFactors = FALSE)
  
  df <- cleanPatentData(patentData = df, columnsExpected = lensColumns,
                        cleanNames = lensNames, dateFields = lensDateFields,
                        dateOrders = lensDateOrder, deduplicate = TRUE,
                        cakcDict = cakcDict, docLengthTypesDict = docLengthTypesDict,
                        keepType = "grant",firstAssigneeOnly = TRUE, assigneeSep = ";;",
                        stopWords = assigneeStopWords)
  # should be of type logical
  expect_is(df ,"data.frame")
})

