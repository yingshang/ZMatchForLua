local ZMatch = require("ZMatch")
ZMatch.InitTestEnvironment()
-- 测试敏感词检测
local textString = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
textString = [[苍天有井独自空， 星落天川遥映瞳。
小溪流泉映花彩， 松江孤岛一叶枫。
南海涟波潭边杏， 星空野尽明日辉
西塞山野雁自翔， 小桥水泽浸芳园。
武园枯藤空留兰， 李氏眉宇尽是春。]]
-- local textString = ""
ZMatch.TestCheck(textString, 1000, 10)
ZMatch.TestCheck("1咳咳dasdad井空苍1", 1000, 10)
ZMatch.TestCheck("苍井空", 1000, 10)
ZMatch.TestCheck("苍井空1", 1000, 10)
ZMatch.TestCheck("1苍井空", 1000, 10)
ZMatch.TestCheck("1苍井空1", 1000, 10)
ZMatch.TestFilter("心如苍井空似水，意比松岛枫叶飞；窗外武藤兰花香，情似饭岛爱相随", 1000)