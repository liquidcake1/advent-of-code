import sys
import collections
regs = []
for i in range(3):
    regs.append(int(sys.stdin.readline().strip().split(' ')[2]))
regs.append(0) # ip
sys.stdin.readline()
program = list(map(int, sys.stdin.readline().strip().split(' ')[1].split(',')))
print(regs)
print(program)

def combo(operand, regs):
    if operand < 4:
        return operand
    elif operand < 7:
        return regs[operand - 4]
    else:
        raise Exception(operand)

def adv(operand):
    regs[0] = regs[0] // 2**combo(operand, regs)
def bxl(operand):
    regs[1] = regs[1] ^ operand
def bst(operand):
    regs[1] = combo(operand, regs) & 7
def jnz(operand):
    if regs[0] == 0:
        return
    regs[3] = operand - 2
def bxc(operand):
    regs[1] = regs[1] ^ regs[2]
def out(operand):
    output.append(combo(operand, regs) & 7) # should be comma sep
def bdv(operand):
    regs[1] = regs[0] // 2**combo(operand, regs)
def cdv(operand):
    regs[2] = regs[0] // 2**combo(operand, regs)
ops = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]

jumps = [[] for _ in range(8)]
for i, (op, operand) in enumerate(zip(program, program[1:])):
    if op != 3:
        continue
    if operand > len(program) - 1:
        raise Exception("assumption failed")
    jumps[operand].append(i)

print(jumps)

def rev(regs, outi):
    prevs = [regs[3] - 2]
    if regs[3] < len(jumps):
        prevs.extend(jumps[regs[3]]) # TODO: A != 0
    for i in prevs:
        if i < 0:
            continue
        for prevregs, prevouti in infer(i, regs[3], regs, outi):
            if prevouti == 0:
                if prevregs[3] == 0:
                    print(derive(prevregs))
                    continue
            if prevregs[3] < 0:
                continue
            rev(prevregs, prevouti)

DivOutput = collections.namedtuple('DivOutput', 'num div')
XorOutput = collections.namedtuple('XorOutput', 'x y')
ModInput = collections.namedtuple('ModInput', 'x')
ModOutput = collections.namedtuple('ModOutput', 'out inp')
NonZero = collections.namedtuple('NonZero', 'x')

def derive(regs):
    print('derive', regs[0])
    if not verify(orig_regs[1], regs[1]):
        return
    if not verify(orig_regs[2], regs[2]):
        return
    #return derive_one(regs[0])

def verify(expect, constraint):
    print("verify", constraint)
    return
    if isinstance(constraint, DivOutput):
        if not isinstance(constraint.div, int):
            raise Exception(f"DivOutput has {constraint.div}")
        print(constraint.div)
    return True

def infer(source, dest, regs, outi):
    print('infer', source, dest, regs, outi)
    prevregs = list(regs)
    prevregs[3] = source
    op = program[source]
    operand = program[source + 1]
    if op == 0:
        prevregs[0] = DivOutput(regs[0], combo(operand, regs))
        yield prevregs, outi
    elif op == 1:
        prevregs[1] = XorOutput(operand, regs[1])
        yield prevregs, outi
    elif op == 2:
        prevregs[1] = ModInput(combo(operand, regs))
        yield prevregs, outi
    elif op == 3:
        if dest == operand:
            prevregs[0] = NonZero(regs[0])
            yield prevregs, outi
        if dest == source + 2:
            prevregs[0] = 0
            yield prevregs, outi
    elif op == 4:
        prevregs[1] = XorOutput(regs[1], regs[2])
        yield prevregs, outi
    elif op == 5:
        if operand < 4 and operand == outi:
            yield prevregs, outi - 1
        if 4 <= operand < 7:
            print('outi', outi)
            prevregs[operand - 4] = ModOutput(program[outi], regs[operand - 4])
            yield prevregs, outi - 1
    elif op == 6:
        prevregs[1] = DivOutput(regs[0], combo(operand, regs))
        yield prevregs, outi
    elif op == 7:
        prevregs[2] = DivOutput(regs[0], combo(operand, regs))
        yield prevregs, outi

orig_regs = list(regs)
finalregs = [None] * 3 + [len(program)]
regs[3] = len(program)
#rev(finalregs, len(program) - 1)
finalregs = [None] * 3 + [len(program) - 1]
#rev(finalregs, len(program) - 1)

print(0 + 3 * 2**3 + 4 * 2 ** 6 + 5 * 2 ** 9 + 3 * 2 ** 12)

def run(aval):
    global regs
    regs = list(orig_regs)
    regs[0] = aval
    global output
    output = []
    steps = 0
    while regs[3] < len(program):
        op = ops[program[regs[3]]]
        op(program[regs[3]+1])
        regs[3] += 2
        steps = steps + 1
    return output

answers = set()

def search(n, depth):
    if depth > 20:
        return
    for i in range(2**9 if depth == 0 else 2**3):
        aval = (n & ((2 << (3*depth)) -1)) + (i << (3 * depth))
        if answers and aval > min(answers):
            continue
        out = run(aval)
        if out[:max(0,depth-1)] == program[:max(0,depth-1)]:
            if out == program:
                answers.add(aval)
                print(aval, out, min(answers))
            search(aval, depth + 1)

search(0, 0)
print(min(answers))
