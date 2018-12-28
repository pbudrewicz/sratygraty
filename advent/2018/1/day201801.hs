import qualified Data.Set as Set

myread :: String -> Integer
myread ('-':num) = -1 * read num 
myread ('+':num) = read num


keepRepeating :: [Integer] -> [Integer]
keepRepeating x = x ++ keepRepeating x

firstDouble :: Set.Set Integer -> [Integer] -> [Integer]
firstDouble seen (x:xs) | Set.member x seen = x:(Set.toList seen)
                        | otherwise = firstDouble (Set.insert x seen) xs

freqList :: String -> [Integer]
freqList input =  0 : [ x + a | (a, x) <-  zip (keepRepeating (map myread (words input))) (freqList input) ]

main = do
  input <- getContents
  putStrLn (show (foldl (\a n -> a + n ) 0 (map myread (words input))))
  putStrLn (show (firstDouble Set.empty (freqList input)))
