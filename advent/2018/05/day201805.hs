import Data.Char

reduce :: String -> String
reduce []                                                 = []
reduce (x:[])                                             = [x]
reduce (x:y:rest) | isLower(y) && x == toUpper(y)         = reduce rest
                  | isUpper(y) && x == toLower(y)         = reduce rest
                  | otherwise                             = x:reduce (y:rest)

reduct :: String -> String
reduct [] = []
reduct x | x == reduce x                = x 
         | otherwise                    = reduct (reduce x)


testunit :: Char -> String -> String
testunit x poly = reduct [ y | y <- poly, toUpper(y) /= toUpper(x) ]

findbest :: String -> Int
findbest poly = minimum [ length ( testunit u poly ) | u <- ['a'..'z'] ]


main = do
polymer <- getLine
putStrLn ( show (findbest polymer ) )

