local tables = {} -- tables that may be cleaned have to be kept here
local tables_to_clean = {} -- list of tables by name (string) that may be reset to {} after a timeout

local bit_band = bit.band
local bit_bor = bit.bor
local bit_lshift = bit.lshift
local bit_rshift = bit.rshift

local string_byte = string.byte
local string_char = string.char
local string_len = string.len
local string_sub = string.sub

local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove

local LibCompress = { _version = "revision 83" }

--[[ local function setCleanupTables(...)
	timeout = 15 -- empty tables after 15 seconds
	if not LibCompress.frame:IsShown() then
		LibCompress.frame:Show()
	end
	for i = 1, select("#",...) do
		tables_to_clean[(select(i, ...))] = true
	end
end ]]--
----------------------------------------------------------------------
----------------------------------------------------------------------
--
-- compression algorithms

--------------------------------------------------------------------------------
-- Huffman codec
-- implemented by Galmok of European Stormrage (Horde), galmok@gmail.com

local function addCode(tree, bcode, length)
	if tree then
		tree.bcode = bcode
		tree.blength = length
		if tree.c1 then
			addCode(tree.c1, bit_bor(bcode, bit_lshift(1, length)), length + 1)
		end
		if tree.c2 then
			addCode(tree.c2, bcode, length + 1)
		end
	end
end

local function escape_code(code, length)
	local escaped_code = 0
	local b
	local l = 0
	for i = length -1, 0, - 1 do
		b = bit_band(code, bit_lshift(1, i)) == 0 and 0 or 1
		escaped_code = bit_lshift(escaped_code, 1 + b) + b
		l = l + b
	end
	if length + l > 32 then
		return nil, "escape overflow ("..(length + l)..")"
	end
	return escaped_code, length + l
end

tables.Huffman_compressed = {}
tables.Huffman_large_compressed = {}

local compressed_size = 0
local remainder
local remainder_length
local function addBits(tbl, code, length)
	if remainder_length+length >= 32 then
		-- we have at least 4 bytes to store; bulk it
		remainder = remainder + bit_lshift(code, remainder_length) -- this overflows! Top part of code is lost (but we handle it below)
		-- remainder now holds 4 full bytes to store. So lets do it.
		compressed_size = compressed_size + 1
		tbl[compressed_size] = string_char(bit_band(remainder, 255)) ..
			string_char(bit_band(bit_rshift(remainder, 8), 255)) ..
			string_char(bit_band(bit_rshift(remainder, 16), 255)) ..
			string_char(bit_band(bit_rshift(remainder, 24), 255))
		remainder = 0
		code = bit_rshift(code, 32 - remainder_length)
		length =  remainder_length + length - 32
		remainder_length = 0
	end
	if remainder_length+length >= 16 then
		-- we have at least 2 bytes to store; bulk it
		remainder = remainder + bit_lshift(code, remainder_length)
		remainder_length = length + remainder_length
		-- remainder now holds at least 2 full bytes to store. So lets do it.
		compressed_size = compressed_size + 1
		tbl[compressed_size] = string_char(bit_band(remainder, 255)) .. string_char(bit_band(bit_rshift(remainder, 8), 255))
		remainder = bit_rshift(remainder, 16)
		code = remainder
		length = remainder_length - 16
		remainder = 0
		remainder_length = 0
	end
	remainder = remainder + bit_lshift(code, remainder_length)
	remainder_length = length + remainder_length
	if remainder_length >= 8 then
		compressed_size = compressed_size + 1
		tbl[compressed_size] = string_char(bit_band(remainder, 255))
		remainder = bit_rshift(remainder, 8)
		remainder_length = remainder_length -8
	end
end

