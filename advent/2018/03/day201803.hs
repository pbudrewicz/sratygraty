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
                       row = (replace x (id:((amap !! (y-1)) !! (x-1))) (amap !! (y-1))) 

addRegToMap :: Map -> RegDef -> Map
addRegToMap amap (id,left,top,width,height) = foldl (\m (x,y) -> insertMap x y id m) amap [ (a,b) | a <- [(left+1) .. (left+width)], b <- [(top+1) .. (top + height)] ]

emptyMap = (replicate 8 ( replicate 8 [] ) )

calcMulti :: Map -> Int
calcMulti m = foldl (\cnt r -> cnt + foldl (\a c -> if length c > 1 then a+1 else a) 0 r) 0 m

main = do
  input <- getContents
  let myinput = map words (lines input)
      mydefs  = map readRegDef myinput
      amap = (foldl addRegToMap emptyMap (map readRegDef (map words (lines input)))) in 
        putStrLn (show (calcMulti amap))
--      putStrLn (showMap amap)
      --putStrLn (show (map readRegDef myinput))

