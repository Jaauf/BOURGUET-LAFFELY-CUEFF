rule Malicious_NodeJS_Obfuscated
{
    meta:
        description = "Détecte des scripts Node.js obfusqués ou des payloads malveillants"
        author      = "Security Team"
        severity    = "HIGH"

    strings:
        // Techniques d'obfuscation classiques
        $hex_eval    = /eval\s*\(\s*Buffer\.from\s*\(/ ascii
        $b64_exec    = /eval\s*\(\s*atob\s*\(/ ascii
        $fromCharCode = "String.fromCharCode" ascii
        $hex_string  = /\\x[0-9a-fA-F]{2}\\x[0-9a-fA-F]{2}\\x[0-9a-fA-F]{2}/ ascii

        // Payloads reverse shell
        $rev_shell1  = "require('net')" ascii
        $rev_shell2  = "require('child_process')" ascii
        $rev_shell3  = ".exec('bash" ascii
        $rev_shell4  = ".exec('/bin/sh" ascii
        $rev_shell5  = "socket.pipe(" ascii

        // Exfiltration
        $exfil1      = "process.env" ascii
        $exfil2      = "/etc/passwd" ascii
        $exfil3      = "/etc/shadow" ascii

        // Obfuscateurs connus
        $obf1        = "_0x" ascii
        $obf2        = "javascript-obfuscator" ascii

    condition:
        // Fichier JS ou TS
        (
            uint16(0) == 0x2F2F  or   // commence par //
            uint16(0) == 0x636F  or   // commence par 'co' (const/console)
            uint16(0) == 0x7661  or   // commence par 'va' (var)
            uint16(0) == 0x6675      // commence par 'fu' (function)
        )
        and
        (
            // Obfuscation + exécution
            ($hex_eval or $b64_exec or $fromCharCode or $hex_string or $obf1 or $obf2)
            or
            // Reverse shell (2 indicateurs suffisent)
            (2 of ($rev_shell*))
            or
            // Exfiltration combinée avec shell
            ($rev_shell2 and 1 of ($exfil*))
        )
}
