local Utils = {}

local V1 = vmath.vector3(0)
local V2 = vmath.vector3(0)

local HASH_DRAW_LINE = hash("draw_line")
local MSD_DRAW_LINE_COLOR = vmath.vector4(0)

local MSD_DRAW_LINE = {
	start_point = V1,
	end_point = V2,
	color = MSD_DRAW_LINE_COLOR
}

function Utils.draw_aabb(left, top, right, bottom, color)
	MSD_DRAW_LINE_COLOR.x = color.x
	MSD_DRAW_LINE_COLOR.y = color.y
	MSD_DRAW_LINE_COLOR.z = color.z
	MSD_DRAW_LINE_COLOR.w = color.w

	V1.x, V1.y = left, top
	V2.x, V2.y = right, top
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = right, top
	V2.x, V2.y = right, bottom
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = right, bottom
	V2.x, V2.y = left, bottom
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = left, bottom
	V2.x, V2.y = left, top
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
end

function Utils.draw_aabb3d(x1, y1, z1, x2, y2, z2, color)
	MSD_DRAW_LINE_COLOR.x = color.x
	MSD_DRAW_LINE_COLOR.y = color.y
	MSD_DRAW_LINE_COLOR.z = color.z
	MSD_DRAW_LINE_COLOR.w = color.w

	--bottom
	V1.x, V1.y, V1.z = x1, y1, z1
	V2.x, V2.y, V2.z = x1, y1, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x1, y1, z1
	V2.x, V2.y, V2.z = x2, y1, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x2, y1, z2
	V2.x, V2.y, V2.z = x1, y1, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x2, y1, z2
	V2.x, V2.y, V2.z = x2, y1, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	--top
	V1.x, V1.y, V1.z = x1, y2, z1
	V2.x, V2.y, V2.z = x1, y2, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x1, y2, z1
	V2.x, V2.y, V2.z = x2, y2, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x2, y2, z2
	V2.x, V2.y, V2.z = x1, y2, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = x2, y2, z2
	V2.x, V2.y, V2.z = x2, y2, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	--edges

	V1.x, V1.y, V1.z = x1, y1, z1
	V2.x, V2.y, V2.z = x1, y2, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
	V1.x, V1.y, V1.z = x1, y1, z2
	V2.x, V2.y, V2.z = x1, y2, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
	V1.x, V1.y, V1.z = x2, y1, z1
	V2.x, V2.y, V2.z = x2, y2, z1
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
	V1.x, V1.y, V1.z = x2, y1, z2
	V2.x, V2.y, V2.z = x2, y2, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

end

function Utils.draw_cube(points, color)
	MSD_DRAW_LINE_COLOR.x = color.x
	MSD_DRAW_LINE_COLOR.y = color.y
	MSD_DRAW_LINE_COLOR.z = color.z
	MSD_DRAW_LINE_COLOR.w = color.w

	local p1 = points[1]
	local p2 = points[2]
	local p3 = points[3]
	local p4 = points[4]
	local p5 = points[5]
	local p6 = points[6]
	local p7 = points[7]
	local p8 = points[8]

	--far
	V1.x, V1.y, V1.z = p1.x, p1.y, p1.z
	V2.x, V2.y, V2.z = p2.x, p2.y, p2.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p2.x, p2.y, p2.z
	V2.x, V2.y, V2.z = p3.x, p3.y, p3.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p3.x, p3.y, p3.z
	V2.x, V2.y, V2.z = p4.x, p4.y, p4.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p4.x, p4.y, p4.z
	V2.x, V2.y, V2.z = p1.x, p1.y, p1.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)


	--near
	V1.x, V1.y, V1.z = p5.x, p5.y, p5.z
	V2.x, V2.y, V2.z = p6.x, p6.y, p6.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p6.x, p6.y, p6.z
	V2.x, V2.y, V2.z = p7.x, p7.y, p7.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p7.x, p7.y, p7.z
	V2.x, V2.y, V2.z = p8.x, p8.y, p8.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p8.x, p8.y, p8.z
	V2.x, V2.y, V2.z = p5.x, p5.y, p5.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	--edges
	V1.x, V1.y, V1.z = p1.x, p1.y, p1.z
	V2.x, V2.y, V2.z = p5.x, p5.y, p5.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p2.x, p2.y, p2.z
	V2.x, V2.y, V2.z = p6.x, p6.y, p6.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p3.x, p3.y, p3.z
	V2.x, V2.y, V2.z = p7.x, p7.y, p7.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y, V1.z = p4.x, p4.y, p4.z
	V2.x, V2.y, V2.z = p8.x, p8.y, p8.z
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	--center
	MSD_DRAW_LINE.color.y = 1
	V1.x, V1.y, V1.z = (p1.x +p2.x)/2, (p1.y +p2.y)/2, (p1.z +p2.z)/2
	V2.x, V2.y, V2.z =  (p3.x +p4.x)/2, (p3.y +p4.y)/2, (p3.z +p4.z)/2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
	V1.x, V1.y, V1.z = (p2.x +p3.x)/2, (p2.y +p3.y)/2, (p2.z +p3.z)/2
	V2.x, V2.y, V2.z =  (p1.x +p4.x)/2, (p1.y +p4.y)/2, (p1.z +p4.z)/2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
end

function Utils.draw_line(x1, y1, z1, x2, y2, z2, color)
	MSD_DRAW_LINE_COLOR.x = color.x
	MSD_DRAW_LINE_COLOR.y = color.y
	MSD_DRAW_LINE_COLOR.z = color.z
	MSD_DRAW_LINE_COLOR.w = color.w

	V1.x, V1.y, V1.z = x1, y1, z1
	V2.x, V2.y, V2.z = x2, y2, z2
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
end

return Utils