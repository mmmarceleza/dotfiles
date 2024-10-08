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

	-- Deployment manifest
	s(
		"deployment",
		fmt(
			[[
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: {}
          namespace: {}
          labels:
            app: {}
        spec:
          replicas: 1
          selector:
            matchLabels:
              app: {}
          template:
            metadata:
              labels:
                app: {}
            spec:
              containers:
                - image: {}
                  name: {}
    ]],
			{
				i(1, "<Deploy Name>"),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				i(2, "<Image>"),
				rep(1),
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

	-- nodeAffinity required
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

	-- nodeAffinity prefered
	s(
		"nodeaffinity-prefered",
		fmt(
			[[
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              preference:
                matchExpressions:
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

	-- podAffinity prefered
	s(
		"podAffinity-prefered",
		fmt(
			[[
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: {}
                    operator: In
                    values:
                    - {}
              topologyKey: topology.kubernetes.io/zone
    ]],
			{
				i(1, "<Key>"),
				i(2, "<Value>"),
			}
		)
	),

	-- podAffinity required
	s(
		"podAffinity-required",
		fmt(
			[[
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: {}
                operator: In
                values:
                - {}
            topologyKey: topology.kubernetes.io/zone
    ]],
			{
				i(1, "<Key>"),
				i(2, "<Value>"),
			}
		)
	),

	-- network policy example
	s(
		"networkpolicy",
		fmt(
			[[
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: {}
        namespace: {}
      spec:
        podSelector:
          matchLabels:
            role: db
        policyTypes:
        - Ingress
        - Egress
        ingress:
        - from:
          - ipBlock:
              cidr: 172.17.0.0/16
              except:
              - 172.17.1.0/24
          - namespaceSelector:
              matchLabels:
                project: myproject
          - podSelector:
              matchLabels:
                role: frontend
          ports:
          - protocol: TCP
            port: 6379
        egress:
        - to:
          - ipBlock:
              cidr: 10.0.0.0/24
          ports:
          - protocol: TCP
            port: 5978
    ]],
			{
				i(1, "<Name>"),
				i(2, "<Namespace>"),
			}
		)
	),
})
