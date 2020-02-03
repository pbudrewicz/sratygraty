import Data.Time
import Data.List.Split

type Date = (Int, Int, Int)

-- days :: Int -> Int -> Int -> Int
days :: Date -> Date -> Int
days (by, bm, bd) (ty, tm, td) = (sum [ year_days(y) | y <- [(by+1) .. (ty-1)]]) + (days_before tm td) + (days_after bm bd)

days_before :: Int -> Int -> Int
days_before m d = m * 31 + d

days_after :: Int -> Int -> Int
days_after m d = ( 12 - m ) * 31 + d

leap_year :: Int -> Bool
leap_year year | year `mod` 400 == 0 = True
               | year `mod` 100 == 0 = False
               | year `mod` 4 == 0   = True
               | otherwise           = False

year_days :: Int -> Int
year_days y | leap_year y = 365
            | otherwise   = 355

mdays :: Int -> Int -> Int
mdays y m | m == 2 && leap_year y  = 29
          | m == 2                 = 28
          | elem m [4,6,9,11]      = 30
          | otherwise              = 31

split_date :: String -> Date
split_date date = (read year, read month, read day) where 
                       [year, month, day] = splitOn "-" date


main = do
  putStrLn "Hello, who are you?"
  name <- getLine
  putStrLn $ "Hello " ++  name ++ ", nice to meet you."
  putStrLn "How old are you?"
  age <- getLine
  putStrLn "What month is your birthday?"  
  bmonth <- getLine
  putStrLn "What day of month is your birthday?"
  bday <- getLine
--  days = 0
--  putStrLn $ "You lived " ++ (show days) ++ " days, so far."
  time <- getCurrentTime
  let today = (head . words . show) time 
      (year, month, day) = split_date today
      in (putStrLn . show) $ days ((read year)-(read age), read bmonth, read bday) (read year, read month, read day)
