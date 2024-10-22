{{- define "fullname" }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define the nodeSelector for rosecape pods
EXAMPLE USAGE: {{ include "rosecape.podNodeSelector" (dict "Release" .Release "Values" .Values "nodeSelector" $nodeSelector) }}
*/}}
{{- define "rosecape.podNodeSelector" }}
{{- .nodeSelector | default .Values.defaultNodeSelector | toYaml }}
{{- end }}

{{/*
Define the Affinity for rosecape pods
EXAMPLE USAGE: {{ include "rosecape.podAffinity" (dict "Release" .Release "Values" .Values "affinity" $affinity) }}
*/}}
{{- define "rosecape.podAffinity" }}
{{- .affinity | default .Values.defaultAffinity | toYaml }}
{{- end }}

{{/*
Define the Tolerations for rosecape pods
EXAMPLE USAGE: {{ include "rosecape.podTolerations" (dict "Release" .Release "Values" .Values "tolerations" $tolerations) }}
*/}}
{{- define "rosecape.podTolerations" }}
{{- .tolerations | default .Values.defaultTolerations | toYaml }}
{{- end }}

{{- define "standard_iceberg_rest_environment" }}

  - name: CATALOG_URI
    valueFrom:
      secretKeyRef:
          name: {{ .Values.icebergRestCatalogSecret }}
          key: uri

  - name: CATALOG_WAREHOUSE
    value: {{ .Values.catalogs.default.warehouse }}

  - name: CATALOG_WAREHOUSE_NAME
    value: {{ .Values.catalogs.default.name }}

  {{- if .Values.catalogs.raw.enabled }}
  - name: CATALOG_RAW_WAREHOUSE
    value: {{ .Values.catalogs.raw.warehouse }}

  - name: CATALOG_RAW_WAREHOUSE_NAME
    value: {{ .Values.catalogs.raw.name }}
  {{- end }}

  {{- if .Values.catalogs.clean.enabled }}
  - name: CATALOG_CLEAN_WAREHOUSE
    value: {{ .Values.catalogs.clean.warehouse }}

  - name: CATALOG_CLEAN_WAREHOUSE_NAME
    value: {{ .Values.catalogs.clean.name }}
  {{- end }}
{{- end }}

{{- define "aws_environment" }}
  - name: CATALOG_IO__IMPL
    value: "org.apache.iceberg.aws.s3.S3FileIO"

  # - name: CATALOG_s3_path__style__access
  #   value: {{ .Values.s3.pathStyleAccess | quote}}

  # - name: AWS_REGION
  #   value: {{ .Values.s3.region }}

  # {{- if .Values.s3.endpoint }}
  # - name: CATALOG_s3_endpoint
  #   value: {{ .Values.s3.endpoint }}
  # {{- end }}

  # - name: CATALOG_s3_access__key__id
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.awsSecretName }}
  #       key: access_key

  # - name: CATALOG_s3_secret__access__key
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.awsSecretName }}
  #       key: secret_access_key
{{- end }}

{{- define "azure_environment" }}
  - name: CATALOG_IO__IMPL
    value: "org.apache.iceberg.azure.adlsv2.ADLSFileIO"
  
  # - name: AZURE_CLIENT_ID
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.azureSecretName }}
  #       key: client_id

  # - name: AZURE_CLIENT_SECRET
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.azureSecretName }}
  #       key: client_secret

  # - name: AZURE_TENANT_ID
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.azureSecretName }}
  #       key: tenant_id
{{- end }}

{{- define "gcp_environment" }}
  - name: CATALOG_IO__IMPL
    value: "org.apache.iceberg.gcp.gcs.GCSFileIO"

  # - name: CATALOG_GCS_PROJECT_ID
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.gcpSecretName }}
  #       key: project_id

  # - name: CATALOG_GCS_OAUTH2_TOKEN
  #   valueFrom:
  #     secretKeyRef:
  #       name: {{ .Values.gcpSecretName }}
  #       key: oauth2_token
{{- end }}

{{- define "dynamic_secret_management" }}
{{- range $i, $config := .Values.envFrom }}
  - name: {{ $config.envName }}
    valueFrom:
      secretKeyRef:
        name: {{ $config.secretName }}
        key: {{ default "value" $config.secretKey }}
  {{- end }}
{{- end }}