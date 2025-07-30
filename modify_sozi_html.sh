#!/bin/bash

# Vérifier si un fichier HTML est fourni en argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <fichier_html>"
    exit 1
fi

HTML_FILE="$1"

# Vérifier si le fichier existe
if [ ! -f "$HTML_FILE" ]; then
    echo "Erreur : Le fichier $HTML_FILE n'existe pas."
    exit 1
fi

# Créer des fichiers temporaires pour le code JavaScript et CSS
JS_FILE=$(mktemp)
CSS_FILE=$(mktemp)

# Code JavaScript
cat << 'EOF' > "$JS_FILE"
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const links = document.querySelectorAll("svg a");
        links.forEach(link => {
            link.addEventListener("touchstart", function(event) {
                event.preventDefault();
                const url = this.getAttribute("xlink:href") || this.getAttribute("href");
                if (url) {
                    window.location.href = url;
                }
            }, { passive: false });
        });
    });
</script>
EOF

# Code CSS
cat << 'EOF' > "$CSS_FILE"
svg a {
    cursor: pointer;
    pointer-events: all;
    touch-action: manipulation;
}
EOF

# Faire une sauvegarde du fichier original
cp "$HTML_FILE" "${HTML_FILE}.bak"

# Ajouter le script JavaScript avant </body>
sed -i "/<\/body>/i $(cat "$JS_FILE" | sed 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')" "$HTML_FILE"

# Ajouter le CSS dans la balise <style>
sed -i "/<\/style>/i $(cat "$CSS_FILE" | sed 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')" "$HTML_FILE"

# Désactiver temporairement .sozi-blank-screen pour tester
sed -i 's/\.sozi-blank-screen\s*{/.sozi-blank-screen { display: none; /' "$HTML_FILE"

# Supprimer les fichiers temporaires
rm "$JS_FILE" "$CSS_FILE"

echo "Modifications appliquées à $HTML_FILE. Sauvegarde créée : ${HTML_FILE}.bak"