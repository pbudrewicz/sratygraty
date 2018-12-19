data Tree = Node { Children :: [Node], Meta :: [Integer] } | Empty
data TreeData { t :: Tree, len :: Integer }


makeTree :: [Integer] -> TreeData
makeTree [] = TreeData ( Empty, 0 )
makeTree (0:y:xs) = Node { Children [], Meta take y xs } 
makeTree (x:y:xs) = Node { Children ,  Meta take y  

sumMeta :: [Integer] -> Integer
sumMeta [] = 0
sumMeta (0:y:xs) = sum (take y xs) 

main = do
  input <- getLine
  putStrLn show (sum (makeTree (map read (words input))))
