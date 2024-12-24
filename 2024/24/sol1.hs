import System.IO
import Data.List
import System.Environment
import Text.Read (readMaybe)
import qualified Data.Map
import Data.Bits


data OpType = And | Or | Xor
data GateType = Gate String OpType String String | Const String Int
data ParsedInputType = Input [GateType] [GateType] (Data.Map.Map String GateType)

main = do
  args <- getArgs
  fh <- openFile (head args) ReadMode
  contents <- hGetContents fh
  print $ solution $ parse contents

solution input = (solution1 input)

solution1 (Input inits gates outMap) = let
  outputs = sort $ filter (\x -> 'z' == head x) $ map (\(Gate _ _ _ out) -> out) gates
  values = map (getValue outMap) outputs
  int = bitsToInt values
  in int

bitsToInt (x:rest) = x + 2 * bitsToInt rest
bitsToInt [] = 0

getValue outMap name =
  case Data.Map.lookup name outMap of
    Nothing -> 5000
    Just x -> case x of 
      Const name val -> val
      Gate in1 op in2 name -> apply op (getValue outMap in1) (getValue outMap in2)

apply Xor in1 in2 = xor in1 in2
apply And in1 in2 = (.&.) in1 in2
apply Or in1 in2 = (.|.) in1 in2








stringToInt :: String -> Maybe Int
stringToInt str = readMaybe str

parse contents = let
  lines1 = lines contents
  first = map parseInput $ takeWhile (\x -> x /= "") lines1
  second = map parseGate $ tail $ dropWhile (\x -> x /= "") lines1
  outMap = Data.Map.fromList $
      (map (\(Gate in1 op in2 out) -> (out, Gate in1 op in2 out)) second) ++
      (map (\(Const name init) -> (name, Const name init)) first)
  in Input first second outMap

parseInput line = let
  parts = words line
  name = reverse $ tail $ reverse $ head parts
  Just init = stringToInt $ head $ tail parts
  in Const name init

instance Show OpType where
  show And = show "AND"
  show Or = show "OR"
  show Xor = show "XOR"
instance Show GateType where
  show (Gate in1 op in2 out) = show ("Gate", in1, op, in2, out)
  show (Const name init) = show ("Const", name, init)

parseGate line = let
  [in1, op, in2, _arrow, out] = words line
  in Gate in1 (parseOp op) in2 out

parseOp "OR" = Or
parseOp "XOR" = Xor
parseOp "AND" = And
