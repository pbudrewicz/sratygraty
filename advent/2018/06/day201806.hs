import Data.Char


data Point = Pt {pointx, pointy :: Int}

readPair :: String -> (Int, Int)
readPair x = (read (head (words x)), read (head (tail (words x))))

main = do
  input <- getContents
  let points = map readPair (lines input) in
      putStrLn (show points)



