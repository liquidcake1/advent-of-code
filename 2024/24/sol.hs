import System.IO
import Data.List
import System.Environment
import Text.Read (readMaybe)
import qualified Data.Map
import Data.Bits
import Formatting


data OpType = And | Or | Xor
data GateType = Gate String OpType String String | Const String Int
data ParsedInputType = Input [GateType] [GateType] (Data.Map.Map String GateType) (Data.Map.Map String [GateType])

main = do
  args <- getArgs
  fh <- openFile (head args) ReadMode
  contents <- hGetContents fh
  print $ solution1 (parse contents [])
  -- Should output (45,Just "z45"). If not, inspect graph around here and provide swaps
  print $ solution2 (parse contents (tail args))

solution1 (Input inits gates outMap inMap) = let
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



solution2 (Input inits gates outMap inMap) = let
  xs = sort $ filter (\x -> 'x' == head x) $ map (\(Gate _ _ _ out) -> out) gates
  ys = sort $ filter (\x -> 'y' == head x) $ map (\(Gate _ _ _ out) -> out) gates
  in checkUntil 0 Nothing inMap

checkUntil n carryprev inMap =
  case checkFullState n carryprev inMap of
    Just carry -> checkUntil (n + 1) (Just carry) inMap
    Nothing -> (n, carryprev)

checkFullState 0 Nothing inMap = let
  in case checkHalfAdder "x00" "y00" inMap of
    Just ("z00", carry) -> Just carry
    Just (_, carry) -> Nothing
    Nothing -> Nothing

checkFullState n (Just carryprev) inMap = let
  xname = 'x':(fmtIntPad n)
  yname = 'y':(fmtIntPad n)
  zname = 'z':(fmtIntPad n)
  in
  case checkHalfAdder xname yname inMap of
    Just (outa, carrya) -> (
      case checkHalfAdder carryprev outa inMap of
        Just (zname2, carryb) -> if zname2 == zname then findGate carrya Or carryb inMap else Nothing
        Nothing -> Nothing
      )
    Nothing -> Nothing
  

checkHalfAdder xname yname inMap = let
  andchild = findGate xname And yname inMap
  xorchild = findGate xname Xor yname inMap
  in
    case xorchild of
      Just sumout -> (case andchild of
        Just carryout -> Just (sumout, carryout)
        Nothing -> Nothing)
      Nothing -> Nothing
      
findGate xname op yname inMap = let
  xchildren = case Data.Map.lookup xname inMap of
    Nothing -> []
    Just x -> x
  ychildren = case Data.Map.lookup xname inMap of
    Nothing -> []
    Just x -> x
  opchildren = filter (\(Gate _ op2 _ _) -> op2 == op) xchildren
  opchild = case opchildren of
    [Gate _ _ _ out] -> Just out
    _ -> Nothing
  childrenok = xchildren == ychildren || xchildren == reverse ychildren
  childlenok = (1 == length opchildren)
  in
    if childrenok && childlenok then
      opchild
    else
      Nothing

fmtIntPad x =
  fmtInt (div x 10) ++ fmtInt(mod x 10)
fmtInt 0 = "0"
fmtInt 1 = "1"
fmtInt 2 = "2"
fmtInt 3 = "3"
fmtInt 4 = "4"
fmtInt 5 = "5"
fmtInt 6 = "6"
fmtInt 7 = "7"
fmtInt 8 = "8"
fmtInt 9 = "9"




stringToInt :: String -> Maybe Int
stringToInt str = readMaybe str

parse contents swapsRaw = let
  swaps = pairSwaps swapsRaw
  lines1 = lines contents
  first = map parseInput $ takeWhile (\x -> x /= "") lines1
  secondPreSwap = map parseGate $ tail $ dropWhile (\x -> x /= "") lines1
  second = map (doSwap swaps) secondPreSwap
  outMap = Data.Map.fromList $
      (map (\(Gate in1 op in2 out) -> (out, Gate in1 op in2 out)) second) ++
      (map (\(Const name init) -> (name, Const name init)) first)
  inMap = Data.Map.fromListWith (\x y -> x ++ y) $
      (map (\(Gate in1 op in2 out) -> (in1, [Gate in1 op in2 out])) second) ++
      (map (\(Gate in1 op in2 out) -> (in2, [Gate in1 op in2 out])) second)
  in Input first second outMap inMap

pairSwaps (x:y:rest) = (x, y):(y, x):pairSwaps rest
pairSwaps [] = []

doSwap ((x, y):rest) (Gate in1 op in2 out) =
  if x == out then
    Gate in1 op in2 y
  else
    doSwap rest (Gate in1 op in2 out)
doSwap [] item = item

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
instance Eq OpType where
  (==) And And = True
  (==) Or Or = True
  (==) Xor Xor = True
  (==) _ _ = False
instance Eq GateType where
  (==) (Gate in11 op1 in21 out1) (Gate in12 op2 in22 out2) = in11 == in12 && op1 == op2 && in21 == in22 && out1 == out2

parseGate line = let
  [in1, op, in2, _arrow, out] = words line
  in Gate in1 (parseOp op) in2 out

parseOp "OR" = Or
parseOp "XOR" = Xor
parseOp "AND" = And
