-- YAML language server
-- https://github.com/redhat-developer/yaml-language-server
return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git" },
	settings = {
		yaml = {
			schemas = {
				kubernetes = {
					"*namespace*.yaml",
					"*pod*.yaml",
					"*deploy*.yaml",
					"*daemonset*.yaml",
					"*statefulset*.yaml",
					"*service*.yaml",
					"*ingress*.yaml",
					"*configmap*.yaml",
					"*secret*.yaml",
					"*hpa*.yaml",
					"*pv*.yaml",
					"*cronjob*.yaml",
					"*job*.yaml",
				},
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
				["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
				["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj/application_v1alpha1.json"] = "*application*.{yml,yaml}",
				["https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrelease-helm-v2beta1.json"] = "*helmrelease*.{yml,yaml}",
				["https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrepository-source-v1beta1.json"] = "*helmrepository*.{yml.yaml}",
			},
		},
	},
}
