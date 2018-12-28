import qualified Data.Set as Set

myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num


keepRepeating :: [Int] -> [Int]
keepRepeating x = x ++ keepRepeating x

firstDouble :: [Int] -> [Int] -> Int
firstDouble seen (x:xs) | elem x seen = x
                        | otherwise = firstDouble (x:seen) xs

freqList :: String -> [Int]
freqList input =  0 : [ x + a | (a, x) <-  zip (keepRepeating (map myread (words input))) (freqList input) ]

main = do
  input <- getContents
  putStrLn (show (foldl (\a n -> a + n ) 0 (map myread (words input))))
  putStrLn (show (firstDouble [] (freqList input)))
