#!/bin/bash

# =================================================================
# MOODLE DEPLOYMENT SKRIPT - AZURE VIA TERRAFORM
# =================================================================
# Dieses Skript automatisiert die Bereitstellung von Moodle auf Azure 
# mit Terraform, inklusive umfassender Protokollierung und Fehlerbehandlung
# =================================================================

set -e  # Sofortiger Abbruch bei Fehlern (Exit-Status ungleich Null)

# =================================================================
# KONFIGURATIONSVARIABLEN
# =================================================================
LOG_DIR="./logs"
DEPLOY_LOG="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"
INFO_LOG="${LOG_DIR}/deployment_info.txt"
MODULES_DIR="./Modules"

# Farbcodes für visuelle Terminal-Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

# =================================================================
# HILFSFUNKTIONEN
# =================================================================

# Protokolliert Nachrichten in Konsole und Logdatei mit Farben
# Verwendung: log "Nachricht" [INFO|SUCCESS|WARNING|ERROR]
log() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  mkdir -p "$LOG_DIR"
  local formatted_message="[$timestamp] [$level] $message"
  echo "$formatted_message" >> "$DEPLOY_LOG"

  # Anzeige mit entsprechender Farbe basierend auf Nachrichtenebene
  case "$level" in
    "INFO") echo -e "${BLUE}$formatted_message${NC}" ;;
    "SUCCESS") echo -e "${GREEN}$formatted_message${NC}" ;;
    "WARNING") echo -e "${YELLOW}$formatted_message${NC}" ;;
    "ERROR") echo -e "${RED}$formatted_message${NC}" ;;
    *) echo "$formatted_message" ;;
  esac
}

# Prüft, ob ein Befehl existiert
# Verwendung: command_exists terraform
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Überprüft, ob alle erforderlichen Abhängigkeiten installiert sind
check_dependencies() {
  log "Überprüfe Abhängigkeiten..."
  if ! command_exists terraform; then
    log "Terraform ist nicht installiert. Bitte installieren Sie Terraform." "ERROR"
    exit 1
  fi
  if ! command_exists az; then
    log "Azure CLI ist nicht installiert. Bitte installieren Sie Azure CLI." "ERROR"
    exit 1
  fi
  log "Alle Abhängigkeiten sind installiert." "SUCCESS"
}

# Überprüft den Azure-Anmeldestatus und fordert bei Bedarf zur Anmeldung auf
check_azure_login() {
  log "Überprüfe Azure-Anmeldestatus..."
  if ! az account show &>/dev/null; then
    log "Nicht bei Azure angemeldet. Führe 'az login' aus..." "WARNING"
    az login
  fi

  local account=$(az account show --query name -o tsv)
  log "Bei Azure-Abonnement angemeldet: $account" "SUCCESS"
}

# Führt die Terraform-Bereitstellungsschritte aus
run_terraform() {
  log "Starte Terraform-Bereitstellung..." "INFO"

  # Terraform initialisieren (inklusive Module)
  log "Initialisiere Terraform..." "INFO"
  terraform init | tee -a "$DEPLOY_LOG"

  # Terraform-Konfiguration validieren
  log "Validiere Terraform-Konfiguration..." "INFO"
  terraform validate | tee -a "$DEPLOY_LOG"

  # Terraform-Plan erstellen
  log "Erstelle Terraform-Plan..." "INFO"
  terraform plan -out=moodle.tfplan | tee -a "$DEPLOY_LOG"

  # Terraform-Plan anwenden ohne Bestätigung
  log "Wende Terraform-Plan an..." "INFO"
  terraform apply -auto-approve moodle.tfplan | tee -a "$DEPLOY_LOG"

  log "Terraform-Bereitstellung erfolgreich abgeschlossen." "SUCCESS"
}

# Erstellt eine Zusammenfassung mit wichtigen Bereitstellungsinformationen
generate_summary() {
log "Erstelle Bereitstellungszusammenfassung..." "INFO"

# Erstellt eine Zusammenfassungsdatei mit Terraform-Outputs
cat > "$INFO_LOG" <<EOF

Moodle-Bereitstellungsinformationen (Bereitgestellt am $(date))
=======================================================

Ressourcengruppe: $(terraform output -raw resource_group_name)
Moodle-URL: $(terraform output -raw moodle_url)
Moodle-Admin-URL: $(terraform output -raw moodle_admin_url)

Verbindungsanweisungen:
$(terraform output -raw connection_instructions)

Hinweis: Es kann einige Minuten dauern, bis Moodle nach der Bereitstellung vollständig initialisiert ist.

EOF

log "Bereitstellungsinformationen gespeichert in $INFO_LOG" "SUCCESS"

# Wichtige Informationen auch in der Konsole anzeigen
echo ""
echo -e "${GREEN}Wichtige Informationen:${NC}"
echo "- Moodle-URL: $(terraform output -raw moodle_url)"
echo "- Moodle-Admin-URL: $(terraform output -raw moodle_admin_url)"
echo "- Ressourcengruppe: $(terraform output -raw resource_group_name)"
echo ""
echo "- Verbindungsanweisungen:"
echo "$(terraform output -raw connection_instructions)"
}

# =================================================================
# HAUPTSKRIPT-AUSFÜHRUNG
# =================================================================

main() {

mkdir -p "$LOG_DIR"

echo -e "${GREEN}"
echo -e "==================================================="
echo -e " Moodle-Bereitstellung auf Azure via Terraform "
echo -e "==================================================="
echo -e "${NC}"

log "Starte Moodle-Bereitstellungsprozess..."

check_dependencies
check_azure_login
run_terraform
generate_summary

log ""
log "Detailliertes Bereitstellungsprotokoll gespeichert in: $DEPLOY_LOG"

}

# Hauptfunktion ausführen
main