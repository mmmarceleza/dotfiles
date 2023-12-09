local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

-- Start Snippets --

ls.add_snippets("all", {

	-- Gitrepository manifest
	s(
		"gitrepo",
		fmt(
			[[
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: GitRepository
    metadata:
      name: {}
      namespace: flux-system
    spec:
      interval: 5m0s
      ref:
        branch: {}
      secretRef:
        name: {}
      url: {} 
    ]],
			{
				i(1, "<Gitrepository Name>"),
				i(2, "<Branch>"),
				i(3, "<Secret Name>"),
				i(4, "<Git URL>"),
			}
		)
	),

	-- Kustomization manifest
	s(
		"kustomization",
		fmt(
			[[
    apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
    kind: Kustomization
    metadata:
      name: {}
      namespace: flux-system
    spec:
      force: false
      interval: 5m0s
      path: {}
      prune: true
      sourceRef:
        kind: GitRepository
        name: {}
        namespace: flux-system
    ]],
			{
				i(1, "<Kustomization Name>"),
				i(2, "<Path>"),
				rep(1),
			}
		)
	),

	-- Helmrelease manifest
	s(
		"helmrelease",
		fmt(
			[[
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: {}
      namespace: flux-system
    spec:
      chart:
        spec:
          chart: {}
          sourceRef:
            kind: HelmRepository
            name: {}
          version: "{}"
      dependsOn: []
      #- name: <dependency release>
      releaseName: {}
      install:
        createNamespace: true
        disableWait: false
        remediation:
          retries: -1
      upgrade:
        disableWait: false
        remediation:
          retries: -1
      interval: 5m
      targetNamespace: {}
      storageNamespace: {}
      values: {{}}
    ]],
			{
				i(1, "<Helmrelease Name>"),
				i(2, "<Chart Name>"),
				i(3, "<Repository Name>"),
				i(4, "<Version>"),
				i(5, "<Release Name>"),
				i(6, "<Target Namespace>"),
				rep(6),
			}
		)
	),

	-- Helmrelease templater manifest
	s(
		"templater",
		fmt(
			[[
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: {}
      namespace: flux-system
    spec:
      chart:
        spec:
          chart: templater
          sourceRef:
            kind: HelmRepository
            name: getupcloud
          version: "1.0.0"
      dependsOn: []
      #- name: <dependency release>
      releaseName: {}
      install:
        createNamespace: true
        disableWait: false
        remediation:
          retries: -1
      upgrade:
        disableWait: false
        remediation:
          retries: -1
      interval: 5m
      targetNamespace: {}
      storageNamespace: {}
      values:
        templates:
        - |-
          # add objects here 
    ]],
			{
				i(1, "<Helmrelease Name>"),
				i(2, "<Release Name>"),
				i(3, "<Target Namespace>"),
				rep(3),
			}
		)
	),

	-- Imagerepository manifest
	s(
		"imagerepository",
		fmt(
			[[
    apiVersion: image.toolkit.fluxcd.io/v1beta2
    kind: ImageRepository
    metadata:
      name: {}
      namespace: flux-system
    spec:
      interval: 5m0s
      image: {}
      secretRef:
        name: {}
    ]],
			{
				i(1, "<ImageRepository Name>"),
				i(2, "<Registry Address>"),
				i(3, "<Secret Name>"),
			}
		)
	),

	-- Imagepolicy manifest
	s(
		"imagepolicy",
		fmt(
			[[
    apiVersion: image.toolkit.fluxcd.io/v1beta2
    kind: ImagePolicy
    metadata:
      name: {}
      namespace: flux-system
    spec:
      imageRepositoryRef:
        name: {}
      policy: # https://fluxcd.io/flux/components/image/imagepolicies/#policy
        semver:
          range: '>=0'
    ]],
			{
				i(1, "<ImagePolicy Name>"),
				i(2, "<imageRepository Name>"),
			}
		)
	),

	-- Imageupdate manifest
	s(
		"imageupdate",
		fmt(
			[[
    apiVersion: image.toolkit.fluxcd.io/v1beta1
    kind: ImageUpdateAutomation
    metadata:
      name: {}
      namespace: flux-system
    spec:
      interval: 5m0s
      sourceRef:
        kind: GitRepository
        name: {}
      git:
        checkout:
          ref:
            branch: {}
        commit:
          author:
            email: {}
            name: FluxCD
          messageTemplate: |-
            Automatic commit from FluxCD: {{range .Updated.Images}}{{println .}}{{end}}

            Automated image update

            Automation name: {{ .AutomationObject }}

            Files:
            {{ range $filename, $_ := .Updated.Files -}}
            - {{ $filename }}
            {{ end -}}

            Objects:
            {{ range $resource, $_ := .Updated.Objects -}}
            - {{ $resource.Kind }} {{ $resource.Name }}
            {{ end -}}

            Images:
            {{ range .Updated.Images -}}
            - {{.}}
            {{ end -}} 
        push:
          branch: {}
      update:
        path: "{}"
        strategy: Setters
    ]],
			{
				i(1, "<ImageUpdate Name>"),
				i(2, "<Gitrepository Name>"),
				i(3, "<Branch Name>"),
				i(4, "<E-mail>"),
				rep(3),
				i(5, "<Path>"),
			}
		)
	),
})
