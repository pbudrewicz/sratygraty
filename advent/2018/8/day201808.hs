data Tree = Node { children :: [Tree], meta :: [Int] } deriving Show
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
makeTree [] = TreeData { tree=Node { children=[], meta=[] }, len=0 }
makeTree (0:y:xs) = TreeData { tree=Node { children=[], meta=(take y xs)}, len=y } 
makeTree (x:y:xs) = TreeData { tree=Node { children=(tree firstChild):(children (tree subTree)), meta=[] }, len=(len subTree) } where 
                                                                                                                       firstChild = makeTree xs
                                                                                                                       subTree = makeTree( x-1:y:(drop (len firstChild) xs ))

-- sumMeta :: [Int] -> Int
-- sumMeta [] = 0
-- sumMeta (0:y:xs) = sum (take y xs) 

sumMeta :: Tree -> Int
sumMeta Node { children = []} = sum meta
sumMeta Node {  } = sum meta + sum (map sumMeta children )

main = do
  input <- getLine
  putStrLn show (makeTree (map read (words input)))
