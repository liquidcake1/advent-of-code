let lines = readfile("input17.txt")
echo lines
" x, y, lastdir (0=x, 1=y)
let qpos = -1
let queue = {0: [[0, 0, 1], [0, 0, 0]]}
"let shortests = {'0,0,0': 0, '0,0,1': 0}
let shortests = []
let y = 0
while y < len(lines)
	let x = 0
	call add(shortests, [])
	while x < len(lines[y])
		call add(shortests[y], [1000000, 1000000])
		let x += 1
	endwhile
	let y += 1
endwhile
let shortests[0][0][0] = 0
let shortests[0][0][1] = 0
while len(queue) > 0
	let qpos += 1
	if has_key(queue, qpos)
		let head = queue[qpos]
	else
		continue
	endif
	"echo "At" qpos
	while len(head) > 0
		let nxt = remove(head, 0)
		"echo "dequeue" nxt
		if nxt[2] == 0
			let dird = [1, 0]
		else
			let dird = [0, 1]
		endif
		for dirm in [-1, 1]
			let nx = nxt[0]
			let ny = nxt[1]
			let newscore = shortests[ny][nx][nxt[2]]
			if newscore < qpos
				"echo "Repeat!!"
				break
			endif
			for cnt in [1, 2, 3]
				let nx += dird[0] * dirm
				let ny += dird[1] * dirm
				if nx < 0 || ny < 0 || ny >= len(lines) || nx >= len(lines[ny]) 
					"echo "too big" nx ny
					break
				endif
				let newscore += lines[ny][nx]
				let oldscore = shortests[ny][nx][1 - nxt[2]]
				if oldscore > newscore
					"echo "queue" [nx, ny, 1 - nxt[2]] "=" newscore "was" oldscore
					let shortests[ny][nx][1 - nxt[2]] = newscore
					if !has_key(queue, newscore)
						let queue[newscore] = []
					endif
					call add(queue[newscore], [nx, ny, 1 - nxt[2]])
				endif
			endfor
		endfor
	endwhile
	call remove(queue, qpos)
endwhile
echo min(shortests[len(lines)-1][len(lines[len(lines)-1])-1])
let y = 0
while y < len(lines)
	let x = 0
	let l = "| "
	while x < len(lines[y])
       		let l .= printf("%4i,%4i | ", shortests[y][x][0], shortests[y][x][1])
		let x += 1
	endwhile
	"echo l
	let y += 1
endwhile
