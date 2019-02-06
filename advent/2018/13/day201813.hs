import Data.Array
import Data.List

type Train = ((Int, Int), Char, Int)

mapElement :: Array (Int,Int) Char -> (Int, Int) -> Char
mapElement mymap pos | c == 'v' || c == '^' = '|'
                     | c == '>' || c == '<' = '-'
                     | otherwise = c
                       where c = mymap ! pos 



nextPos :: Array (Int, Int) Char -> Int -> Train -> Train
nextPos tracks tick (pos@(x,y),t,turn) | t == '^' && tracks ! (x,y-1) == '|' = ((x,y-1),'^',turn)
                                       | t == '^' && tracks ! (x,y-1) == '\\' = ((x,y-1),'<',turn)
                                       | t == '^' && tracks ! (x,y-1) == '/' = ((x,y-1),'>',turn)
                                       | t == '^' && tracks ! (x,y-1) == '+' = ((x,y-1),doTurn turn t, (turn + 1) `mod` 3)
                                       | t == '>' && tracks ! (x+1,y) == '-' = ((x+1,y),'>',turn)
                                       | t == '>' && tracks ! (x+1,y) == '/' = ((x+1,y),'^',turn)
                                       | t == '>' && tracks ! (x+1,y) == '\\' = ((x+1,y),'v',turn)
                                       | t == '>' && tracks ! (x+1,y) == '+' = ((x+1,y),doTurn turn t, (turn + 1) `mod` 3)
                                       | t == 'v' && tracks ! (x,y+1) == '|' = ((x,y+1),'v',turn)
                                       | t == 'v' && tracks ! (x,y+1) == '/' = ((x,y+1),'<',turn)
                                       | t == 'v' && tracks ! (x,y+1) == '\\' = ((x,y+1),'>',turn)
                                       | t == 'v' && tracks ! (x,y+1) == '+' = ((x,y+1),doTurn turn t, (turn + 1) `mod` 3)
                                       | t == '<' && tracks ! (x-1,y) == '-' = ((x-1,y),'<',turn)
                                       | t == '<' && tracks ! (x-1,y) == '/' = ((x-1,y),'v',turn)
                                       | t == '<' && tracks ! (x-1,y) == '\\' = ((x-1,y),'^',turn)
                                       | t == '<' && tracks ! (x-1,y) == '+' = ((x-1,y),doTurn turn t, (turn + 1) `mod` 3)
                                       | otherwise = ((x,y), '?', -1)

doTurn :: Int -> Char -> Char
doTurn turn train | turn == 0 && train == '^' = '<'
                  | turn == 1 && train == '^' = '^'
                  | turn == 2 && train == '^' = '>'
                  | turn == 0 && train == '>' = '^'
                  | turn == 1 && train == '>' = '>'
                  | turn == 2 && train == '>' = 'v'
                  | turn == 0 && train == 'v' = '>'
                  | turn == 1 && train == 'v' = 'v'
                  | turn == 2 && train == 'v' = '<'
                  | turn == 0 && train == '<' = 'v'
                  | turn == 1 && train == '<' = '<'
                  | turn == 2 && train == '<' = '^'

moveTrains :: Array (Int, Int) Char -> Int -> [Train] -> [Train] -> [Train]
moveTrains _ _ moved [] = moved
moveTrains tracks tick moved (t@(pos,_,_):ts) | crash tm (moved ++ ts) = moveTrains tracks tick (removeCrashed mpos moved) (removeCrashed mpos ts)
                                              | otherwise = moveTrains tracks tick (tm:moved) ts
                                                where tm@(mpos,_,_) = (nextPos tracks tick t)

crash :: Train -> [Train] -> Bool
crash _ [] = False
crash train@((x1,y1),_,_) (((x2,y2),_,_):ts) = (x1 == x2 && y1 == y2) || crash train ts

removeCrashed :: (Int,Int) -> [Train] -> [Train]
removeCrashed _ [] = []
removeCrashed pos@(x,y) (t@((tx,ty),_,_):ts) | (x == tx && y == ty) = removeCrashed pos ts
                                             | otherwise = t:(removeCrashed pos ts)
main = do
  input <- getContents
  let rows = (length (lines input)) - 1
      cols = length (head (lines input)) - 1
      myarray = array ((0,0),(cols, rows)) [((x,y), ((lines input) !! y) !! x) | x<-[0..cols], y<-[0..rows]] 
      mytrains = sort [ ((x,y),t,0)| x <-[0..cols], y<-[0..rows], t <- ['<','^','>','v'], (myarray ! (x,y)) == t ] 
      tracks = array((0,0),(cols, rows)) [((x,y), (mapElement myarray (x,y))) | x<-[0..cols], y<-[0..rows] ] in 
      putStrLn ( unlines ( map show (scanl (\trains tick -> moveTrains tracks tick [] (sort trains)) mytrains [0..])))
        --(show mytrains) ++ "\n" ++
        --(show (moveTrains tracks 0 mytrains)) ++ "\n")
-- ++   (unlines [ [ tracks ! (c,r) | c <- [0..cols] ] | r <- [0..rows] ] ))
