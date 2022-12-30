import GHC.Generics (Generic)
import System.Environment
import Data.Char
import Text.Regex.Posix -- for regex

covered :: (Int,Int,Int,Int) -> Bool
covered (a,b,c,d) | (a <= c && b >= d) || (a >= c && b <= d) = True
                  | otherwise = False

overlapping :: (Int,Int,Int,Int) -> Bool
overlapping (a,b,c,d) | (a <= c && b >= c) || (a <= d && b >= d) || (c <= a && d >= a) || (c <= b && d >= b) = True
                      | otherwise = False

text2Rec :: String -> (Int, Int, Int, Int)
text2Rec x | x =~ rangePattern :: Bool = let (b,m,a,[g1,g2,g3,g4]) = (x =~ rangePattern :: (String, String, String, [String]))
                                         in (read g1, read g2, read g3, read g4)
  where rangePattern = "([0-9]+)-([0-9]+),([0-9]+)-([0-9]+)"

main = do args <- getArgs
          input <- getContents
          putStrLn $ show $ length (filter (\r -> covered (text2Rec r))  (lines input))
          putStrLn $ show $ length (filter (\r -> overlapping (text2Rec r))  (lines input))
