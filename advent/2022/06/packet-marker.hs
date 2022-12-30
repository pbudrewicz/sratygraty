import GHC.Generics (Generic)
import System.Environment


member :: (Eq a) => a -> [a] -> Bool
member _ [] = False
member a (x:xs) = (a == x) || (member a xs)

unique :: (Eq a) => [a] -> [a]
unique [] = []
unique (x:xs) | member x xs = unique xs
              | otherwise = x:(unique xs)


getSOPM :: [Char] -> [Char] -> Int -> (Int, [Char])
getSOPM s [] n = (n, s)
getSOPM [] (x:xs) n = getSOPM [x] xs 1
getSOPM (s:ss) (x:xs) n | length (unique (s:ss)) == 14 = (n, s:ss)
                        | length (s:ss) < 14 = getSOPM ((s:ss) ++ [x]) xs (n+1)
                        | otherwise = getSOPM ((ss) ++ [x]) xs (n+1)



main = do
  args <- getArgs
  input <- getContents
  let num = getSOPM [] input 1
    in putStrLn $ show num
