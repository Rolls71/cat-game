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

static func axial_add(axial, vec):
	return [axial[0] + vec[0], axial[1] + vec[1]]
