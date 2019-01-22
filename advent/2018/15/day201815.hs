import Data.Array
import Data.List
import qualified Data.Set as Set

type Pos = (Int, Int)
type Beast = (Pos, Char, Int)
type Field = Array (Int, Int) Char

dedup :: (Eq a) =>  [a] -> [a]
dedup [] = []
dedup (x:xs) | x `elem` xs = dedup xs
             | otherwise = x:(dedup xs)

cleanMap :: Char -> Char
cleanMap c | c == 'G' = '.'
           | c == 'E' = '.'
           | otherwise = c

isInRange :: Pos -> Pos -> Bool
isInRange (y1,x1) (y2,x2) = (abs (x1 - x2) == 1 && y1 == y2 ) || (x1 == x2 && abs (y1 - y2) == 1)

-- moveUnits :: Int -> Field -> [Beast] -> [Beast]
-- moveUnits round field (u:us) = afterTurn:moveUnits round afterTurn us
--                                 where afterTurn = (maybeAttack (maybeMove field u) u)

showMapElement :: Field -> Pos  -> [Beast] -> String
showMapElement field pos beasts | beast == [] = [field ! pos]
                                | otherwise = showBeast (head beast)
                                    where beast = filter (\(bpos,_,_) -> pos == bpos) beasts

showBeast :: Beast -> String
showBeast (pos,c,l) | l == 200 = "\27[32m" ++ [c] ++ "\27[0m"
                    | l > 150  = "\27[36m" ++ [c] ++ "\27[0m"
                    | l > 100  = "\27[34m" ++ [c] ++ "\27[0m"
                    | l > 50   = "\27[35m" ++ [c] ++ "\27[0m"
                    | l > 0    = "\27[31m" ++ [c] ++ "\27[0m"
                    | otherwise = [c]

elves :: [Beast] -> [Beast]
elves  = filter (\(_,b,_) -> b == 'E') 

gnomes :: [Beast] -> [Beast]
gnomes  = filter (\(_,b,_) -> b == 'G') 

beastAt :: [Beast] -> Pos -> Char -- returns beast at position or empty, if no beast
beastAt [] _ = ' '
beastAt ((p,b,_):bs) pos | p == pos = b
                         | otherwise = beastAt bs pos

-- maybeMove :: Field -> Beast -> [Beast]
-- maybeMove field unit = isInRange.... [ b | x <- rows...  blabla....

-- scanField :: Field -> Pos -> [(Int,Pos)]
-- scanField field pos = 

neighborList :: Field -> [Beast] -> [(Pos,Int,Char)] -> [(Pos,Int,Char)] -> [(Pos,Int,Char)]
neighborList field beasts neighbors fresh | nList == [] = newNeighbors
                                          | otherwise = neighborList field beasts newNeighbors nList
                                                      where 
                                                        newNeighbors = neighbors ++ fresh
                                                        nList = dedup [((y+r,x+c),dist+1, beastAt beasts (y+r,x+c) ) | (y,x) <- [(-1,0),(0,-1),(0,1),(1,0)], ((r,c),dist,_) <- fresh, field ! (y+r,x+c) == '.' &&  beastAt beasts (r,c) == ' ' && not ((y+r,x+c) `elem` (map (\(a,b,c) -> a) newNeighbors)) ]

showDistance :: Field -> Pos -> [Beast] -> [(Pos,Int,Char)] -> String
showDistance field pos beasts neighbors | field ! pos == '.' && (beastAt beasts pos) == ' ' = dist
                                        | otherwise = showMapElement field pos beasts
                                           where dist = getDistance pos neighbors

getDistance :: Pos -> [(Pos,Int,Char)] -> String
getDistance _ [] = "."
getDistance pos ((p,dist,_):rest) | pos == p = if dist < 10 then show dist else "*"
                                | otherwise = getDistance pos rest

getTarget :: Field -> [Beast] -> Pos -> Char -> (Pos,Int,Char)
getTarget field beasts start beast = (head (filter (\(p,d,b) -> b == beast) (neighborList field beasts [] [(start,0,'.')])))

main = do
  input <- getContents
  let rows = (length (lines input)) - 1
      cols = length (head (lines input)) - 1
      myarray = array ((0,0),(rows, cols)) [((y,x), ((lines input) !! y) !! x) | y<-[0..rows], x <- [0..cols]] 
      beasts = sort [ ((y,x),t,200)| y <-[0..rows], x<-[0..cols], t <- ['E','G'], (myarray ! (y,x)) == t ] 
--      gnomes = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'G' ] 
--      elves = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'E' ] 
      field = array((0,0),(rows, cols)) [((y,x), (cleanMap (myarray ! (y,x)))) | y<-[0..rows], x<-[0..cols] ] 
      neighbors = (neighborList field beasts [] [((9,21),0,'.')] )
      --in putStrLn (unlines ( [ foldl  (\acc c -> acc ++ (showMapElement field (c,r) beasts)) "" [0..cols]  | r <- [0..rows] ] ))
--      in putStrLn (unlines ( [ foldl  (\acc c -> acc ++ (showDistance field (r,c) beasts neighbors)) "" [0..cols]  | r <- [0..rows] ] ))
      in putStrLn (show (getTarget field beasts (9,21) 'E'))
--      in putStrLn (show (neighborList field beasts [] [((20,6),0,'.')] ))

 --(show mytrains) ++ "\n" ++
        --(show (moveTrains tracks 0 mytrains)) ++ "\n")
-- ++   (unlines [ [ tracks ! (c,r) | c <- [0..cols] ] | r <- [0..rows] ] ))
