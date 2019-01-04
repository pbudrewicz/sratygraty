myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num

firstDouble :: [Int] -> [Int] -> [Int]
firstDouble seen [] = []
firstDouble seen (x:xs) | elem x seen = x:[]
                        | otherwise = firstDouble (x:seen) xs

freqList :: Int -> [Int] -> [Int]
freqList n [] = n:[] -- should not happen
freqList 0 (x:[]) = x:[] -- should not happen
freqList n (x:xs) = (n+x):(freqList (n+x) xs)

main = do
  input <- getContents
  let myinput = (map myread (words input)) in 
--    putStrLn (show (foldl (\a n -> a + n ) 0 myinput ))
    putStrLn (show (firstDouble [] (freqList 0 (cycle myinput))))
