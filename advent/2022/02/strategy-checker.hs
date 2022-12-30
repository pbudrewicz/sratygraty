import GHC.Generics (Generic)
import System.Environment


data RPS = RPSError | Rock | Paper | Scissors deriving (Show, Eq, Read)
data Outcome = Win | Draw | Lose


gameOutcome :: RPS -> RPS -> Outcome
gameOutcome Rock  Paper = Win
gameOutcome Scissors  Rock = Win
gameOutcome Paper  Scissors = Win
gameOutcome x y | x == y    = Draw
                | otherwise = Lose


outcomeScore :: Outcome -> Int
outcomeScore Win = 6
outcomeScore Draw = 3
outcomeScore Lose = 0

shapeScore :: RPS -> Int
shapeScore Scissors = 3
shapeScore Paper = 2
shapeScore Rock = 1

gameScore :: (RPS, RPS) -> Int
gameScore (a, b) = (outcomeScore (gameOutcome a b)) + (shapeScore b)

char2RPS :: String -> RPS
char2RPS "A" = Rock
char2RPS "B" = Paper
char2RPS "C" = Scissors
char2RPS "X" = Rock
char2RPS "Y" = Paper
char2RPS "Z" = Scissors
char2RPS _ = RPSError


gamePlay :: [String] -> (RPS, RPS)
gamePlay (a:b:[]) = ((char2RPS a), (char2RPS b))
gamePlay _ = (RPSError, RPSError)

main = do args <- getArgs
          input <- getContents
          putStrLn $ show (sum (map (\l -> (gameScore( gamePlay (words l)))) (lines input)))
