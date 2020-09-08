{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "postgresql-auto-failover.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgresql-auto-failover.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified monitor name.
*/}}
{{- define "postgresql-auto-failover.monitor.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "%s-monitor" .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-monitor" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-monitor" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified nodes name.
*/}}
{{- define "postgresql-auto-failover.node.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "%s-node" .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- printf "%s-node" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s-node" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql-auto-failover.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Global labels
*/}}
{{- define "postgresql-auto-failover.labels" -}}
helm.sh/chart: {{ include "postgresql-auto-failover.chart" . }}
app.kubernetes.io/name: {{ include "postgresql-auto-failover.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Monitor labels
*/}}
{{- define "postgresql-auto-failover.monitor.labels" -}}
helm.sh/chart: {{ include "postgresql-auto-failover.chart" . }}
{{ include "postgresql-auto-failover.monitor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Monitor selector labels
*/}}
{{- define "postgresql-auto-failover.monitor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql-auto-failover.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
role: monitor
{{- end }}

{{/*
Monitor labels
*/}}
{{- define "postgresql-auto-failover.node.labels" -}}
helm.sh/chart: {{ include "postgresql-auto-failover.chart" . }}
{{ include "postgresql-auto-failover.node.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Node selector labels
*/}}
{{- define "postgresql-auto-failover.node.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql-auto-failover.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
role: node
{{- end }}

