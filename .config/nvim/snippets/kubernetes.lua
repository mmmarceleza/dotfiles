local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

-- Start Snippets --

ls.add_snippets("all", {

	-- Pod manifest
	s(
		"pod",
		fmt(
			[[
    apiVersion: v1
    kind: Pod
    metadata:
      name: {}
    spec:
      containers:
      - name: {}
        image: {}
    ]],
			{
				i(1, "<Pod Name>"),
				rep(1),
				i(2, "<Image>"),
			}
		)
	),

	-- Toleration
	s(
		"toleration",
		fmt(
			[[
      tolerations:
      - key: "{}"
        operator: "Equal"
        value: "{}"
        effect: "NoSchedule"
    ]],
			{
				i(1, "dedicated"),
				i(2, "<Value>"),
			}
		)
	),

	-- nodeAffinity
	s(
		"nodeaffinity-required",
		fmt(
			[[
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: {}
                operator: In
                values:
                - {}
    ]],
			{
				i(1, "role"),
				i(2, "<Value>"),
			}
		)
	),
})
