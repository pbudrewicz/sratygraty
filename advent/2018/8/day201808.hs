data Tree = Tree { children :: [Tree], meta :: [Int], len :: Int } | Empty | BadData deriving Show
-- data TreeData = TreeData { tree :: Tree, len :: Int } deriving Show
-- type Meta = [Int]


-- getTree :: TreeData -> Tree
-- getTree TreeData{ } = tree

-- getLen :: TreeData -> Int
-- getLen TreeData{ } = len

-- getChildren :: Tree -> [Tree]
-- getChildren Node( ch, _ ) = ch

-- getMeta :: Tree -> [Int] 
-- getMeta Node( _, m ) = m

makeTree :: [Int] -> Tree
makeTree [] = Empty
makeTree (0:y:xs) = Tree { children=[], meta=take y xs, len=y+2 }
makeTree (x:_:[]) = BadData
makeTree (x:y:xs) = Tree { children= firstChild:(children subTree), meta=(take y (drop treeLength xs)), len=treeLength } where 
                                                                                                                       firstChild = makeSubTree xs
                                                                                                                       subTree = makeSubTree( x-1:y:(drop (len firstChild) xs ))
                                                                                                                       treeLength = (len firstChild) + (len subTree)

makeSubTree :: [Int] -> Tree
makeSubTree [] = Empty
makeSubTree (0:y:xs) = Tree { children=[], meta=[], len=2 }
makeSubTree (x:y:xs) = Tree { children=firstChild:(children subTree), meta=(take y (drop treeLength xs)), len=treeLength } where
                                                                                                                       firstChild = makeSubTree xs
                                                                                                                       subTree = makeSubTree( x-1:y:(drop (len firstChild) xs ))
                                                                                                                       treeLength = (len firstChild) + (len subTree)

-- sumMeta :: [Int] -> Int
-- sumMeta [] = 0
-- sumMeta (0:y:xs) = sum (take y xs) 

sumMeta :: Tree -> Int
sumMeta Empty = 0
sumMeta Tree { children = [], meta=meta } = sum meta
sumMeta Tree { children = children, meta = meta } = sum meta + sum (map sumMeta children )

main = do
  input <- getLine
  putStrLn (show  (makeTree (map read (words input))))
  putStrLn (show (sumMeta (makeTree (map read (words input)))))
