import qualified System.IO
import System.Environment
import Text.Read (readMaybe)

-- Things from last year
-- import qualified Data.Map
-- import Data.Bits
-- import Formatting

-- Things Clonq recommended
-- import Data.List
-- Missing: import Data.Vector.Strict
-- import Data.Map.Strict
-- import Data.Set
-- import Data.Sequence
-- import Data.Graph
import Data.Text.IO

import qualified Data.Text

main = do
  args <- getArgs
  fh <- System.IO.openFile (head args) System.IO.ReadMode
  contents <- hGetContents fh
  print $ part1 (parse contents [])
  print $ part2 (parse contents [])

stringToInt :: String -> Maybe Int
stringToInt str = readMaybe str

parse contents swapsRaw = let
  lines1 = Data.Text.lines contents
  split = map (Data.Text.split (== ',')) lines1
  asInts = map (map (\x -> read @Int (Data.Text.unpack x))) split
  asPairs = map (\[a, b] -> (a, b)) asInts
  in asPairs

makePairs xs ys = [(x, y) | x <- xs, y <- ys]

area ((x1, y1), (x2, y2)) = (abs (x1 - x2) + 1) * (abs (y1 - y2) + 1)

part1 parsed = let
  pairs = makePairs parsed parsed
  areas = map area pairs
  in maximum areas

-- checkCoord x y = x /= y - 1 && x /= y + 1
-- checkCoord2 x y = x /= y && x /= y - 1 && x /= y + 1
-- checkValid ((x1, y1), (x2, y2)) =
--   (checkCoord2 x1 x2) && (checkCoord y1 y2) || (checkCoord x1 x2) && (checkCoord2 y1 y2)
-- We verified the input always jumps at least 2 in one direction.

isBetween low high a = a > low && a < high

doesCross low high a b = let
  in not ((a >= high && b >= high) || (a <= low && b <= low))

isPairIntersectedByAdj (rect1, rect2) (line1, line2) = let
  (r1x, r1y) = rect1
  (r2x, r2y) = rect2
  (l1x, l1y) = line1
  (l2x, l2y) = line2
  top = min r1y r2y
  bottom = max r1y r2y
  left = min r1x r2x
  right = max r1x r2x
  in if l1x == l2x then
    isBetween left right l1x &&
    doesCross top bottom l1y l2y
  else
    isBetween top bottom l1y &&
    doesCross left right l1x l2x

isPairValid adjacents pair = and $ map not $ map (isPairIntersectedByAdj pair) adjacents

part2 parsed = let
  pairs = makePairs parsed parsed
  adjacents = (last parsed, head parsed):(zip parsed $ tail parsed)
  validPairs = filter (isPairValid adjacents) pairs
  areas = map area validPairs
  in maximum areas



-- 1439862255 is too low
