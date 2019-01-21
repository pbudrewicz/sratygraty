import Data.Array
import Data.List

type Pos = (Int, Int)
type Beast = (Pos, Char, Int)

mapElement :: Char -> Char
mapElement c | c == 'G' = '.'
             | c == 'E' = '.'
             | otherwise = c

isInRange :: Pos -> Pos -> Bool
isInRange (x1,y1) (x2,y2) = (abs (x1 - x2) == 1 && y1 == y2 ) || (x1 == x2 && abs (y1 - y2) == 1)

moveUnits :: Int -> Array (Int,Int) Char -> [Beast] -> [Beast]
moveUnits round field (u:us) = afterTurn:moveUnits round afterTurn us
                              where afterTurn = (maybeAttack (maybeMove field u) u)

maybeMove :: Array (Int,Int) Char -> Beast -> [Beast]
maybeMove field unit = isInRange.... [ b | x <- rows...  blabla.... 

main = do
  input <- getContents
  let rows = (length (lines input)) - 1
      cols = length (head (lines input)) - 1
      myarray = array ((0,0),(cols, rows)) [((x,y), ((lines input) !! y) !! x) | x<-[0..cols], y<-[0..rows]] 
      beasts = sort [ ((x,y),t,3)| x <-[0..cols], y<-[0..rows], t <- ['E','G'], (myarray ! (x,y)) == t ] 
      gnomes = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'G' ] 
      elves = sort [ ((x,y),3)| x <-[0..cols], y<-[0..rows], (myarray ! (x,y)) == 'E' ] 
      field = array((0,0),(cols, rows)) [((x,y), (mapElement (myarray ! (x,y)))) | x<-[0..cols], y<-[0..rows] ] 
      in putStrLn (unlines ((map show [gnomes, elves]) ++ [(show beasts)] ++ [ [field ! (c,r) | c <- [0..cols] ] | r <- [0..rows] ] ))

 --(show mytrains) ++ "\n" ++
        --(show (moveTrains tracks 0 mytrains)) ++ "\n")
-- ++   (unlines [ [ tracks ! (c,r) | c <- [0..cols] ] | r <- [0..rows] ] ))
