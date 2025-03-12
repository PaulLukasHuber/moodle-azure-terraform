#!/bin/bash

# =================================================================
# MOODLE DEPLOYMENT SKRIPT - AZURE MIT TERRAFORM
# =================================================================
# Dieses Skript automatisiert die Bereitstellung von Moodle auf Azure
# unter Verwendung von Terraform. Es übernimmt:
# - Umgebungsprüfungen (Terraform, Azure CLI)
# - Terraform-Initialisierung, Validierung und Anwendung
# - Detaillierte Protokollierung des Bereitstellungsprozesses
# - Erstellung einer Zusammenfassung mit wichtigen Ausgaben
# =================================================================

set -e  # Beendet das Skript sofort, wenn ein Befehl mit Fehler endet

# =================================================================
# KONFIGURATIONSVARIABLEN
# =================================================================
LOG_DIR="./logs"
DEPLOY_LOG="${LOG_DIR}/deploy_$(date +%Y%m%d_%H%M%S).log"
INFO_LOG="${LOG_DIR}/deployment_info.txt"
MODULES_DIR="./Modules"

# Farbcodes für Terminalausgabe zur besseren Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # Keine Farbe

# =================================================================
# HILFSFUNKTIONEN
# =================================================================

# Protokolliert Nachrichten sowohl in Konsole als auch in Logdatei mit Farben
# Verwendung: log "Nachricht" [INFO|SUCCESS|WARNING|ERROR]
log() {
  local message="$1"
  local level="${2:-INFO}"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  mkdir -p "$LOG_DIR"
  local formatted_message="[$timestamp] [$level] $message"
  echo "$formatted_message" >> "$DEPLOY_LOG"
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

# Überprüft, ob erforderliche Abhängigkeiten installiert sind
check_dependencies() {
  log "Prüfe Abhängigkeiten..."
  if ! command_exists terraform; then
    log "Terraform nicht installiert. Bitte installieren." "ERROR"
    exit 1
  fi
  if ! command_exists az; then
    log "Azure CLI nicht installiert. Bitte installieren." "ERROR"
    exit 1
  fi
  log "Alle Abhängigkeiten vorhanden." "SUCCESS"
}

# Überprüft den Azure-Anmeldestatus und fordert bei Bedarf zur Anmeldung auf
check_azure_login() {
  log "Prüfe Azure Login Status..."
  if ! az account show &>/dev/null; then
    log "Nicht bei Azure angemeldet. Bitte 'az login' ausführen." "ERROR"
    az login
  else
    local account=$(az account show --query name -o tsv)
    log "Eingeloggt in Azure Subscription: $account" "SUCCESS"
  }
}

# Führt Terraform-Befehle aus (init, validate, plan, apply)
run_terraform() {
  log "Starte Terraform Deployment..." "INFO"

  # Terraform initialisieren (inkl. Module)
  log "Initialisiere Terraform (inkl. Module)..." "INFO"
  terraform init | tee -a "$DEPLOY_LOG"

  # Terraform-Konfiguration validieren
  log "Validiere Terraform-Konfiguration..." "INFO"
  terraform validate | tee -a "$DEPLOY_LOG"

  # Terraform-Plan erstellen
  log "Erstelle Terraform Plan..." "INFO"
  terraform plan -out=moodle.tfplan | tee -a "$DEPLOY_LOG"

  # Terraform-Plan automatisch anwenden ohne Bestätigung
  log "Wende Terraform Plan an..." "INFO"
  terraform apply -auto-approve moodle.tfplan | tee -a "$DEPLOY_LOG"

  log "Terraform Deployment abgeschlossen." "SUCCESS"
}

# Erstellt eine Zusammenfassung der Bereitstellung mit wichtigen Informationen
generate_summary() {
  log "Generiere Deployment-Zusammenfassung..." "INFO"

# Erstellt eine Zusammenfassungsdatei mit den wichtigen Terraform-Outputs
cat > "$INFO_LOG" <<EOF

Moodle Deployment Informationen (Deployzeit: $(date))
=======================================================

Resource Group: $(terraform output -raw resource_group_name)
Moodle URL: $(terraform output -raw moodle_url)
Moodle Admin URL: $(terraform output -raw moodle_admin_url)

Verbindungsinformationen:
$(terraform output -raw connection_instructions)

Hinweis: Es kann einige Minuten dauern, bis Moodle vollständig initialisiert ist.

EOF

log "Deployment Informationen gespeichert in $INFO_LOG" "SUCCESS"

# Zeigt wichtige Informationen auch in der Konsole an
echo ""
echo -e "${GREEN}Wichtige Informationen:${NC}"
echo "- Moodle URL: $(terraform output -raw moodle_url)"
echo "- Moodle Admin URL: $(terraform output -raw moodle_admin_url)"
echo "- Resource Group: $(terraform output -raw resource_group_name)"
echo ""
echo "- Verbindungshinweise:"
echo "$(terraform output -raw connection_instructions)"
}

# =================================================================
# HAUPTAUSFÜHRUNG DES SKRIPTS
# =================================================================

main() {
  
mkdir -p "$LOG_DIR"

echo -e "${GREEN}"
echo -e "==================================================="
echo -e " Moodle Deployment zu Azure via Terraform "
echo -e "==================================================="
echo -e "${NC}"

log "Starte Moodle Deployment Prozess..."

check_dependencies
check_azure_login
run_terraform
generate_summary

log ""
log "Deployment Log gespeichert in: $DEPLOY_LOG" 

}

# Führt die Hauptfunktion aus
main