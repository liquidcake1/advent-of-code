import sys
regs = []
for i in range(3):
    regs.append(int(sys.stdin.readline().strip().split(' ')[2]))
regs.append(0) # ip
sys.stdin.readline()
program = list(map(int, sys.stdin.readline().strip().split(' ')[1].split(',')))
print(regs)
print(program)

def combo(operand):
    if operand < 4:
        return operand
    elif operand < 7:
        return regs[operand - 4]
    else:
        raise Exception(operand)

def adv(operand):
    regs[0] = regs[0] // 2**combo(operand)
def bxl(operand):
    regs[1] = regs[1] ^ operand
def bst(operand):
    regs[1] = combo(operand) & 7
def jnz(operand):
    if regs[0] == 0:
        return
    regs[3] = operand - 2
def bxc(operand):
    regs[1] = regs[1] ^ regs[2]
def out(operand):
    output.append(combo(operand) & 7) # should be comma sep
def bdv(operand):
    regs[1] = regs[0] // 2**combo(operand)
def cdv(operand):
    regs[2] = regs[0] // 2**combo(operand)
ops = [adv, bxl, bst, jnz, bxc, out, bdv, cdv]
output = []

while regs[3] < len(program):
    op = ops[program[regs[3]]]
    print(op, ops)
    op(program[regs[3]+1])
    regs[3] += 2

print(','.join(map(str,output)))
