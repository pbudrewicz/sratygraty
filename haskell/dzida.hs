data Dzida = Przed | Srod | Za deriving (Show)

-- instance Show ( Dzida ) where 
  -- show Przed = "przed"
  -- show Srod = "srod"
  -- show Za = "za"

part_names = [ "przed", "srod", "za" ]

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

dzid :: Int -> [[String]] -- handle enumerated recursion for expansion
dzid 0 = [[]]
dzid l = unroll ( dzid  ( l-1 ) )

dzida :: Int -> String -- get name of dzida's parts expanded numbered time
dzida l = join ".\n" (map (\x -> (nominative x) ++ " sklada sie z " ++ join ", " (map (genitive) (unroll  [x]))) (dzid l)) ++ ".\n"

main = do
  putStr ( concat ( map (\l -> dzida l ++ "\n" ) [0..] ))

