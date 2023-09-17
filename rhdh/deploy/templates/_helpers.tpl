{{/*
Expand the name of the chart.
*/}}
{{- define "rhdh.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rhdh.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rhdh.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rhdh.labels" -}}
helm.sh/chart: {{ include "rhdh.chart" . }}
{{ include "rhdh.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rhdh.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rhdh.fullname" . }}
app.kubernetes.io/instance:  {{ include "rhdh.fullname" . }}
{{- end }}

{{/*


{{/*
Create the name of the service account to use
*/}}
{{- define "rhdh.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rhdh.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "rhdh.serviceAccount.annotations" -}}
{{- if .Values.serviceAccount.create }}
annotations: 
    serviceaccounts.openshift.io/oauth-redirecturi.backstage: {{ .Values.serviceAccount.annotations.CallbackUrl }}
{{- end }}
{{- end }}

{{- define "rhdh.serviceAccount.automountServiceAccountToken" -}}
{{- default "true" .Values.serviceAccount.automountServiceAccountToken }}
{{- end }}

{{/*
Check for existing secret
*/}}

{{- define "gen.postgres-password" -}}
{{- if .Values.postgresql.databasePassword }}
databasePassword: {{ .Values.postgresql.databasePassword | quote }}
{{- else -}}
{{/*
This will NOT work with ArgoCD, it currently does not support lookup functions
*/}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace  (printf "%s-%s" (include "rhdh.fullname" . ) "postgresql") -}}
{{- if $secret -}}
{{/*
   Reusing existing secret data
databasePassword: {{ $secret.data.databasePassword | quote }}
*/}}
databasePassword: {{ $secret.data.databasePassword | b64dec | quote }}
{{- else -}}
{{/*
    Generate new data
*/}}
databasePassword: "{{ randAlphaNum 20 }}"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the oauth proxy name
*/}}
{{- define "rhdh.oauthProxy.name" -}}
{{- printf "%s-oauth-proxy" (include "rhdh.fullname" . ) }}
{{- end }}

{{/*
Create the postgresql name
*/}}
{{- define "rhdh.postgresql.name" -}}
{{- printf "%s-postgresql" (include "rhdh.fullname" . ) }}
{{- end }}

{{/*
Postgresql Common labels
*/}}
{{- define "rhdh.postgresql.labels" -}}
helm.sh/chart: {{ include "rhdh.chart" . }}
app.kubernetes.io/name: "postgresql"
app.kubernetes.io/instance: {{ include "rhdh.fullname"  . }}
app.kubernetes.io/component: primary
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Postresql Selector labels
*/}}
{{- define "rhdh.postgresql.selectorLabels" -}}
app.kubernetes.io/name: "postgresql"
app.kubernetes.io/instance: {{ include "rhdh.fullname"  . }}
app.kubernetes.io/component: primary
{{- end }}
