require("craicua")
require("sample_app")

link("a table {}",
      function (scenario,sarg)
	 scenario.table = sarg[1]
      end
)

link("it counts the size",
     function (scenario,sarg)
	scenario.result = table_count(scenario.table)
     end
)


link("the result is {}",
     function (scenario,sarg)
	assert(scenario.result == sarg[1])
     end
)

craicua_run(arg[0])

--[[
Feature: Counting table size
Scenario: Counting a numeric table
Given a table ={1,2,3}
When it counts the size
Then the result is =3

Scenario: Counting a string table
Given a table ={"a","b","c","d"}
When it counts the size
Then the result is =4

Scenario: Counting an empty table
Given a table ={}
When it counts the size
Then the result is =0
--]]

