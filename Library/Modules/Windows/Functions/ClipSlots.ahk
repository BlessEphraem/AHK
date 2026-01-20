#Requires AutoHotkey v2.0

class ClipSlot {
    static SaveDir := A_Path.User "\.config\AHK\ClipSlots"
    
    static Write(ID) {
        if !DirExist(this.SaveDir)
            DirCreate(this.SaveDir)

        ; 1. Sauvegarder le contenu ACTUEL au cas où (optionnel, mais prudent)
        OldClip := ClipboardAll()

        ; 2. Vider le presse-papier pour pouvoir détecter le changement
        A_Clipboard := ""
        
        ; 3. Envoyer la commande de copie (Ctrl+C)
        SendInput "^c"
        
        ; 4. Attendre que le presse-papier contienne des données (Max 2 secondes)
        if !ClipWait(2) {
            ToolTip "Échec de la copie (Timeout) ❌"
            ; On restaure l'ancien contenu si la copie échoue
            A_Clipboard := OldClip
            SetTimer () => ToolTip(), -1000
            return
        }

        ; 5. Maintenant on est sûr d'avoir les NOUVELLES données
        ClipData := ClipboardAll()

        Path := this.SaveDir "\Slot_" ID ".clip"
        
        try {
            f := FileOpen(Path, "w")
            f.RawWrite(ClipData)
            f.Close()
            ToolTip "Slot " ID " Saved ✅"
        } catch as e {
            ToolTip "Error: " e.Message
        }

        ; (Optionnel) Restaurer le clipboard original si tu veux que ce slot soit "invisible"
        ; A_Clipboard := OldClip 
        
        SetTimer () => ToolTip(), -1000
    }

    static Paste(ID) {
        Path := this.SaveDir "\Slot_" ID ".clip"

        if !FileExist(Path) {
            ToolTip "Slot " ID " vide ❌"
            return
        }

        try {
            ; 1. Lire les données brutes (retourne un Buffer)
            RawData := FileRead(Path, "RAW")
            
            ; 2. CORRECTION : Convertir le Buffer en objet ClipboardAll valide
            ClipData := ClipboardAll(RawData)
            
            ; 3. Mettre dans le presse-papier
            A_Clipboard := ClipData
            
            ; Attendre que le clipboard soit prêt (important pour les gros fichiers)
            Sleep 100 
            SendInput "^{v}"
            
            ToolTip "Slot " ID " Collé ⚡"
        } catch as e {
            ToolTip "Erreur lecture: " e.Message
        }
    }
}
