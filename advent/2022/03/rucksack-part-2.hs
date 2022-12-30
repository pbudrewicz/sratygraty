import GHC.Generics (Generic)
import System.Environment
import Data.Char

priority :: Char -> Int
priority a | isLower(a) = ord(a) - ord('a') + 1
           | otherwise = ord(a) - ord('A') + 27

member :: Char -> String -> Bool
member _ [] = False
member a (x:xs) = (a == x) || (member a xs)

compRucksacks :: (String, String, String) -> Char
compRucksacks ((a:as), b, c) | (member a b) && (member a c) = a
                             | otherwise = compRucksacks (as,b,c)
compRucksacks _ = '0'

-- getRucksackPriority :: String -> Int
-- getRucksackPriority x = let s = (length x) `div` 2
--                             c = compRucksacks (take s x) (drop s x)
--                         in priority c


triplets :: [String] -> [(String, String, String)]
triplets [] = []
triplets (x:y:z:rest) = (x,y,z):(triplets rest)


main = do args <- getArgs
          input <- getContents
          putStrLn $ show $ sum (map (\l -> (priority (compRucksacks l))) (triplets (lines input)))
