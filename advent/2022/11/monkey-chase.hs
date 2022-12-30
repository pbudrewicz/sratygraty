import GHC.Generics (Generic)
import System.Environment
import Text.Regex.Posix -- for regex
import Data.Array



type Monkey = (Int, [Integer], Integer -> Integer, String, Integer, Int, Int, Int)
-- monkeyId, [worry levels], update func, func description, divisability, true Monkey, false Monkey, inspection count


lineToRec :: [String] -> [Monkey]
lineToRec [] = []
lineToRec (mon:wor:oper:divtest:tmon:fmon:separator:x) = let (b1,m1,a1,[g1]) = (mon =~ monPattern :: (String, String, String, [String]))
                                                             (b2,m2,a2,[g2]) = (wor =~ worPattern :: (String, String, String, [String]))
                                                             (b3,m3,a3,[g3]) = (oper =~ operPattern :: (String, String, String, [String]))
                                                             (b4,m4,a4,[g4]) = (divtest =~ divtestPattern :: (String, String, String, [String]))
                                                             (b5,m5,a5,[g5]) = (tmon =~ tmonPattern :: (String, String, String, [String]))
                                                             (b6,m6,a6,[g6]) = (fmon =~ fmonPattern :: (String, String, String, [String]))
                                                             worries = map (\w -> read w :: Integer) (words (filter (\a -> a /= ',') g2))
                                                         in (read g1 :: Int, worries, readOperation g3, g3, read g4 :: Integer, read g5 :: Int, read g6 :: Int,0):(lineToRec x)
  where
    monPattern = "Monkey ([0-9]+)"
    worPattern = "Starting items: (.*)"
    operPattern = "Operation: new = (.*)"
    divtestPattern =  "Test: divisible by ([0-9]+)"
    tmonPattern = "If true: throw to monkey ([0-9]+)"
    fmonPattern = "If false: throw to monkey ([0-9]+)"
lineToRec _ = []

showMonkey :: Monkey -> String
showMonkey (m,w,o,c,d,t,f,i) = "Monkey: " ++ show m ++ ", (" ++ show w ++ "), " ++ c ++ ", " ++ show d ++ ", (" ++ show t ++ "," ++ show f ++ "), " ++ show i ++ "\n"

readOperation :: String -> (Integer -> Integer)
readOperation x = let [arg1, op, arg2] = words x
                  in (\a -> (if op == "+" then (+)
                             else (*)) (if arg1 == "old" then a
                                        else (read arg1))  (if arg2 == "old" then a
                                                            else (read arg2)))

readMonkeys :: Array (Int) Monkey -> [Monkey] -> Array (Int) Monkey
readMonkeys ar [] = ar
readMonkeys ar (mon@(m,_,_,_,_,_,_,_):ms) = readMonkeys (ar // [(m, mon)]) ms


manageWorryLevel :: Integer -> Integer
-- manageWorryLevel x = x `div` 3   -- for first part
-- manageWorryLevel x = x `mod` 96577 -- for test data
manageWorryLevel x = x `mod` 9699690 -- for input

monkeyInspection :: Monkey -> Integer -> (Int, Integer) -- what, whom
monkeyInspection (_, _, o, _, d, t, f, _) x = let nw = manageWorryLevel (o x) -- `div` 3 -- part one vs. part two
                                              in
                                                (if nw `mod` d == 0 then t
                                                 else f, nw)

monkeyTurn :: Array (Int) Monkey -> Int -> Array (Int) Monkey
monkeyTurn ar n = let mon@(m,ws,o,c,d,t,f,i) = (ar ! n)
                      out = foldl (\a -> \wl -> aMonkeyCatch a (monkeyInspection mon wl)) ar ws -- throw elements
                  in out // [(m, (m,[],o,c,d,t,f,i+(length ws)))] -- return with emptied list and added inspection count


theMonkeyCatch :: Monkey -> Integer -> Monkey
theMonkeyCatch (m,w,o,c,d,t,f,i) x = (m,w ++ [x],o,c,d,t,f,i)

aMonkeyCatch :: Array (Int) Monkey -> (Int, Integer) -> Array (Int) Monkey -- which, what
aMonkeyCatch ar (n,x) = ar // [(n, (theMonkeyCatch (ar ! n) x))]


monkeyRound :: Array (Int) Monkey -> Array (Int) Monkey
monkeyRound ar = foldl (\a -> \m -> monkeyTurn a m) ar (indices ar)

main = do
  args <- getArgs
  input <- getContents
  let monkeys = (lineToRec . lines) input
      start = readMonkeys (array (0, (length monkeys)-1) [(x, (x,[], (+1), "inc",1,2,3,0)) | x <- [0..((length monkeys)-1)]])  monkeys
      two = foldl (\a -> \r -> monkeyTurn (monkeyTurn a 0) 1) start [0]
      one = foldl (\a -> \r -> monkeyTurn (monkeyTurn (monkeyTurn (monkeyTurn a 0) 1) 2) 3) start [0]
      twenty = foldl (\a -> \r -> monkeyRound a) start [1..20]
      end = foldl (\a -> \r -> monkeyRound a) start [1..10000]
    in putStrLn $ foldl (\ms -> \m -> ms ++ showMonkey m) "" ((elems start) ++ (elems two) ++ (elems one) ++ (elems twenty) ++ (elems end))
