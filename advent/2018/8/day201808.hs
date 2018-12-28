data Tree = Tree { children :: [Tree], meta :: [Int], len :: Int } | Empty | BadData deriving Show

makeTree :: [Int] -> Tree
makeTree [] = Empty
makeTree (0:y:xs) = Tree { children=[], meta=take y xs, len=y+2 }
makeTree (x:_:[]) = BadData
makeTree (x:y:xs) = Tree { children=subTree, meta=(take y (drop treeLength xs)), len=treeLength+2+y } where 
                                                                                                       subTree = makeChildren(x:xs)
                                                                                                       treeLength = sum  (map len subTree)

makeChildren :: [Int] -> [Tree]
makeChildren [] = []
makeChildren (0:xs) = []
makeChildren (x:xs) = firstChild:subTree where
                                            firstChild = makeTree xs
                                            subTree = makeChildren( x-1:(drop (len firstChild) xs))

sumMeta :: Tree -> Int
sumMeta Empty = 0
sumMeta Tree { children = [], meta=meta } = sum meta
sumMeta Tree { children = children, meta = meta } =  sum (map (\m -> element m children)  meta )

element :: Int -> [Tree] -> Int
element 0 _ = 0
element _ [] = 0
element 1 (x:xs) = sumMeta x 
element n (x:xs) = element (n-1) xs

main = do
  input <- getLine
  putStrLn (show  (makeTree (map read (words input))))
  putStrLn (show (sumMeta (makeTree (map read (words input)))))
