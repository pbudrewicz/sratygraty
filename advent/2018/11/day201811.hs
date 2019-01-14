

myGridSerial = 7689

cellLevel :: (Int,Int, Int) -> Int
cellLevel (gridSerial,x,y) = let rackID = x+10
                                 powLevelStart = rackID * y
                             in ((((powLevelStart + gridSerial) * rackID)  `div` 100) `mod` 10) - 5

squarePower :: (Int, Int, Int, Int) -> Int
squarePower (serial, s, x, y) = sum [ cellLevel( serial, x1, y1 ) | x1 <- [x..(x+s-1)], y1 <- [y..(y+s-1)] ]

bestSquare :: Int -> (Int, Int, Int,Int)
bestSquare serial = foldl (\(p1,s1,x1,y1) (s2,x2, y2) -> let p2 = (squarePower(serial, s2, x2, y2)) 
                                                         in if p2 > p1 then  (p2,s2,x2, y2) 
                                                                       else (p1,s1, x1,y1)) (squarePower( serial, 1, 1, 1),1,1,1) [ (s3,x3,y3) | s3 <- [1..300], x3 <- [1..(300-s3+1)], y3 <- [1..(300-s3+1)] ]

bestSizeSquare :: Int -> Int -> (Int, Int, Int,Int)
bestSizeSquare serial size = foldl (\(p1,_,x1,y1) (x2, y2) -> let p2 = (squarePower(serial, size, x2, y2)) 
                                                               in if p2 > p1 then (p2,size,x2,y2) 
                                                                             else (p1,size,x1,y1)) (squarePower( serial, size, 1, 1),size,1,1) [ (x3,y3) | x3 <- [1..(300-size+1)], y3 <- [1..(300-size+1)] ]

bestAnySquare :: Int -> [(Int, Int, Int,Int)]
bestAnySquare serial = scanl (\(p1,s1,x1,y1) s -> let (p2,s2,x2,y2) = (bestSizeSquare serial s)
                                                  in if p2 > p1 then (p2,s2,x2,y2) 
                                                                else (p1,s1,x1,y1)) (bestSizeSquare serial 1) [ s3 | s3 <- [1..300] ]


main = do 
  putStrLn ( show ([cellLevel(8,3,5),cellLevel (57,122,79),cellLevel(39,217,196),cellLevel(71,101,153), squarePower(18,3,33,45), squarePower(42,3,21,61) ]))
  putStrLn (  unlines (map (show . bestSizeSquare myGridSerial) [1..300] ))
