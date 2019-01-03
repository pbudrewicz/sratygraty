import qualified Data.Set as Set

myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num

firstDouble :: Set.Set Int -> [Int] -> [Int]
firstDouble seen [] = []
firstDouble seen (x:xs) | Set.member x seen = [x]
                        | otherwise = firstDouble (Set.insert x seen) xs

freqList :: Int -> [Int] -> [Int]
freqList n [] = n:[] -- should not happen
freqList 0 (x:[]) = x:[] -- should not happen
freqList n (x:xs) = (n+x):(freqList (n+x) xs)

main = do
  input <- getContents
  let myinput = (map myread (words input)) in 
--    putStrLn (show (foldl (\a n -> a + n ) 0 myinput ))
    putStrLn (show (firstDouble Set.empty (freqList 0 (cycle myinput))))
