import Data.List -- for sort
import Text.Regex.Posix -- for regex

type Id = Int 
type Minute = Int

data State = Sleep|Awake|Id Int deriving (Read, Show, Eq)
type LogRec = (Minute, State)
type SleepTime = (Id, Int)
type SleepPeriod = (Int,Int)

textToRec :: String -> LogRec
textToRec x | x =~ patGuard :: Bool = let (b,m,a,[g1,g2]) = (x =~ patGuard :: (String, String, String, [String]))
                                      in  (read g1,Id (read g2))
            | x =~ patFalls :: Bool = let (b,m,a,[g]) = (x =~ patFalls :: (String, String, String, [String]))
                                      in  (read g, Sleep)
            | x =~ patWakes :: Bool = let (b,m,a,[g]) = (x =~ patWakes :: (String, String, String, [String]))
                                      in (read g, Awake)
            where patWakes = ":([0-9]{2}).*wakes" 
                  patFalls = ":([0-9]{2}).*falls"
                  patGuard = ":([0-9]{2}).*Guard #([0-9]+) "

getGuards :: [LogRec] -> [Id]
getGuards []  = []
getGuards (l@(m,Id g):ls) | g `elem` glist = glist
                          | otherwise = g:glist
                          where glist = getGuards ls
getGuards (l:ls) = getGuards ls
                                

getSleepTime :: Id -> [LogRec] -> SleepTime
--getSleepTime guard alog = (\(id,slp,x) -> (guard,slp)) (foldl (\(i, acc, t) (m, s) -> case (i, s) of
--                                                                                            (id,Awake) -> if id == guard then (i, acc+m-t, m)
--                                                                                                                         else (i, acc, m)
--                                                                                            (_,Id g)   -> (g, acc, m)
--                                                                                            _          -> (i, acc, m)
--                                                                                                    
--                                                              ) (-1, 0, 0) alog)
getSleepTime guard alog = (\(id,slp,x) -> (guard,slp)) (foldl (getGuardsSleeps :: (Id,Int,Int) -> (Int,State) -> (Id,Int,Int)) (-1, 0, 0) alog)
                                                       where 
                                                          getGuardsSleeps (i, acc, t) (m, Awake) | guard == i = (guard, acc+m-t,m)
                                                                                                 | otherwise  = (i, acc, m)
                                                          getGuardsSleeps (_, acc, _) (m, Id g) = (g, acc, m)
                                                          getGuardsSleeps (i, acc, _) (m, _)    =  (i, acc, m)
           
                                                                                                    
                                                              


showSleeper :: SleepTime -> String
showSleeper (id,t) = "Guard " ++ show id ++ " sleeped " ++ show t

longestSleeper :: [SleepTime] -> SleepTime
longestSleeper [] = (-1,0)
longestSleeper (x:[]) = x
longestSleeper (x@(i,s):xs) | s > ls = x
                            | otherwise   = l
                              where l@(li,ls) = longestSleeper xs



mostMinute :: [(Int,Int,Int)] -> (Int,Int,Int)
mostMinute [] = (-1,-1,0)
mostMinute (x:[]) = x
mostMinute (x@(m,g,c):xs) | c > mc = x
                          | otherwise = mM
                            where mM@(mm,mg,mc) = mostMinute xs

countMinutes :: Id -> [LogRec] -> Int -> Int
countMinutes guard alog min = length [ (f,t) | (f,t) <- sleepPeriods guard alog, min >= f && min < t ]

sleepPeriods :: Id -> [LogRec] -> [SleepPeriod]
sleepPeriods guard alog = (\(id,acc,x) -> acc) (foldl (\(i, acc, t) (m, s) -> case (i, s) of
                                                                                            (id,Awake) -> if id == guard then (i, (t,m):acc, m)
                                                                                                                         else (i, acc, m)
                                                                                            (_,Id g)   -> (g, acc, m)
                                                                                            _          -> (i, acc, m)
                                                                                                    
                                                              ) (-1, [], 0) alog)

showPeriod :: Id -> SleepPeriod -> String
showPeriod guard (from, to) = "Guard " ++ show guard ++ " slept from " ++ show from ++ " to " ++ show to

main = do
  input <- getContents
  let myinput = (lines input) 
      alog = map textToRec (sort myinput)
      guard = (\(g,s) -> g) (longestSleeper [  getSleepTime grd alog | grd <- getGuards alog ])
      minute1 = (mostMinute [(m,grd,countMinutes grd alog m) | m <- [0..59], grd <- [guard]] ) 
      minute2 = (mostMinute [(m,grd,countMinutes grd alog m) | m <- [0..59], grd <- getGuards alog] ) in
--      putStrLn (unlines (map showSleeper [  getSleepTime guard alog | guard <- getGuards alog ]))
      putStrLn (show (map (\(m,g,c) -> m * g) [minute1, minute2]))
--      putStrLn (show (longestSleeper [  getSleepTime guard alog | guard <- getGuards alog ]))
--      putStrLn (unlines (map show alog))