-- word size for this huffman algorithm is 8 bits (1 byte).
-- this means the best compression is representing 1 byte with 1 bit, i.e. compress to 0.125 of original size.
function LibCompress.CompressHuffman(uncompressed)
	if type(uncompressed) ~= "string" then
		return nil, "Can only compress strings"
	end
	if #uncompressed == 0 then
		return "\001"
	end

	-- make histogram
	local hist = {}
	-- don't have to use all data to make the histogram
	local uncompressed_size = string_len(uncompressed)
	local c
	for i = 1, uncompressed_size do
		c = string_byte(uncompressed, i)
		hist[c] = (hist[c] or 0) + 1
	end

	--Start with as many leaves as there are symbols.
	local leafs = {}
	local leaf
	local symbols = {}
	for symbol, weight in pairs(hist) do
		leaf = { symbol=string_char(symbol), weight=weight }
		symbols[symbol] = leaf
		table_insert(leafs, leaf)
	end

	-- Enqueue all leaf nodes into the first queue (by probability in increasing order,
	-- so that the least likely item is in the head of the queue).
	table.sort(leafs, function(a, b)
		if a.weight < b.weight then
			return true
		elseif a.weight > b.weight then
			return false
		else
			return nil
		end
	end)

	local nLeafs = #leafs

	-- create tree
	local huff = {}
	--While there is more than one node in the queues:
	local length, height, li, hi, leaf1, leaf2
	local newNode
	while (#leafs + #huff > 1) do
		-- Dequeue the two nodes with the lowest weight.
		-- Dequeue first
		if not next(huff) then
			li, leaf1 = next(leafs)
			table_remove(leafs, li)
		elseif not next(leafs) then
			hi, leaf1 = next(huff)
			table_remove(huff, hi)
		else
			li, length = next(leafs)
			hi, height = next(huff)
			if length.weight <= height.weight then
				leaf1 = length
				table_remove(leafs, li)
			else
				leaf1 = height
				table_remove(huff, hi)
			end
		end

		-- Dequeue second
		if not next(huff) then
			li, leaf2 = next(leafs)
			table_remove(leafs, li)
		elseif not next(leafs) then
			hi, leaf2 = next(huff)
			table_remove(huff, hi)
		else
			li, length = next(leafs)
			hi, height = next(huff)
			if length.weight <= height.weight then
				leaf2 = length
				table_remove(leafs, li)
			else
				leaf2 = height
				table_remove(huff, hi)
			end
		end

		--Create a new internal node, with the two just-removed nodes as children (either node can be either child) and the sum of their weights as the new weight.
		newNode = {
			c1 = leaf1,
			c2 = leaf2,
			weight = leaf1.weight + leaf2.weight
		}
		table_insert(huff,newNode)
	end

	if #leafs > 0 then
		li, length = next(leafs)
		table_insert(huff, length)
		table_remove(leafs, li)
	end
	huff = huff[1]

	-- assign codes to each symbol
	-- c1 = "0", c2 = "1"
	-- As a common convention, bit '0' represents following the left child and bit '1' represents following the right child.
	-- c1 = left, c2 = right

	addCode(huff, 0, 0)
	if huff then
		huff.bcode = 0
		huff.blength = 1
	end

	-- READING
	-- bitfield = 0
	-- bitfield_len = 0
	-- read byte1
	-- bitfield = bitfield + bit_lshift(byte1, bitfield_len)
	-- bitfield_len = bitfield_len + 8
	-- read byte2
	-- bitfield = bitfield + bit_lshift(byte2, bitfield_len)
	-- bitfield_len = bitfield_len + 8
	-- (use 5 bits)
	--	word = bit_band( bitfield, bit_lshift(1,5)-1)
	--	bitfield = bit_rshift( bitfield, 5)
	--	bitfield_len = bitfield_len - 5
	-- read byte3
	-- bitfield = bitfield + bit_lshift(byte3, bitfield_len)
	-- bitfield_len = bitfield_len + 8

	-- WRITING
	remainder = 0
	remainder_length = 0

	local compressed = tables.Huffman_compressed
	--compressed_size = 0

	-- first byte is version info. 0 = uncompressed, 1 = 8 - bit word huffman compressed
	compressed[1] = "\003"

	-- Header: byte 0 = #leafs, bytes 1-3 = size of uncompressed data
	-- max 2^24 bytes
	length = string_len(uncompressed)
	compressed[2] = string_char(bit_band(nLeafs -1, 255))	-- number of leafs
	compressed[3] = string_char(bit_band(length, 255))			-- bit 0-7
	compressed[4] = string_char(bit_band(bit_rshift(length, 8), 255))	-- bit 8-15
	compressed[5] = string_char(bit_band(bit_rshift(length, 16), 255))	-- bit 16-23
	compressed_size = 5

	-- create symbol/code map
	local escaped_code, escaped_code_len, success, msg
	for symbol, leaf in pairs(symbols) do
		addBits(compressed, symbol, 8)
		escaped_code, escaped_code_len = escape_code(leaf.bcode, leaf.blength)
		if not escaped_code then
			return nil, escaped_code_len
		end
		addBits(compressed, escaped_code, escaped_code_len)
		addBits(compressed, 3, 2)
	end

	-- create huffman code
	local large_compressed = tables.Huffman_large_compressed
	local large_compressed_size = 0
	local ulimit
	for i = 1, length, 200 do
		ulimit = length < (i + 199) and length or (i + 199)

		for sub_i = i, ulimit do
			c = string_byte(uncompressed, sub_i)
			addBits(compressed, symbols[c].bcode, symbols[c].blength)
		end

		large_compressed_size = large_compressed_size + 1
		large_compressed[large_compressed_size] = table_concat(compressed, "", 1, compressed_size)
		compressed_size = 0
	end

	-- add remaining bits (if any)
	if remainder_length > 0 then
		large_compressed_size = large_compressed_size + 1
		large_compressed[large_compressed_size] = string_char(remainder)
	end
	local compressed_string = table_concat(large_compressed, "", 1, large_compressed_size)

	-- is compression worth it? If not, return uncompressed data.
	if (#uncompressed + 1) <= #compressed_string then
		return "\001"..uncompressed
	end

	--setCleanupTables("Huffman_compressed", "Huffman_large_compressed")
	return compressed_string
end

-- lookuptable (cached between calls)
local lshiftMask = {}
setmetatable(lshiftMask, {
	__index = function (t, k)
		local v = bit_lshift(1, k)
		rawset(t, k, v)
		return v
	end
})

-- lookuptable (cached between calls)
local lshiftMinusOneMask = {}
setmetatable(lshiftMinusOneMask, {
	__index = function (t, k)
		local v = bit_lshift(1, k) -  1
		rawset(t, k, v)
		return v
	end
})

local function bor64(valueA_high, valueA, valueB_high, valueB)
	return bit_bor(valueA_high, valueB_high),
		bit_bor(valueA, valueB)
end

local function band64(valueA_high, valueA, valueB_high, valueB)
	return bit_band(valueA_high, valueB_high),
		bit_band(valueA, valueB)
end

local function lshift64(value_high, value, lshift_amount)
	if lshift_amount == 0 then
		return value_high, value
	end
	if lshift_amount >= 64 then
		return 0, 0
	end
	if lshift_amount < 32 then
		return bit_bor(bit_lshift(value_high, lshift_amount), bit_rshift(value, 32-lshift_amount)),
			bit_lshift(value, lshift_amount)
	end
	-- 32-63 bit shift
	return bit_lshift(value, lshift_amount), -- builtin modulus 32 on shift amount
		0
end

local function rshift64(value_high, value, rshift_amount)
	if rshift_amount == 0 then
		return value_high, value
	end
	if rshift_amount >= 64 then
		return 0, 0
	end
	if rshift_amount < 32 then
		return bit_rshift(value_high, rshift_amount),
			bit_bor(bit_lshift(value_high, 32-rshift_amount), bit_rshift(value, rshift_amount))
	end
	-- 32-63 bit shift
	return 0,
		bit_rshift(value_high, rshift_amount)
end

local function getCode2(bitfield_high, bitfield, field_len)
	if field_len >= 2 then
		-- [bitfield_high..bitfield]: bit 0 is right most in bitfield. bit <field_len-1> is left most in bitfield_high
		local b1, b2, remainder_high, remainder
		for i = 0, field_len - 2 do
			b1 = i <= 31 and bit_band(bitfield, bit_lshift(1, i)) or bit_band(bitfield_high, bit_lshift(1, i)) -- for shifts, 32 = 0 (5 bit used)
			b2 = (i+1) <= 31 and bit_band(bitfield, bit_lshift(1, i+1)) or bit_band(bitfield_high, bit_lshift(1, i+1))
			if not (b1 == 0) and not (b2 == 0) then
				-- found 2 bits set right after each other (stop bits) with i pointing at the first stop bit
				-- return the two bitfields separated by the two stopbits (3 values for each: bitfield_high, bitfield, field_len)
				-- bits left: field_len - (i+2)
				remainder_high, remainder = rshift64(bitfield_high, bitfield, i+2)
				-- first bitfield is the lower part
				return (i-1) >= 32 and bit_band(bitfield_high, bit_lshift(1, i) - 1) or 0,
					i >= 32 and bitfield or bit_band(bitfield, bit_lshift(1, i) - 1),
					i,
					remainder_high,
					remainder,
					field_len-(i+2)
			end
		end
	end
	return nil
end

local function unescape_code(code, code_len)
	local unescaped_code = 0
	local b
	local l = 0
	local i = 0
	while i < code_len do
		b = bit_band( code, lshiftMask[i])
		if not (b == 0) then
			unescaped_code = bit_bor(unescaped_code, lshiftMask[l])
			i = i + 1
		end
		i = i + 1
		l = l + 1
	end
	return unescaped_code, l
end

tables.Huffman_uncompressed = {}
tables.Huffman_large_uncompressed = {} -- will always be as big as the largest string ever decompressed. Bad, but clearing it every time takes precious time.

function LibCompress.DecompressHuffman(compressed)
	if not type(compressed) == "string" then
		return nil, "Can only uncompress strings"
	end

	local compressed_size = #compressed
	--decode header
	local info_byte = string_byte(compressed)
	-- is data compressed
	if info_byte == 1 then
		return compressed:sub(2) --return uncompressed data
	end
	if not (info_byte == 3) then
		return nil, "Can only decompress Huffman compressed data ("..tostring(info_byte)..")"
	end

	local num_symbols = string_byte(string_sub(compressed, 2, 2)) + 1
	local c0 = string_byte(string_sub(compressed, 3, 3))
	local c1 = string_byte(string_sub(compressed, 4, 4))
	local c2 = string_byte(string_sub(compressed, 5, 5))
	local orig_size = c2 * 65536 + c1 * 256 + c0
	if orig_size == 0 then
		return ""
	end

	-- decode code -> symbol map
	local bitfield = 0
	local bitfield_high = 0
	local bitfield_len = 0
	local map = {} -- only table not reused in Huffman decode.
	setmetatable(map, {
		__index = function (t, k)
			local v = {}
			rawset(t, k, v)
			return v
		end
	})

	local i = 6 -- byte 1-5 are header bytes
	local c, cl
	local minCodeLen = 1000
	local maxCodeLen = 0
	local symbol, code_high, code, code_len, temp_high, temp, _bitfield_high, _bitfield, _bitfield_len
	local n = 0
	local state = 0 -- 0 = get symbol (8 bits),  1 = get code (varying bits, ends with 2 bits set)
	while n < num_symbols do
		if i > compressed_size then
			return nil, "Cannot decode map"
		end

		c = string_byte(compressed, i)
		temp_high, temp = lshift64(0, c, bitfield_len)
		bitfield_high, bitfield = bor64(bitfield_high, bitfield, temp_high, temp)
		bitfield_len = bitfield_len + 8

		if state == 0 then
			symbol = bit_band(bitfield, 255)
			bitfield_high, bitfield = rshift64(bitfield_high, bitfield, 8)
			bitfield_len = bitfield_len - 8
			state = 1 -- search for code now
		else
			code_high, code, code_len, _bitfield_high, _bitfield, _bitfield_len = getCode2(bitfield_high, bitfield, bitfield_len)
			if code_high then
				bitfield_high, bitfield, bitfield_len = _bitfield_high, _bitfield, _bitfield_len
				if code_len > 32 then
					return nil, "Unsupported symbol code length ("..code_len..")"
				end
				c, cl = unescape_code(code, code_len)
				map[cl][c] = string_char(symbol)
				minCodeLen = cl < minCodeLen and cl or minCodeLen
				maxCodeLen = cl > maxCodeLen and cl or maxCodeLen
				--print("symbol: "..string_char(symbol).."  code: "..tobinary(c, cl))
				n = n + 1
				state = 0 -- search for next symbol (if any)
			end
		end
		i = i + 1
	end

	-- don't create new subtables for entries not in the map. Waste of space.
	-- But do return an empty table to prevent runtime errors. (instead of returning nil)
	local mt = {}
	setmetatable(map, {
		__index = function (t, k)
			return mt
		end
	})

	local uncompressed = tables.Huffman_uncompressed
	local large_uncompressed = tables.Huffman_large_uncompressed
	local uncompressed_size = 0
	local large_uncompressed_size = 0
	local test_code
	local test_code_len = minCodeLen
	local dec_size = 0
	compressed_size = compressed_size + 1
	local temp_limit = 200 -- first limit of uncompressed data. large_uncompressed will hold strings of length 200
	temp_limit = temp_limit > orig_size and orig_size or temp_limit

	while true do
		if test_code_len <= bitfield_len then
			test_code = bit_band( bitfield, lshiftMinusOneMask[test_code_len])
			symbol = map[test_code_len][test_code]

			if symbol then
				uncompressed_size = uncompressed_size + 1
				uncompressed[uncompressed_size] = symbol
				dec_size = dec_size + 1
				if dec_size >= temp_limit then
					if dec_size >= orig_size then -- checked here for speed reasons
						break
					end
					-- process compressed bytes in smaller chunks
					large_uncompressed_size = large_uncompressed_size + 1
					large_uncompressed[large_uncompressed_size] = table_concat(uncompressed, "", 1, uncompressed_size)
					uncompressed_size = 0
					temp_limit = temp_limit + 200 -- repeated chunk size is 200 uncompressed bytes
					temp_limit = temp_limit > orig_size and orig_size or temp_limit
				end

				bitfield = bit_rshift(bitfield, test_code_len)
				bitfield_len = bitfield_len - test_code_len
				test_code_len = minCodeLen
			else
				test_code_len = test_code_len + 1
				if test_code_len > maxCodeLen then
					return nil, "Decompression error at "..tostring(i).."/"..tostring(#compressed)
				end
			end
		else
			c = string_byte(compressed, i)
			bitfield = bitfield + bit_lshift(c or 0, bitfield_len)
			bitfield_len = bitfield_len + 8
			if i > compressed_size then
				break
			end
			i = i + 1
		end
	end

	--setCleanupTables("Huffman_uncompressed", "Huffman_large_uncompressed")
	return table_concat(large_uncompressed, "", 1, large_uncompressed_size)..table_concat(uncompressed, "", 1, uncompressed_size)
end

return LibCompress