import qualified Data.Set as Set

myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num


keepRepeating :: Int -> [Int] -> [Int]
keepRepeating 0 x = x ++ keepRepeating 0 x
keepRepeating 1 x = x 
keepRepeating n x = x ++ keepRepeating (n-1) x

firstDouble :: Set.Set Int -> [Int] -> [Int]
firstDouble seen [] = []
firstDouble seen (x:xs) | Set.member x seen = [x]
                        | otherwise = firstDouble (Set.insert x seen) xs

freqList :: [Int] -> [Int]
freqList input =  0 : [ x + a | (a, x) <-  zip (keepRepeating 0 input) (freqList input) ]

main = do
  input <- getContents
  let myinput = (map myread (words input)) in 
--    putStrLn (show (foldl (\a n -> a + n ) 0 myinput ))
    putStrLn (show (firstDouble Set.empty (freqList myinput)))
