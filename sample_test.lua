require("craicua")
require("sample_app")

link("a table <>",
      function (scenario,sarg)
	 scenario.table = sarg[1]
      end
)

link("it counts the size",
     function (scenario,sarg)
	scenario.result = table_count(scenario.table)
     end
)


link("the result is <>",
     function (scenario,sarg)
	assert_eq(scenario.result, sarg[1])
     end
)

link("the word <>",
     function (scenario,sarg)
	scenario.word = sarg[1]
     end
)

link("it is split",
     function(scenario,sarg)
	scenario.result = split_word(sarg[1])
     end
)

link("part <> is <>",
     function(scenario,sarg)
	assert_eq(scenario.result[sarg[1]], 3)
     end
)

craicua_run(arg[0])

--[[
Feature: Counting table size
Scenario: Counting a numeric table
Given a table <{1,2,3}>
When it counts the size
Then the result is <3>

Scenario: Counting a string table
Given a table <{"a","b","c","d"}>
When it counts the size
Then the result is <4>

Scenario: Counting an empty table
Given a table <{}>
When it counts the size
Then the result is <0>

Feature: Splitting a word in half (not working yet)
Scenario: A word with an even number of letters
Given the word <bubble>
When it is split
Then part <1> is <bub>
And part <2> is <ble>
--]]

