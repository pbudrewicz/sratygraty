import Text.Regex.Posix

type Coord = (Int, Int)
type Velo  = (Int, Int)

readConstraints :: [String] -> [(Coord,Velo)]
readConstraints [] = []
readConstraints (s:ss) = let (_,_,_,[x,y,vx,vy]) = (s =~ "position=< *(-?[0-9]+), *(-?[0-9]+)> velocity=< *(-?[0-9]+), *(-?[0-9]+)>" :: (String, String, String, [String]))
                         in ((read x,read y),(read vx, read vy)):(readConstraints ss)



getBounds :: [(Coord,Velo)] -> (Int,Int,Int,Int)
getBounds points = foldl getBounds' (x,x,y,y) points
  where ((x,y), _ ) = head points

getBounds' :: (Int, Int, Int, Int) -> ((Int,Int),(Int, Int)) -> (Int, Int, Int, Int) 
getBounds' (n,s,w,e) ((x,y),_) = (mn, ms, mw, me)
                              where mn = min n y
                                    ms = max s y
                                    mw = min w x
                                    me = max e x


showMessage :: [(Coord,Velo)] -> [String]
showMessage points = let  coords = map (\(c,v) -> c) points
                          ((x0,y0), _ ) = head points
                          bounds@(n,s,w,e) = foldl getBounds' (x0,x0,y0,y0) points
                     in if (s - n < 100) && (e - w < 100) then [ [  if (x,y) `elem` coords then '#' else '.' |   x <- [w..e] ] | y <- [n..s] ]
                                                          else [ "========" ++ show(s-n) ++ "--" ++ show(e-w) ++ "===============" ]
                                                                        
                                                                           

nextMove :: [(Coord,Velo)] -> [(Coord, Velo)]
nextMove points = map (\((x,y),(vx,vy)) -> ((x+vx,y+vy),(vx,vy))) points

main = do
  input <- getContents
  let constr = readConstraints (lines input)
      ((x,y),_) = head constr  in
    putStrLn (unlines (map (unlines . showMessage) (scanl (\pts i -> nextMove pts) constr [0..11000])))
  
