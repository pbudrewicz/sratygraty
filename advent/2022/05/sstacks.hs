import GHC.Generics (Generic)
import System.Environment
import Data.Char
import Text.Regex.Posix -- for regex
import Data.Array

type Stacks = Array (Int) [Char]


rearrange :: Stacks -> Stacks
rearrange x = x//[(i, reverse (x ! i)) | i <- [1..9]]

buildStacks :: ([String], Stacks) -> ([String], Stacks)
buildStacks (l:ls, stack) | l =~ blocksPattern :: Bool = buildStacks (ls, getLayer (l, stack, 1))
                          | otherwise = (ls, rearrange stack)
                          where blocksPattern = "\\[.\\]"


getLayer :: (String, Stacks, Int) -> Stacks
getLayer (' ':' ':' ':' ':ls, s, i) = getLayer (ls, s, i+1)
getLayer (' ':' ':' ':ls, s, i) = getLayer (ls, s, i+1)
getLayer (' ':'[':c:']':ls, s, i) = getLayer(ls, s//[(i, c:(s ! i))], i+1)
getLayer ('[':c:']':ls, s, i) = getLayer(ls, s//[(i, c:(s ! i))], i+1)
getLayer (_, s, _) = s

printStacks :: ([String], Stacks) -> IO ([String], Stacks)
printStacks (ls, ss) = do
  putStrLn $ show $ map (\i -> (ss ! i)) [1..9]
  return (ls, ss)

moveStacks :: ([String], Stacks) -> ([String], Stacks)
moveStacks ([], stack) = ([], stack)
moveStacks ((m:ms), stack) | m =~ movePattern :: Bool = let (b, match, a, [g1, g2, g3]) = (m =~ movePattern :: (String, String, String, [String]))
                                                        in moveStacks (ms, (moveStack9001 stack (read g1) (read g2) (read g3)))
                           | otherwise = moveStacks(ms, stack)
  where movePattern = "move ([0-9]+) from ([0-9]+) to ([0-9]+)"


moveStack9000 :: Stacks -> Int -> Int -> Int -> Stacks
moveStack9000 ss 1 from to = let (c:cs) = ss ! from
                             in ss//[(to, c:(ss ! to)), (from, cs)]
moveStack9000 ss times from to = let (c:cs) = ss ! from
                                     nss = ss//[(to, c:(ss ! to)), (from, cs)]
                                 in (moveStack9000 nss (times - 1) from to)

moveStack9001 :: Stacks -> Int -> Int -> Int -> Stacks
moveStack9001 ss cnt from to = let tMove = take cnt (ss ! from)
                                   tLeave = drop cnt (ss ! from)
                               in ss//[(to, tMove ++ (ss ! to)), (from, tLeave)]

main = do
  args <- getArgs
  input <- getContents
  stacks <- (printStacks . buildStacks) ((lines input), array(1, 9) [ (x, []) | x <- [1..9]])
  moved <-  (printStacks . moveStacks) stacks
  putStrLn $ (\(ss,s) -> map (\h -> head h) (elems s)) moved
