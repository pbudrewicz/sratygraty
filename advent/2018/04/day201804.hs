import Data.List -- for sort
import Text.Regex.Posix -- for regex

type Id = Int 
type Minute = Int

data State = Sleep|Awake|Id Int deriving (Read, Show)
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

getGuards :: [LogRec] -> [Int]
getGuards []  = []
getGuards (l@(m,Id g):ls) | g `elem` glist = glist
                          | otherwise = g:glist
                          where glist = getGuards ls
getGuards (l:ls) = getGuards ls

getSleep :: Id -> [LogRec] -> SleepTime
getSleep g alog = scanl (\id (m, s) -> case s of 
                                              (m,Id 
                         

main = do
  input <- getContents
  let myinput = (lines input) 
      alog = map textToRec (sort myinput) in
      putStrLn (show (getGuards alog))
--      putStrLn (unlines (map show alog))
