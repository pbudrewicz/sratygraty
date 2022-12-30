import GHC.Generics (Generic)
import System.Environment

maxCalories :: [String] -> Int -> Int -> Int
maxCalories [] c d = if c > d then c
                     else d
maxCalories (a:b) c d | a == ""   = let max = (maxCalories b 0 d)
                                    in
                                      if max > c then max
                                      else c
                      | otherwise = (maxCalories b ((read a :: Int)+c) d)

calories :: [String] -> [Int] -> [Int]
calories [] a = a
calories a [] = calories a [0]
calories (a:b) (d:e) | a == "" = d:(calories b e)
                     | otherwise =  calories b (((read a :: Int) + d):e)


insert :: Int -> [Int] -> [Int]
insert a [] = [a]
insert a (b:c) = if a > b then a:b:c
                 else b:(insert a c)



main = do args <- getArgs
          input <- getContents
          putStrLn $ show (length (lines input))
          putStrLn $ show (maxCalories (lines input) 0 0)
          putStrLn $ show (take 3 (calories (lines input) []))
          putStrLn $ show (sum (foldr (\a -> \b ->  (take 3 (insert a b))) []  (calories (lines input) [])))


--          putStr  (unlines (map (show . phrase . words) (lines input)))
