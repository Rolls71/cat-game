class_name Hex

const axial_directions = [
	[+1, 0], [+1, -1], [0, -1], 
	[-1, 0], [-1, +1], [0, +1], 
]

static func axial_to_oddq(axial):
	var col = axial[0]
	var row = axial[1] + (axial[0] - (axial[0]&1)) / 2
	return Vector2i(col, row)

static func oddq_to_axial(oddq:Vector2i):
	var q = oddq.x
	var r = oddq.y - (oddq.x - (oddq.x&1)) / 2
	return [q, r]

static func axial_direction(direction):
	return axial_directions[direction]

static func axial_add(a, b):
	return [a[0] + b[0], a[1] + b[1]]
	
static func axial_subtract(a, b):
	return [a[0] - b[0], a[1] - b[1]]

static func axial_distance(a, b):
	var vec = axial_subtract(a, b)
	return (abs(vec[0]) +
			abs(vec[0] + vec[1]) +
			abs(vec[1])) / 2
			
static func is_oddq_adjacent(a, b):
	return is_axial_adjacent(oddq_to_axial(a), oddq_to_axial(b))
			
static func is_axial_adjacent(a, b):
	for direction in axial_directions:
		if axial_add(a, direction) == b:
			return true
	return false
