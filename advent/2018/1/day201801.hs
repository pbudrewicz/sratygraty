myread :: String -> Int
myread ('-':num) = -1 * read num 
myread ('+':num) = read num


main = do
  input <- getContents
  putStrLn (show (map myread (words input)  ))
  putStrLn (show (foldl (\a n -> a + n ) 0 (map myread (words input))))
