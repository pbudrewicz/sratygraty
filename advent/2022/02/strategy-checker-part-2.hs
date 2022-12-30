import GHC.Generics (Generic)
import System.Environment


data RPS = RPSError | Rock | Paper | Scissors deriving (Show, Eq, Read)
data Outcome = OutcomeError | Win | Draw | Lose deriving (Show, Eq, Read)


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

gameAnswer :: RPS -> Outcome -> RPS
gameAnswer a x | x == Win = winningShape a
               | x == Draw = a
               | otherwise = losingShape a


winningShape :: RPS -> RPS
winningShape x | x == Scissors = Rock
               | x == Rock = Paper
               | otherwise = Scissors

losingShape :: RPS -> RPS
losingShape x | x == Scissors = Paper
               | x == Rock = Scissors
               | otherwise = Rock

gameScore :: (RPS, Outcome) -> Int
gameScore (a, b) = (outcomeScore (gameOutcome a (gameAnswer a b))) + (shapeScore (gameAnswer a b))

char2RPS :: String -> RPS
char2RPS "A" = Rock
char2RPS "B" = Paper
char2RPS "C" = Scissors

char2Outcome :: String -> Outcome
char2Outcome "X" = Lose
char2Outcome "Y" = Draw
char2Outcome "Z" = Win
char2Outcome _ = OutcomeError


gamePlay :: [String] -> (RPS, Outcome)
gamePlay (a:b:[]) = ((char2RPS a), (char2Outcome b))
gamePlay _ = (RPSError, OutcomeError)

main = do args <- getArgs
          input <- getContents
          putStrLn $ show (sum (map (\l -> (gameScore( gamePlay (words l)))) (lines input)))
