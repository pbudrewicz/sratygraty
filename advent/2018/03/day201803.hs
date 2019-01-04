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
                       row = (replace x (id:((amap !! y) !! x)) (amap !! y)) 

addRegToMap :: Map -> RegDef -> Map
-- addRegToMap amap (id,left,top,width,height) = insertMap (left+1) (top+1) id amap
addRegToMap amap (id,left,top,width,height) = foldl (\m (x,y) -> insertMap x y id m) amap [ (a,b) | a <- [(left+1) .. (left+width)], b <- [(top+1) .. (top + height)] ]

addTestToMap :: Map -> [(Int,Int)] -> Map
addTestToMap amap list = foldl (\m (x,y) -> insertMap x y 1 m) amap list -- [(1,2),(2,1)] -- [(1,1),(1,2),(2,1),(2,2),(3,3),(5,5)]

emptyMap = (replicate 8 ( replicate 8 [] ) )

main = do
  input <- getContents
  putStrLn (showMap (addTestToMap emptyMap [(3,2),(2,3)] ))
  putStrLn (showMap (addTestToMap emptyMap [(2,3),(3,2)] ))
  let myinput = map words (lines input)
      mydefs  = map readRegDef myinput
      amap = (foldl addRegToMap emptyMap (map readRegDef (map words (lines input)))) in 
        putStrLn (showMap amap)
--      putStrLn (showMap amap)
      --putStrLn (show (map readRegDef myinput))

