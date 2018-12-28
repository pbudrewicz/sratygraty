import qualified Data.Set as Set

myread :: String -> Integer
myread ('-':num) = -1 * read num 
myread ('+':num) = read num


keepRepeating :: [Integer] -> [Integer]
keepRepeating x = x ++ keepRepeating x

firstDouble :: [Integer] -> [Integer] -> [Integer]
firstDouble seen (x:xs) | elem x seen = (x:seen)
                        | otherwise = firstDouble (x:seen) xs

freqList :: String -> [Integer]
freqList input =  0 : [ x + a | (a, x) <-  zip (keepRepeating (map myread (words input))) (freqList input) ]

main = do
  input <- getContents
  putStrLn (show (foldl (\a n -> a + n ) 0 (map myread (words input))))
  putStrLn (show (firstDouble [] (freqList input)))
