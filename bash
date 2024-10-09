#!/bin/bash

# Créer les groupes
groupes=("PDG" "RH" "Employer" "Marketing" "Service_informatique")
dossiers=("Dossier1" "Dossier2" "Dossier3" "Dossier4" "Dossier5")

# Créer les groupes s'ils n'existent pas déjà
for groupe in "${groupes[@]}"; do
  if ! grep -q "^$groupe:" /etc/group; then
    groupadd "$groupe"
    echo "Groupe $groupe créé."
  else
    echo "Groupe $groupe existe déjà."
  fi
done

# Création des dossiers et fichiers
for ((i = 1; i <= 5; i++)); do
  dossier="Dossier$i"
  mkdir -p "/srv/$dossier"
  echo "Dossier $dossier créé."

  for ((j = 1; j <= 5; j++)); do
    fichier="/srv/$dossier/fichier$j"
    touch "$fichier"
    echo "Fichier fichier$j créé dans $dossier."
  done
done

# Création des utilisateurs
declare -A utilisateurs=(
  ["PDG"]="pdg"
  ["RH1"]="rh1"
  ["RH2"]="rh2"
  ["RH3"]="rh3"
  ["Employer1"]="Tess"
  ["Employer2"]="Will"
  ["Employer3"]="Meg"
  ["Employer4"]="Bruce"
  ["Employer5"]="Laure"
  ["Marketing1"]="mark1"
  ["Marketing2"]="mark2"
  ["Marketing3"]="mark3"
  ["Service_info1"]="serv1"
  ["Service_info2"]="serv2"
  ["Service_info3"]="serv3"
)

# Créer les utilisateurs
for user in "${!utilisateurs[@]}"; do
  username=${utilisateurs[$user]}

  if ! id "$username" &>/dev/null; then
    useradd -m -s /bin/bash "$username"
    echo "Utilisateur $username créé."
  else
    echo "L'utilisateur $username existe déjà."
  fi

  # Définir un mot de passe pour l'utilisateur
  echo "$username:password" | chpasswd
done

# Attribution des permissions par groupe

# PDG - Accès à tous les groupes (Lecture, Écriture, Exécution)
usermod -aG PDG,RH,Employer,Marketing,Service_informatique pdg
chown -R pdg:PDG /srv/
chmod -R 770 /srv/

# RH - Accès à tous sauf PDG (Lecture, Écriture, Exécution)
for rh in rh1 rh2 rh3; do
  usermod -aG RH,Employer,Marketing,Service_informatique "$rh"
done
chown -R :RH /srv/Dossier1 /srv/Dossier2 /srv/Dossier3 /srv/Dossier4 /srv/Dossier5
chmod -R 770 /srv/Dossier1 /srv/Dossier2 /srv/Dossier3 /srv/Dossier4 /srv/Dossier5

# Employés - Accès à leur propre groupe uniquement (Lecture, Écriture, Exécution)
employes=("Tess" "Will" "Meg" "Bruce" "Laure")
for employe in "${employes[@]}"; do
  usermod -aG Employer "$employe"
done
chown -R :Employer /srv/Dossier1
chmod -R 770 /srv/Dossier1

# Marketing - Accès à leur propre groupe avec tous les droits et au groupe Employer en lecture seule
for marketing in mark1 mark2 mark3; do
  usermod -aG Marketing,Employer "$marketing"
done
chown -R :Marketing /srv/Dossier2
chmod -R 770 /srv/Dossier2
chmod -R 750 /srv/Dossier1

# Service informatique - Accès à tous les groupes avec tous les droits
for service in serv1 serv2 serv3; do
  usermod -aG PDG,RH,Employer,Marketing,Service_informatique "$service"
done
chmod -R 770 /srv/
