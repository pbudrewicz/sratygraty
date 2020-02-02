import System.Environment


-- primes = 2:[ x | x <- [3..], and $ map (\a -> x `mod` a /= 0) $ takeWhile (\a -> a*a<x) primes ]
primes = 2:[ x | x <- [3..], let sqrtx = ( round . sqrt . fromInteger ) x in and (map (\a -> x `mod` a /= 0) (takeWhile (<sqrtx) primes)) ]
             
             
main = do
   count <- getArgs
   (putStrLn . show . take (( read . head ) count)) primes 
