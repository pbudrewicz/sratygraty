import Text.Regex.Posix
import Data.List
import Data.Char

type Step = Char
type Time = Int
type Succession = (Step, Step) -- (prerequsite, step)
-- State is (( list of pairs: step and the time step will be finished), pair of (list of (pairs of step and the finish time)) and number of busy workers, list of steps)
type State = ([(Step,Time)],([(Step,Time)],Int),[Step]) 

workerCnt = 2

readConstraints :: [String] -> [Succession]
readConstraints [] = []
readConstraints (s:ss) = let (_,_,_,[pred,post]) = (s =~ "Step (.) must be finished before step (.) can begin." :: (String, String, String, [String]))
                         in (head pred,head post):(readConstraints ss)

isSubsetOf :: [Step] -> [Step] -> Bool
isSubsetOf [] _ = True
isSubsetOf (e:ex) set = e `elem` set && ex `isSubsetOf` set

dedup :: [Char] -> [Char]
dedup [] = []
dedup (x:xs) | x `elem` xs = dedup xs
             | otherwise = x:(dedup xs)

stepIsExecutable :: Step -> [(Step,Time)] -> [Succession] -> Bool
stepIsExecutable step done constraints = [ s1 | (s1, s2) <- constraints, s2 == step ] `isSubsetOf` (map (\(s,t) -> s) done)

stepIsDone :: Time -> Step -> [Step] -> [Succession] -> Bool
stepIsDone t step done constraints = [ s1 | (s1, s2) <- constraints, s2 == step ] `isSubsetOf` done

getPrerequisites :: Step -> [Succession] -> [Step]
getPrerequisites s constraints = [ s1 | (s1, s2) <- constraints, s2 == s ]

doStep :: Time -> State -> Step -> State -- assume step isDone
doStep t (done,(exec,w),left) s = ((s,t):done, (remove (s,t) exec, w-1), left) 

executeSteps :: Time -> [Step] -> State -> State -- assume step IsExecutable
executeSteps _ [] state = state
executeSteps t (s:ss) state@(done,(exec,w),left) | w < workerCnt = executeSteps t ss (done, ((s,t+(stepTime s)):exec,w+1), remove s left) 
                                                 | otherwise = state
                                           
remove :: (Eq a) => a -> [a] -> [a]
remove i [] = []
remove i (x:xs) | i == x = remove i xs
                | otherwise = x:(remove i xs)

nextStep :: Time -> [Succession] -> State -> State
nextStep t _ s@(done,([],_),[]) = s
nextStep t constraints curr@(done,(exec,w),left) = let (cur_done,cur_exec,cur_left) = foldl (doStep t) curr [ s | (s,t1) <- exec, t1 < t] 
                                                   in  nextStep (t+1) constraints (executeSteps t [s | s <- cur_left, stepIsExecutable s cur_done constraints ] (cur_done, cur_exec, cur_left) )

-- nextStep constraints (done,left) = nextStep constraints (executeStep t (head (sort ([ s | s <- left, stepPossible s done constraints] ))) (done, left))

stepTime :: Char -> Int
stepTime c = (ord c) - 4

main = do
  input <- getContents
  let constraints = readConstraints (lines input)
      steps = dedup (concat (map (\(s1,s2) -> [s1, s2]) constraints)) in
      putStrLn (show (reverse ((\(d,c,l) -> d) (nextStep 0 constraints ([],([],0),steps)))))
--      putStrLn (show [ (s, getPrerequisites s constraints) | s <- steps ] )
--      putStrLn (show [ s | s <- steps, stepPossible s [] constraints ] )
