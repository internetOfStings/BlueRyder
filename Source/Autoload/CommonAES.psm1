
<#
    CommonAES Example:
    $Key256 = [CommonAES]::NewKey()
    $IV = [CommonAES]::NewIV()
    $text = 'This is example text.'
    $encryptedData = [CommonAES]::Encrypt($Key256, $IV, $text)
    Write-Host $encryptedData
    $unencryptedData = [CommonAES]::Decrypt($Key256, $IV, $encryptedData)
    Write-Host $unencryptedData
#>
class CommonAES{

    static [byte[]] NewKey(){
        # Default key length is 256 (on my system), thats what I return here
        return [System.Security.Cryptography.Aes]::Create().Key
    }

    static [byte[]] NewIV() {
        return [System.Security.Cryptography.Aes]::Create().IV
    }

    static [byte[]] Encrypt([byte[]]$key, [byte[]]$iv, [string]$text) {

        $aes = [System.Security.Cryptography.Aes]::Create()
        $encryptor = $aes.CreateEncryptor($key, $iv);
        $msEncrypt = [System.IO.MemoryStream]::new()
        $csEncrypt = [System.Security.Cryptography.CryptoStream]::new($msEncrypt, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
        $swEncrypt = [System.IO.StreamWriter]::new($csEncrypt)
        $swEncrypt.Write($text)

        $swEncrypt.Dispose()
        $msEncrypt.Dispose()
        $csEncrypt.Dispose()
        $aes.Dispose()

        # Returns encrypted data as a byte array
        return $msEncrypt.ToArray()
    }

    static [string] Decrypt([byte[]]$key, [byte[]]$iv, [byte[]]$encryptedBytes) {

        $aes = [System.Security.Cryptography.Aes]::Create()
        $decryptor = $aes.CreateDecryptor($key, $iv)

        $msDecrypt = [System.IO.MemoryStream]::new($encryptedBytes)
        $csDecrypt = [System.Security.Cryptography.CryptoStream]::new($msDecrypt, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
        $srDecrypt = [System.IO.StreamReader]::new($csDecrypt)

        $clearText = $srDecrypt.ReadToEnd()

        $msDecrypt.Dispose()
        $csDecrypt.Dispose()
        $srDecrypt.Dispose()
        $aes.Dispose()

        return $clearText
    }
}