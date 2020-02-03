
import System.Environment

data Dzida = Przed | Srod | Za deriving (Show)

-- instance Show ( Dzida ) where 
  -- show Przed = "przed"
  -- show Srod = "srod"
  -- show Za = "za"

part_names = [ "przed", "śród", "za" ]

nominative :: [String] -> String     -- "za" -> "zadzidzie"
nominative [] = "dzida"
nominative (p:[]) = p ++ "dzidzie" 
nominative (p:ps) = p ++ "dzidzie " ++ genitive ps

genitive :: [String] -> String  -- "za" -> "zadzidzia"
genitive xs = join " " (map (++ "dzidzia") xs)

join :: String -> [String] -> String -- join list using delimiter
join d [] = ""
join d (x:[]) = x
join d (x:xs) = x ++ d ++ (join d xs)

unroll :: [[String]] -> [[String]] -- expand one level of parts
unroll [] = []
unroll [[]] = [[x] | x <- part_names] 
unroll (x:xs) = [ y:x   | y <- part_names ] ++ unroll xs

dzida :: Int -> [[String]] -- handle enumerated recursion for expansion of abstract type
dzida 0 = [[]]
dzida l = unroll ( dzida  ( l-1 ) )

name_dzida :: Int -> String -- get name of dzida's parts expanded number of times as a description string
name_dzida l = join ".\n" (map (\x -> (nominative x) ++ " sklada sie z " ++ join ", " (map (genitive) (unroll  [x]))) (dzida l)) ++ ".\n"

describe :: [String] -> String -- describe dzida up to x levels (or infinite when empty)
describe [] =  concat ( map (\l -> name_dzida l ++ "\n" ) [0..] )
describe (x:xs)  = concat ( map (\l -> name_dzida l ++ "\n" ) [0..(read x)] )

main = do a <- getArgs ; putStr ( describe a )

