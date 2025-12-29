{{/*
Expand the name of the chart.
*/}}
{{- define "tcpdump-capture.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains non-alphanumeric characters, it will be converted to lowercase and stripped of symbols.
We use regex sub to remove symbols, so the variable name must be regex_safe.
*/}}
{{- define "tcpdump-capture.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains "-" .Release.Name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as labels.
*/}}
{{- define "tcpdump-capture.labels" -}}
home.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include $.Chart.Name . }}-{{ $.Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "tcpdump-capture.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "tcpdump-capture.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tcpdump-capture.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "tcpdump-capture.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "tcpdump-capture.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}
