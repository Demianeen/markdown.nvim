local ts = vim.treesitter

local M = {}

--- Finds a tree from `trees` contained within the `node`.
---@param trees TSTree[]
---@param node TSNode
---@return TSTree|nil
function M.find_tree_in_node(trees, node)
	for _, t in pairs(trees) do
		if ts.node_contains(node, { t:root():range() }) then
			return t
		end
	end
end

--- Determines if the `node` has an ancestor of one of the provided `types`.
---@param node TSNode
---@param types string[]
---@return boolean
function M.is_contained_by_any_of(node, types)
	local p = node:parent()
	while p ~= nil do
		for _, type in pairs(types) do
			if p:type() == type then
				return true
			end
		end
		p = p:parent()
	end
	return false
end

--- Gets the number of `node`'s children that satisfy the provided `predicate`.
---@param node TSNode
---@param predicate fun(child: TSNode): boolean
---@return integer
function M.child_count(node, predicate)
	local count = 0
	for child in node:iter_children() do
		if predicate(child) then
			count = count + 1
		end
	end

	return count
end

--- Gets the smallest node of the given type based on the provided options.
---@param type string Type of node to get
---@param opts table|nil `vim.treesitter.get_node` opts
---@return TSNode|nil
---
---@see vim.treesitter.get_node
function M.get_node_of_type(type, opts)
	local node = ts.get_node(opts)
	while node ~= nil and node:type() ~= type do
		node = node:parent()
	end
	return node
end

--- Determines if the `node` has the same type as its immediate parent.
---@param node TSNode
---@return boolean
function M.has_parent_type(node)
	local parent = node:parent()
	return parent and node:type() == parent:type()
end

--- Determines if the `node` spans the inner range of its immediate parent.
---@param node TSNode
---@param inner_col_offset? integer `1` if not provided
---@return boolean
---
--- The inner column offset is used to narrow the subrange of the parent checked. For example, if
--- the node's range is `{ 0, 2, 1, 8 }` and its parent range is `{ 0, 0, 1, 10 }`, this will return
--- true given an offset of `2`.
function M.spans_parent_range(node, inner_col_offset)
	local parent = node:parent()
	if parent == nil then
		return false
	end

	local range = { node:range() }
	local parent_range = { parent:range() }

	inner_col_offset = inner_col_offset or 1
	return range[1] == parent_range[1] and range[3] == parent_range[3]
			and range[2] == parent_range[2] + inner_col_offset
			and range[4] == parent_range[4] - inner_col_offset
end

return M
