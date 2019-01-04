-- import qualified Data.Set as Set
import Data.List

type Code = [Char]
type Codes = (Code, Code, Code, Code)
type Cnts = (Int, Int)

qualifyChar :: Codes -> Char -> Codes
qualifyChar  (a,b,c,d) x | elem x d = (a, b, c, d)
                    | elem x c = (a, b, delete x c, x:d)
                    | elem x b = (a, delete x b, x:c, d)
                    | elem x a = (delete x a, x:b, c, c)
                    | otherwise = (x:a, b, c, d)

qualifyStr :: Codes -> String -> Codes
qualifyStr c [] = c
qualifyStr c (x:xs) = qualifyChar (qualifyStr c xs) x

nonZero :: Code -> Int
nonZero [] = 0
nonZero x  = 1

countCodes :: Cnts -> [Codes] -> Cnts
countCodes (n,m) [] = (n,m)
countCodes (n,m) (id@(a,b,c,d):codes) = countCodes (n + nonZero b, m + nonZero c) codes

countCksum :: Cnts -> Int
countCksum (n,m) = n * m

sameChars :: String -> String -> String
sameChars [] _ = []
sameChars _ [] = []
sameChars (x:xs) (y:ys) | x == y = (x:sameChars xs ys)
                        | otherwise = sameChars xs ys

findMatch :: [String] -> [String]
findMatch [] = []
findMatch (x:[]) = []
findMatch (x:y:rest) | length same + 1 == length x = [same]
                     | otherwise = findMatch (x:rest)
                       where same = sameChars x y

findPair :: [String] -> [String]
findPair (x:[]) = []
findPair (x:rest) |  res == [] = findPair rest
                  |  otherwise = res
                     where res = findMatch (x:rest) 


main = do
  input <- getContents
  putStrLn ( show ( countCksum (countCodes (0,0) (map (qualifyStr ([], [], [], [])) (words input)))))
  putStrLn ( show ( findPair (words input)))
