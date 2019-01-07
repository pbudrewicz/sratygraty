import Data.List -- for sort
import Text.Regex.Posix -- for regex

type Id = Int 
type Minute = Int

data State = Sleep|Awake|Id Int deriving (Read, Show, Eq)
type LogRec = (Minute, State)
type SleepTime = (Id, Int)

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
getSleepTime guard alog = (\(id,slp,x) -> (guard,slp)) (foldl (\(i, acc, t) (m, s) -> case (i, s) of
                                                                                            (id,Awake) -> if id == guard then (i, acc+m-t, m)
                                                                                                                         else (i, acc, m)
                                                                                            (_,Id g)   -> (g, acc, m)
                                                                                            _          -> (i, acc, m)
                                                                                                    
                                                              ) (-1, 0, 0) alog)

showSleeper :: SleepTime -> String
showSleeper (id,t) = "Guard " ++ show id ++ " sleeped " ++ show t

longestSleeper :: [SleepTime] -> SleepTime
longestSleeper [] = (-1,0)
longestSleeper (x:[]) = x
longestSleeper (x@(i,s):xs) | s > ls = x
                            | otherwise   = l
                              where l@(li,ls) = longestSleeper xs

mostMinute :: Id -> [LogRec] -> Int
mostMinut guard alog = maximum [ (m,countMinutes guard alog m) | m <- [0..59] ]

countMinutes Id -> [LogRec] -> Int -> Int
countMinutes guard alog min = 

main = do
  input <- getContents
  let myinput = (lines input) 
      alog = map textToRec (sort myinput) in
--      putStrLn (unlines (map showSleeper [  getSleepTime guard alog | guard <- getGuards alog ]))
      putStrLn (show (longestSleeper [  getSleepTime guard alog | guard <- getGuards alog ]))
--      putStrLn (unlines (map show alog))
