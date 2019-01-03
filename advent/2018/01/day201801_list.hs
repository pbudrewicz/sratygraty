
myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num

keepRepeating :: Int -> [Int] -> [Int]
keepRepeating 0 x = x ++ keepRepeating 0 x
keepRepeating 1 x = x
keepRepeating n x = x ++ keepRepeating (n-1) x

firstDouble :: [Int] -> [Int] -> [Int]
firstDouble seen [] = []
firstDouble seen (x:xs) | elem x seen = [x]
                        | otherwise = firstDouble (x:seen) xs

freqList :: Int -> [Int] -> [Int]
freqList n [] = n:[] -- should not happen
freqList 0 (x:[]) = x:[] -- should not happen
freqList n (x:xs) = (n+x):(freqList (n+x) xs)

main = do
  input <- getContents
  -- putStrLn (show (foldl (\a n -> a + n ) 0 (map myread (words input))))
  -- let a=(freqList input) in putStrLn (show ( [minimum a, maximum a, length a, 0, 0, 0] ++ (firstDouble [] a ))) 
  let myinput = (map myread (words input)) in 
    putStrLn (show (firstDouble [] (freqList 0 (cycle myinput))))
