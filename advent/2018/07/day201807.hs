import Text.Regex.Posix
import Data.List
import Data.Char

type Step = Char
type Succession = (Step, Step) 

readConstraints :: [String] -> [Succession]
readConstraints [] = []
readConstraints (s:ss) = let (_,_,_,[pred,post]) = (s =~ "Step (.) must be finished before step (.) can begin." :: (String, String, String, [String]))
                         in (head pred,head post):(readConstraints ss)

stepPossible :: Step -> [Step] -> [Succession] -> Bool
stepPossible step done constraints = [ s1 | (s1, s2) <- constraints, s2 == step ] `isSubsetOf` done

isSubsetOf :: [Step] -> [Step] -> Bool
isSubsetOf [] _ = True
isSubsetOf (e:ex) set = e `elem` set && ex `isSubsetOf` set

dedup :: [Char] -> [Char]
dedup [] = []
dedup (x:xs) | x `elem` xs = dedup xs
             | otherwise = x:(dedup xs)

getPrerequisites :: Step -> [Succession] -> [Step]
getPrerequisites s constraints = [ s1 | (s1, s2) <- constraints, s2 == s ]

doStep :: Step -> ([Step],[Step]) -> ([Step],[Step])
doStep s (done,left) = (s:done, remove s left)

remove :: Step -> [Step] -> [Step]
remove i [] = []
remove i (x:xs) | i == x = remove i xs
                | otherwise = x:(remove i xs)

nextStep :: [Succession] -> ([Step],[Step]) -> ([Step],[Step])
nextStep _ (done,[]) = (done,[]) 
nextStep constraints (done,left) = nextStep constraints (doStep (head (sort ([ s | s <- left, stepPossible s done constraints] ))) (done, left))

stepTime :: Char -> Int
stepTime c = (ord c) - 4

main = do
  input <- getContents
  let constraints = readConstraints (lines input)
      steps = dedup (concat (map (\(s1,s2) -> [s1, s2]) constraints)) in
      putStrLn (show (map (\c -> (c,stepTime c)) ((reverse ((\(d,l) -> d) (nextStep constraints ([],steps) ))))))
--      putStrLn (show [ (s, getPrerequisites s constraints) | s <- steps ] )
--      putStrLn (show [ s | s <- steps, stepPossible s [] constraints ] )
