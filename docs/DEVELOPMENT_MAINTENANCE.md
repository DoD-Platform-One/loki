# To upgrade the Loki Package

Check the [upstream changelog](https://grafana.com/docs/loki/latest/upgrading/) and the [helm chart upgrade notes](https://github.com/grafana/helm-charts/tree/main/charts/loki#upgrading).

# Upgrading

## Update dependencies  
  
Typically, the `--strategy=force-delete-replace` is useful to "heavy handidly" bring in dep changes which may need to be reviewed. 
```
cd chart/deps && \
kpt pkg update minio && \
kpt pkg update loki --strategy=force-delete-replace && \
kpt pkg update loki-simple-scalable --strategy=force-delete-replace ;
```

## Update binaries

Pull assets and commit the binaries as well as the Chart.lock file that was generated.
```
helm dependency update ./chart
``` 

## Update chart

```chart/Chart.yaml```

- update loki `version` and `appVersion`
- increment Big Bang version suffix to chart version

```chart/values.yaml```

- Update `tag` for the new version.

```chart/templates/bigbang/*```

- Add/update Big Bang network policies _if applicable_.

```chart/tests/*```

- add cypress testing configuration and/or tests _if necessary_.

# Modifications made to upstream
This is a high-level list of modifitations that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

```chart/values.yaml```
- Review both the `loki` & `loki-simple-scalable` sub-chart values and bring any new important and relevant values to our `chart/values.yaml`. If it's a new config item/option first add it to `global` if it's a template or paste it directly in our `global.config` table value.

```chart/deps/loki-simple-scalable/templates/read/statefulset-read.yaml```
- Ensure the `config` volume on line 117 also has an `else if` under the existing secret def to check for our `global.existingSecretForConfig` value.
```
          {{- else if .Values.global.existingSecretForConfig }}
          secret:
            secretName: {{ .Values.global.existingSecretForConfig }}
```

```chart/deps/loki-simple-scalable/templates/write/statefulset-write.yaml```
- Ensure the `config` volume on line 117 also has an `else if` under the existing secret def to check for our `global.existingSecretForConfig` value.
```
          {{- else if .Values.global.existingSecretForConfig }}
          secret:
            secretName: {{ .Values.global.existingSecretForConfig }}
```

```chart/deps/loki-simple-scalable/templates/service-memberlist.yaml```
- Ensure name is `tcp` and not `http`.
```
   ports:
     name: tcp
```

```chart/deps/loki-simple-scalable/values.yaml loki-new/chart/deps/loki-simple-scalable/values.yaml```
- Change `selfMonitoring` to `true`.
```
   selfMonitoring:
     enabled: true
```

```chart/deps/loki-simple-scalable/templates/tokengen/job-tokengen.yaml```
- Add enterprise tokengen tolerations value to job template on line 88
```
      {{- with .Values.enterprise.tokengen.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

```chart/deps/loki-simple-scalable/values.yaml```
- Add tolerations value to `enterprise.tokengen` block starting on line 276 eg:
```
    # -- Tolerations for tokengen Job
    tolerations: []
```

# Testing new Loki Version

- Deploy Loki as a part of BigBang  
```
helm upgrade \
  --install bigbang ./bigbang/chart \
  --create-namespace \
  --namespace bigbang \
  --values ./bigbang/chart/values.yaml \
  --values ./bigbang/chart/ingress-certs.yaml \
  --values ./overrides/loki.yaml \
  --set gatekeeper.enabled=false \
  --set clusterAuditor.enabled=false \
  --set twistlock.enabled=false \
  --set loki.enabled=true \
  --set promtail.enabled=true \
  --set logging.enabled=false \
  --set eckoperator.enabled=false \
  --set fluentbit.enabled=true \
  --set jaeger.enabled=false \
  --set tempo.enabled=true \
  --set addons.minioOperator.enabled=true
```
`overrides/loki.yaml`
```
loki:
  git:
    tag: ""
    branch: "my-branch-name-goes-here"
  enabled: true
  strategy: scalable
  values:
    global:
      createGlobalConfig: true
      existingSecretForConfig: "loki-config"
```
- Visit `https://grafana.bigbang.dev` and login
- Search dashboards for `Loki Dashboard Quick Search` and confirm log data is being populated/no error messages.
- Navigate to `configuration -> Data Sources -> Loki` and then click `Save & Test` to ensure Data Source changes can be saved successfully.

