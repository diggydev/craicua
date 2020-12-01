features = {}
Feature = {}
links = {}

function link(description, action)
   table.insert(links, {description=description, action=action})
end

function Feature:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   o.scenarios = {}
   return o
end

Scenario = {}
function Scenario:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function Scenario:evaluate(statement)
   for statement_key,statement_value in ipairs(links) do
      local text_to_match = string.gsub(statement_value.description,"<>",".+")
      --print("text_to_match "..text_to_match)
      local sargs = {}
      --print("statement "..statement)
      if statement:match(text_to_match) then
	 local index = 1
	 for sarg in string.gmatch(statement, "<.+>") do
	    --print("sarg "..sarg)
	    load("temp="..sarg:sub(2,#sarg-1))()
	    sargs[index]=temp
	    index = index + 1
	 end
	 statement_value.action(self, sargs)
      end
   end
end

function run(scenario)
   scenario:evaluate(scenario.given)
   scenario:evaluate(scenario.when)
   scenario:evaluate(scenario.then_)
end

function craicua_run(stories_file_name)
   local stories_file = io.open(stories_file_name, "r")
   local feature = nil
   local scenario = nil
   while true do
      local line = stories_file:read("l")
      if line == nil then break end
      if "Feature: " == line:sub(1,9) then
	 feature = Feature:new({name=line:sub(10,#line)})
	 table.insert(features, feature)
      elseif "Scenario: " == line:sub(1,10) then
	 scenario = Scenario:new({name=line:sub(11,#line)})
	 table.insert(feature.scenarios, scenario)
      elseif "Given " == line:sub(1,6) then
	 scenario.given = line:sub(7,#line)
      elseif "When " == line:sub(1,5) then
	 scenario.when = line:sub(6,#line)
      elseif "Then " == line:sub(1,5) then
	 scenario.then_ = line:sub(6,#line)
      end
   end

   for feature_key,feature_value in ipairs(features) do
      io.write("=== Feature "..feature_key..": "..feature_value.name.." ===\n")
      local pass_count = 0
      for scenario_key,scenario_value in ipairs(feature_value.scenarios) do
	 local status, retval = pcall(run, scenario_value)
	 if status then
	    pass_count = pass_count + 1
	 else
	    io.write("FAIL: Scenario "..scenario_key..": "..scenario_value.name..
		     "\nGiven "..scenario_value.given..
		     "\nWhen "..scenario_value.when..
		     "\nThen "..scenario_value.then_..
		     "\nResult: "..retval.."\n\n")
	 end
      end
      io.write("Passes: "..pass_count.."/"..#feature_value.scenarios.."\n")
   end
end
