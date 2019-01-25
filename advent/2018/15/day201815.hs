import Data.Array
import Data.List
import qualified Data.Set as Set

type Pos = (Int, Int) 
type Field = Array (Int, Int) Char
data Species = Ghost | Elf | Gnome deriving (Eq, Ord)
type Distance = Int
type HitPoints = Int
type Beast = (Pos, (Species, HitPoints)) -- I'm afraid we need uniq IDs for beasts
type MapElement = (Pos, (Distance, Species))

instance Show Species where
  show Ghost = " "
  show Gnome = "G"
  show Elf = "E"

other :: Species -> Species
other s |  s == Gnome = Elf 
        |  s == Elf = Gnome
        |  otherwise = s

alive :: Species -> Bool
alive s = s == Elf || s == Gnome

specie :: Char -> Species
specie c | c == 'G' = Gnome
         | c == 'E' = Elf
         | otherwise = Ghost

dedup :: (Eq a) =>  [a] -> [a]
dedup [] = []
dedup (x:xs) | x `elem` xs = dedup xs
             | otherwise = x:(dedup xs)

removeBeasts :: Char -> Char
removeBeasts c | c == 'G' = '.'
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
                                    where beast = filter (\b -> pos == (fst b)) beasts

showBeast :: Beast -> String
showBeast (pos,(b,l)) | l == 200 = "\27[32m" ++ show b ++ "\27[0m"
                      | l > 150  = "\27[36m" ++ show b ++ "\27[0m"
                      | l > 100  = "\27[34m" ++ show b ++ "\27[0m"
                      | l > 50   = "\27[35m" ++ show b ++ "\27[0m"
                      | l > 0    = "\27[31m" ++ show b ++ "\27[0m"
                      | otherwise = show b

elves :: [Beast] -> [Beast]
elves  = filter (\b -> (fst (snd b)) == Elf) 

gnomes :: [Beast] -> [Beast]
gnomes  = filter (\b -> (fst (snd b)) == Gnome) 

beastAt :: [Beast] -> Pos -> Species -- returns beast at position or empty, if no beast
beastAt [] _ = Ghost
beastAt ((p,(b,_)):bs) pos | p == pos = b
                           | otherwise = beastAt bs pos

allBut :: [Beast] -> Beast -> [Beast]
allBut [] _ = []
allBut (b:bs) beast | b == beast = bs
                    | otherwise = b:(allBut bs beast)

maybeMove :: Field -> [Beast] -> Beast -> [Beast]
maybeMove field beasts beast@(pos,(species,l)) | nextMove == [] = beasts
                                         | tgts /= [] && isInRange (fst (head tgts)) pos = beasts
                                         | otherwise = ((head nextMove),(species,l)):(allBut beasts beast)
                                             where tgts = getTargets field beasts pos (other species) 
                                                   nextMove = chooseStep field beasts beast tgts

maybeAttack :: Field -> [Beast] -> Beast -> [Beast]
maybeAttack field beasts beast = beasts

-- scanField :: Field -> Pos -> [(Int,Pos)]
-- scanField field pos = 

adjacent = [(-1,0),(0,-1),(0,1),(1,0)] :: [Pos]

chooseStep :: Field -> [Beast] -> Beast -> [MapElement] -> [Pos]
chooseStep field beasts beast@((r,c),(b,_)) tgts | tgts == [] = []
                                                 | otherwise = [snd( head (sort ((map (\(pos,(d,_)) -> (d,pos))  (filter (\n -> isInRange (r,c) (fst n)) (neighborList field beasts (head tgts) ))))))]

neighborList :: Field -> [Beast] -> MapElement -> [MapElement]
neighborList field beasts s@(start,(_,_)) = neighborList' field (filter (\b -> (fst b) /= start) beasts) [] [s]

neighborList' :: Field -> [Beast] -> [MapElement] -> [MapElement] -> [MapElement]
neighborList' field beasts neighbors fresh | nList == [] = newNeighbors
                                           | otherwise = neighborList' field beasts newNeighbors nList
                                                      where 
                                                        newNeighbors = neighbors ++ fresh
                                                        nList = dedup [((y+r,x+c),(dist+1, beastAt beasts (y+r,x+c) )) | (y,x) <- adjacent,
                                                                       ((r,c),(dist,_)) <- fresh,
                                                                       field ! (y+r,x+c) == '.',
                                                                       beastAt beasts (r,c) == Ghost,
                                                                       not ((y+r,x+c) `elem` (map fst newNeighbors)) ] -- how to start from beast position?!



showDistance :: Field -> Pos -> [Beast] -> [(Pos,Distance,Species)] -> String
showDistance field pos beasts neighbors | field ! pos == '.' && (beastAt beasts pos) == Ghost = dist
                                        | otherwise = showMapElement field pos beasts
                                           where dist = getDistance pos neighbors

getDistance :: Pos -> [(Pos,Distance,Species)] -> String
getDistance _ [] = "."
getDistance pos ((p,dist,_):rest) | pos == p = if dist < 10 then show dist else "*"
                                  | otherwise = getDistance pos rest

getTargets :: Field -> [Beast] -> Pos -> Species -> [MapElement]
getTargets field beasts start beast = filter (\b -> (snd (snd b)) == beast) (neighborList field (filter (\p -> (fst p) /= start) beasts) (start,(0,Ghost)))

showField :: (Field, (Int, Int)) -> [Beast] -> [String]
showField (field,(rows, cols)) beasts =  [ foldl  (\acc c -> acc ++ (showMapElement field (r,c) beasts)) "" [0..cols]  | r <- [0..rows] ] 

main = do
  input <- getContents
  let rows = (length (lines input)) - 1
      cols = length (head (lines input)) - 1
      myarray = array ((0,0),(rows, cols)) [((y,x), ((lines input) !! y) !! x) | y<-[0..rows], x <- [0..cols]] 
      beasts = sort [ ((y,x),(specie(myarray ! (y,x)),200))| y <-[0..rows], x<-[0..cols], alive(specie(myarray ! (y,x)))] 
--      gnomes = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'G' ] 
--      elves = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'E' ] 
      field = array((0,0),(rows, cols)) [((y,x), (removeBeasts (myarray ! (y,x)))) | y<-[0..rows], x<-[0..cols] ] 
--      neighbors = (neighborList field beasts  ((9,21),0,Ghost) )
      in putStrLn (unlines ((showField (field,(rows,cols)) beasts) ++ (map ( \b -> (show  (maybeMove field beasts b ))) beasts) ++ (showField (field,  (rows, cols)) (foldl ( \beasts beast -> maybeMove field beasts beast) beasts beasts))))
--      in putStrLn (unlines ( [ foldl  (\acc c -> acc ++ (showDistance field (r,c) beasts neighbors)) "" [0..cols]  | r <- [0..rows] ] ))
--      in putStrLn (show ( getTargets field beasts (9,25) 'E'))
--       in putStrLn (show (map (\(pos,b,_) -> getTargets field beasts pos (other b)) beasts))
--      in putStrLn (show (neighborList field beasts ((20,6),0,Ghost) ))

 --(show mytrains) ++ "\n" ++
        --(show (moveTrains tracks 0 mytrains)) ++ "\n")
-- ++   (unlines [ [ tracks ! (c,r) | c <- [0..cols] ] | r <- [0..rows] ] ))
