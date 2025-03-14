#!/bin/bash

# Récupérer le dernier tag Git
TAG=$(git describe --tags --abbrev=0)

# Supprimer le préfixe 'v' si présent (ex. v1.0.0 -> 1.0.0)
VERSION=${TAG#v}

# Récupérer le nombre de commits depuis le dernier tag pour le build number
BUILD_NUMBER=$(git rev-list "${TAG}"..HEAD --count)

# Mettre à jour pubspec.yaml
sed -i "s/version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml

echo "Version mise à jour dans pubspec.yaml : $VERSION+$BUILD_NUMBER"