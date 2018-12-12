import Data.Char
import Data.List
import qualified Data.Set as Set

next_generation :: [[Int]] -> Set.Set Int  -> Set.Set Int 
next_generation rules px = Set.fromList [ p | p <- [(Set.findMin px - 2)..(Set.findMax px + 2)], check_rules p px rules ] 

check_rules :: Int -> Set.Set Int -> [[Int]] -> Bool
check_rules n state rules =  any (\r -> check_rule n state r) rules 

check_rule :: Int -> Set.Set Int -> [Int] -> Bool
check_rule n state rule = all (\v ->   ((elem (v) rule) && (Set.member (n+v) state)) || (not (elem (v) rule) && not (Set.member (n+v) state))) [-2, -1, 0, 1, 2] 


-- preparation of input

decode_state :: Int -> String -> [Int]
decode_state _ [] = []
decode_state n (x:xs) | x == '#'  = n:decode_state (n+1) xs
                      | otherwise = decode_state (n+1) xs

get_initial_state :: String -> [Int]
get_initial_state input = decode_state 0 (head (drop 2 (words (head (lines input)))))

get_rules :: String -> [[Int]]
get_rules input = decode_rules (drop 2 (lines input))

decode_rules :: [String] -> [[Int]]
decode_rules rules  = map decode_rule (filter ( \s -> (last s) == '#' )  rules)

decode_rule :: String -> [Int]
decode_rule rule = map  (\(c,v) -> v) (filter (\(c, v) -> (c == '#')) (zip rule [-2, -1, 0, 1, 2] ))

main = do
  input <- getContents
  let rules = get_rules input in
    putStrLn ( show ( sum (Set.elems (foldl' (\s i -> next_generation rules s) (Set.fromList (get_initial_state input)) [1..100000]))))
--    putStrLn ( show ( sum (foldr (\i s -> next_generation rules s) (get_initial_state input) [1..20] )))
--  putStrLn (show (get_initial_state input))
--  putStrLn (show (get_rules input))
