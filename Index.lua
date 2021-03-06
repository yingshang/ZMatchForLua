local ZMatch = require("ZMatch")

local zmatch
local t1
local t2
local t3
local count
local r

function InitTestEnvironment()
	zmatch = ZMatch.New()
	t1 = os.clock()
	local c = collectgarbage("count")
	zmatch:BuildTrie()
	local c1 = collectgarbage("count")
	t2 = os.clock()
	print("构建Trie内存:", c1 - c)
	print("构建Trie耗时:", t2 - t1)
	t1 = os.clock()
	local c2 = collectgarbage("count")
	zmatch:BuildAC()
	local c3 = collectgarbage("count")
	t2 = os.clock()
	print("构建AC内存:", c3 - c2)
	print("构建AC耗时:", t2 - t1)
	local count = 0
	for _,_ in pairs(zmatch.originCfg) do
		count = count + 1
	end
	print("敏感词总量", count)
	print("常规词数量", zmatch.singleCount)
	print("带&词数量", #zmatch.multiList)
end
local printLine = function()
	print("----")
end

function TestCheck(text, newWayCount, oldWayCOunt)
	print(string.format("\n\n开始对【%s】进行敏感词检测...", text))
	printLine()
	count = oldWayCOunt
	t2 = os.clock()
	for i=1,count do
		r = zmatch:_CheckAllByTraverse(text)
	end
	t3 = os.clock()
	print(string.format("原始遍历接口%d次全词检测,时间:%f,结果:%s", count, t3 - t2, r and "true" or "false"))
	count = newWayCount
	t2 = os.clock()
	for i=1,count do
		r = zmatch:CheckTextByAC(text)
	end
	t3 = os.clock()
	print(string.format("库接口%d次全词检测,时间:%f,结果:%s", count, t3 - t2, r and "true" or "false"))
	printLine()
	local chars = string.ConvertToCharArray(text)
	t2 = os.clock()
	for i=1,count do
		r = zmatch:_CheckSingleByTrie(chars)
	end
	t3 = os.clock()
	print(string.format("\t%d次常规词Trie检测,时间:%f,结果:%s", count, t3 - t2, r and "true" or "false"))
	t2 = os.clock()
	for i=1,count do
		r = zmatch:_CheckSingleByAC(chars)
	end
	t3 = os.clock()
	print(string.format("\t%d次常规词AC检测,时间:%f,结果:%s", count, t3 - t2, r and "true" or "false"))
	printLine()
	t2 = os.clock()
	for i=1,count do
		r = zmatch:_CheckMultiByTrie(chars)
	end
	t3 = os.clock()
	print(string.format("\t%d次带&词Trie检测,时间%f,结果%s", count, t3 - t2, r and "true" or "false"))
	t2 = os.clock()
	for i=1,count do
		r = zmatch:_CheckMultiByTraverse(text)
	end
	t3 = os.clock()
	print(string.format("\t%d次带&词遍历检测,时间%f,结果%s", count, t3 - t2, r and "true" or "false"))
end

function TestFilter(text, newWayCount, oldWayCOunt)
	count = newWayCount
	t2 = os.clock()
	for i=1,count do
		r = zmatch:FilterText(text)
	end
	t3 = os.clock()
	print(string.format("\n\n%d次敏感词过滤,时间:%f,\n--源:【%s】\n--结果:【%s】", count, t3 - t2, text, r))
	local chars = string.ConvertToCharArray(text)
	t2 = os.clock()
	for i=1,count do
		chars = zmatch:_FilterSingleChars(chars)
	end
	t3 = os.clock()
	print(string.format("\t%d次常规词过滤,时间%f", count, t3 - t2))

	t2 = os.clock()
	for i=1,count do
		chars = zmatch:_FilterMultiChars(chars)
	end
	t3 = os.clock()
	print(string.format("\t%d次带&词过滤,时间%f", count, t3 - t2))
end

-- 检测重复配置
function CheckRepetCfg()
	-- 是否有敏感词没检测出来
	for k,v in pairs(zmatch.originCfg) do
		local r1 = zmatch:CheckTextByAC(v["word"])
		local r2 = zmatch:CheckTextByAC("1"..v["word"])
		local r3 = zmatch:CheckTextByAC(v["word"].."1")
		local r4 = zmatch:CheckTextByAC("1"..v["word"].."1")
		if not (r1 and r2 and r3 and r4) then
			print("敏感词没检测出来:", v["word"])
			return
		end
	end

	-- 遍历,最耗的重复语义检测
	local count = 0
	local sensitiveFunc = function(text)
		return string.split(text, "&")
	end
 	local checkAllByTraverse= function(k,text)
 		local isFirstPrint = false 
 		local firstPrint = function()
 			if not isFirstPrint then
 				isFirstPrint = true
 				print("\n----------------------------------------")
 				print(k, text, "已经涵盖了下面单词意思:")
 			end
 		end
		local sheet = zmatch.originCfg
		local strings = sensitiveFunc(text)
		for k1, item in pairs(sheet) do
			if k1 ~= k then
				local m = true
				for _, w in ipairs(strings) do
					if not string.find(item.word, w, 1, true) then
						m = false
						break
					end
				end
				if m then
					firstPrint()
					print("冗余:", k1, item.word)
					count = count + 1
				end
			end
		end
		return false
	end
	for k,v in pairs(zmatch.originCfg) do
		checkAllByTraverse(k, v.word)
	end
	print(string.format("冗余配置:%d条", count))
end


InitTestEnvironment()
-- 测试敏感词检测
TestCheck("正常说一句话的内容,大概这么长", 1000, 1)
TestCheck("敏感词:苍井空-", 1000, 1)
TestCheck("带&敏感词:kanzhongguo.com", 1000, 1)
local textString = [[长字符串: 苍天有井独自空, 星落天川遥映瞳。
小溪流泉映花彩, 松江孤岛一叶枫。
南海涟波潭边杏, 敏感词1兼职上门
敏感词2裤袜女优, 敏感词3泽铃木麻。
敏感词4费偷窥网, 敏感词5欧美大乳。]]
-- local textString = ""
TestCheck(textString, 1000, 1)
TestFilter("心如苍井空似水,意比松岛枫叶飞。窗外武藤兰花香, 情似饭岛爱相随。咳咳dasdad井空苍苍, 台台ott", 1000, 1)
-- CheckRepetCfg()