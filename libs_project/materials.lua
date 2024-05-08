local Materials = {
	materials = {}
}

function Materials.add(id, material)
	assert(not Materials.materials[id], material)
	print("add material:" .. id .. " material:" .. tostring(material))
	Materials.materials[id] = material
end

return Materials
