import Text.Regex.Posix -- for regex

data Point = Pt {pointx, pointy :: Int}

readPair :: String -> (Int, Int)
readPair x | x =~ patPair :: Bool = let (_,_,_,[g1,g2]) = (x =~ patPair :: (String, String, String, [String])) 
                                    in (read g1, read g2)
           | otherwise = (-1, -1)
           where patPair = "([0-9]+), ([0-9]+)"

getBounds :: (Int, Int, Int, Int) -> (Char, (Int, Int)) -> (Int, Int, Int, Int) 
getBounds (n,s,w,e) (_,(x,y)) = (mn, ms, mw, me)
                              where mn = max n y
                                    ms = min s y
                                    mw = min w x
                                    me = max e x



closestPoint :: (Int, Int) -> [(Char, (Int, Int))] -> [(Char, (Int, Int))]
closestPoint p [] = [('#', p)]
closestPoint _ (p:[]) = [p]
closestPoint x ((n,p):ps) | dp < dps = [(n,p)]
                          | dp == dps = (n,p):cps
                          | otherwise = cps
                            where dp  = distance x p
                                  cps = closestPoint x ps
                                  (n1,p1) = head cps
                                  dps = distance x p1

distance :: (Int,Int) -> (Int, Int) -> Int
distance (x1,y1) (x2, y2) = (abs(x2 - x1) + abs(y2 - y1))

getRegions :: (Int,Int,Int,Int) -> [(Char, (Int, Int))] -> [(Char, (Int, Int))]
getRegions (n,s,w,e) points = [ (c,(x,y)) | x <- [w..e], 
                                    y <- [s..n], 
                                    let p = (closestPoint (x,y) points), 
                                    let (c,(_,_)) = if length p == 1 then head p
                                                                     else ('.', (0, 0)) ]

boundaryRegions :: (Int,Int,Int,Int) -> [(Char,(Int,Int))] -> [Char]
boundaryRegions _ [] = []
boundaryRegions b@(n,s,w,e) ((c,(x,y)):rs) | c /= '.' && (x == w || x == e || y == n || y == s) = c:br
                                           | otherwise = br
                                            where br = boundaryRegions b rs

dedup :: [Char] -> [Char]
dedup [] = []
dedup (x:xs) | x `elem` xs = dedup xs
             | otherwise = x:(dedup xs)

regionSize :: Char -> [(Char, (Int, Int))] -> Int
regionSize c points = length [ x | (x,_) <- points, x == c ]

main = do
  input <- getContents
  let points = [ (name, (x, y)) | (name, (x,y)) <- zip ['a'..] (map readPair (lines input)) ]
      (_, (x,y)) = head points 
      bounds@(n,s,w,e) = foldl getBounds (y,y,x,x) points 
      regions = getRegions bounds points 
      br = dedup (boundaryRegions bounds regions)
      finiteRegions = dedup [ c | (c,_) <- points, not (c `elem` br) ] 
      sizes = map (\c -> (c, regionSize c points)) finiteRegions in
--      putStrLn (show (points))
      putStrLn (show (sizes))
    

