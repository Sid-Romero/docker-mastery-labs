{{/*
Expand the name of the chart.
*/}}
{{- define "job-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains non-alphanumeric characters, it will be converted to alphanumeric.
*/}}
{{- define "job-app.fullname" -}}
{{- $fullName := printf "%s-%s" .Release.Name .Chart.Name -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "job-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "job-app.labels" -}}
happ.kubernetes.io/name: {{ include "job-app.name" . }}
happ.kubernetes.io/instance: {{ .Release.Name }}
happ.kubernetes.io/managed-by: {{ .Release.Service }}
happ.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ include "job-app.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "job-app.selectorLabels" -}}
happ.kubernetes.io/name: {{ include "job-app.name" . }}
happ.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "job-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "job-app.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
