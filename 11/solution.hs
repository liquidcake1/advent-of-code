import System.IO
import Data.List

main = do solution "input11.txt"

solution filename = do
    fh <- openFile filename ReadMode
    input <- hGetContents fh
    print $ solve input expand

-- Why error when I try "solution filename expfn" and replace expand2 with expfn?
solution2 filename = do
    fh <- openFile filename ReadMode
    input <- hGetContents fh
    print $ solve input expand2

solve input expfn = let
    ilines = lines input
    galaxies = findGalaxies ilines
    xs = sort $ map (\(_, x) -> x) galaxies
    ys = sort $ map (\(y, _) -> y) galaxies
    xdists = tdist $ expfn xs
    ydists = tdist $ expfn ys
    in xdists + ydists

findGalaxies ilines = let
    xss = map findGalaxiesOnLine ilines
    in concat $ map (\(xs, y) -> map (\x -> (x, y)) xs) $ zip xss $ iterate (+1) 0

findGalaxiesOnLine line = map (\(_, a) -> a) $ filter (\(a, _) -> a == '#') $ zip line $ iterate (+1) 0

-- sorted coords to expanded coords
expand xs = let
    gaps = getGaps xs
    gapsums = drop 1 $ scanl (+) 0 gaps
    in map (\(a, b) -> a + b) $ zip xs gapsums

expand2 xs = let
    gaps = getGaps xs
    gapsums = drop 1 $ scanl (+) 0 gaps
    in map (\(a, b) -> a + b * 999999) $ zip xs gapsums

-- sorted coords to expansion gaps prior to each
getGaps xs = map (max 0) $ map (\(a, b) -> a - b - 1) $ zip xs $ 0:xs

tdist xs = sum $ map (\(a, b) -> a * b) $ zip xs $ iterate (2 +) $ 1 - (length xs)
