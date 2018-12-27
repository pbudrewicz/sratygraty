data Tree = Node { children :: [Tree], meta :: [Int], len :: Int } | Empty | BadData deriving Show
data TreeData = TreeData { tree :: Tree, len :: Int } deriving Show
-- type Meta = [Int]


-- getTree :: TreeData -> Tree
-- getTree TreeData{ } = tree

-- getLen :: TreeData -> Int
-- getLen TreeData{ } = len

-- getChildren :: Tree -> [Tree]
-- getChildren Node( ch, _ ) = ch

-- getMeta :: Tree -> [Int] 
-- getMeta Node( _, m ) = m

makeTree :: [Int] -> TreeData
makeTree [] = TreeData { tree=Empty, len=0 }
makeTree (0:y:xs) = TreeData { tree=Node { children=[], meta=(take y xs)}, len=y+2 }
makeTree (x:_:[]) = TreeData { tree=BadData, len=2 }
makeTree (x:y:xs) = TreeData { tree=Node { children=(tree firstChild):(children (tree subTree)), meta=(take y (drop length xs)) }, len=length } where 
                                                                                                                       firstChild = makeTree xs
                                                                                                                       subTree = makeTree( x-1:y:(drop (len firstChild) xs ))
                                                                                                                       length = (len firstChild) + (len subTree)

-- makeSubTree :: [Int] -> [TreeData]

-- sumMeta :: [Int] -> Int
-- sumMeta [] = 0
-- sumMeta (0:y:xs) = sum (take y xs) 

sumMeta :: Tree -> Int
sumMeta Empty = 0
sumMeta Node { children = [], meta=meta } = sum meta
sumMeta Node { children = children, meta = meta } = sum meta + sum (map sumMeta children )

main = do
  input <- getLine
  putStrLn (show  (makeTree (map read (words input))))
  putStrLn (show (sumMeta (tree (makeTree (map read (words input))))))
