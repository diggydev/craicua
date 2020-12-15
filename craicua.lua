features = {}
Feature = {}
links = {}
keywords = {"given","when","then","and"}

function safe(value)
   if value==nil then
      return ""
   else
      return value
   end
end

function safe_len(table)
   return #safe_table(table)
end

function safe_table(table)
   if table==nil then
      return {}
   else
      return table
   end
end

function assert_eq(value1, value2)
   assert(value1 == value2, "Expected ["..safe(value1).."] Actual ["..safe(value2).."]")
end

function assert_table_eq(table1, table2)
   assert(safe_len(table1) == safe_len(table2), "Expected size ["..safe_len(table1).."] Actual size ["..safe_len(table2).."]")
   for key,value in ipairs(table1) do
      assert(value == safe_table(table2)[key], "Key ["..key.."] Expected ["..value.."] Actual ["..safe_table(table2)[key].."]")
   end
end

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
   o.statements = {}
   return o
end

function Scenario:evaluate(statement)
   for statement_key,statement_value in ipairs(links) do
      local text_to_match = string.gsub(statement_value.description,"<>",".+")
      local sargs = {}
      if statement:match(text_to_match) then
	 local index = 1
	 for sarg in string.gmatch(statement, "<.+>") do
	    load("temp="..sarg:sub(2,#sarg-1))()
	    sargs[index]=temp
	    index = index + 1
	 end
	 in_evaluation = statement
	 statement_value.action(self, sargs)
	 return
      end
   end
   error("Failed to evaluate '"..statement.."'")
end

function run(scenario)
   for statement_key,statement in ipairs(scenario.statements) do
      scenario:evaluate(statement)
   end
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
      else
	 for key,keyword in ipairs(keywords) do
	    if keyword == line:sub(1,#keyword):lower() then
	       table.insert(scenario.statements, line:sub(#keyword+2,#line))
	    end
	 end
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
		     "\n"..in_evaluation..
		     "\nResult: "..retval.."\n\n")
	 end
      end
      io.write("Passes: "..pass_count.."/"..#feature_value.scenarios.."\n")
   end
end
