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

stringToInt :: String -> Maybe Int
stringToInt str = readMaybe str

parse contents swapsRaw = let
  lines1 = Data.Text.lines contents
  split = map (Data.Text.split (== ',')) lines1
  asInts = map (map (\x -> read @Int (Data.Text.unpack x))) split
  asPairs = map (\[a, b] -> (a, b)) asInts
  in asPairs

makePairs xs ys = [(x, y) | x <- xs, y <- ys]

area ((x1, y1), (x2, y2)) = abs (x1 - x2 + 1) * abs (y1 - y2 + 1)

part1 parsed = let
  pairs = makePairs parsed parsed
  areas = map area pairs
  in maximum areas
