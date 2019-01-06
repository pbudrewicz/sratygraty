type Id = Int
type RegDef = (Id, Int, Int, Int, Int)
type MapSpot = [Id]
type MapRow = [MapSpot]
type Map = [MapRow] -- this is two dimensional array of region id lists. 

showRegDef :: RegDef -> String
showRegDef (a, b, c, d, e) = "(#" ++ show a ++ ", " ++ show b ++ ", " ++ show c ++ ", " ++ show d ++ ", " ++ show e ++ ")"

readRegDef :: [String] -> RegDef
readRegDef [a,b,c,d,e] = (read a,read b,read c,read d,read e)
readRegDef _ = (-1,-1,-1,-1,-1)

ptInReg :: (Int,Int) -> RegDef -> Bool
ptInReg (x,y) (i,l,t,w,h) = x > l && x <= (l+w) && y > t && y <= (t+h)

countMulti :: [RegDef] -> Int
countMulti defs = length [ (x,y) | x <- [1..1000], y <- [1..1000], let regs = foldl (\cnt reg -> if ptInReg (x,y) reg then cnt+1 else cnt) 0 defs, regs > 0 ]

getMulti :: [RegDef] -> [Id]
getMulti defs = concat [ regs | x <- [1..1000], y <- [1..1000], let regs = foldl (\regs reg@(i,l,t,w,h) -> if ptInReg (x,y) reg then i:regs else regs) [] defs, length regs > 1 ]

remove :: Id -> [Id] -> [Id]
remove i [] = []
remove i (x:xs) | i == x = remove i xs
                | otherwise = x:(remove i xs)

findNonOverlapping :: [Id] -> [Id] -> [Id]
findNonOverlapping ids [] = ids
findNonOverlapping ids (x:xs) = findNonOverlapping (remove x ids) xs

-- GARBAGE BELOW

replace :: Int -> a -> [a] -> [a]
replace n c xs = take (n-1) xs ++ [c] ++ drop n xs

showRow :: [MapSpot] -> String
showRow [] = "\n"
showRow (x:[]) = show( x ) ++ "\n"
showRow (x:xs) = show( x ) ++ ":" ++ showRow xs


showMap :: Map -> String
showMap [] = ""
showMap (x:xs) = showRow x ++ showMap xs

insertMap :: Int -> Int -> Id -> Map -> Map
insertMap x y id amap = replace y row amap where
                       row = (replace x (id:((amap !! (y-1)) !! (x-1))) (amap !! (y-1))) 

addRegToMap :: Map -> RegDef -> Map
addRegToMap amap (id,left,top,width,height) = foldl (\m (x,y) -> insertMap x y id m) amap [ (a,b) | a <- [(left+1) .. (left+width)], b <- [(top+1) .. (top + height)] ]

emptyMap = (replicate 1000 ( replicate 1000 [] ) )

calcMulti :: Map -> Int
calcMulti m = foldl (\cnt r -> cnt + foldl (\a c -> if length c > 1 then a+1 else a) 0 r) 0 m

-- END OF GARBAGE

main = do
  input <- getContents
  let myinput = map words (lines input)
      mydefs  = map readRegDef myinput in
      putStrLn (show (findNonOverlapping [1..1381] (getMulti mydefs)))
--      putStrLn (show (countMulti mydefs))
--      amap = (foldl addRegToMap emptyMap (map readRegDef (map words (lines input)))) in 
        --putStrLn (show (calcMulti amap))


--      putStrLn (showMap amap)
      --putStrLn (show (map readRegDef myinput))
