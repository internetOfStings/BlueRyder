[Route('GET', '/aes-example')]
[Route('POST', '/aes-example')]
class AESExample {

    [Response] Response([string] $HttpMethod, [hashtable] $GET, [hashtable] $POST) {

        $Key256 = [CommonAES]::NewKey()
        $IV = [CommonAES]::NewIV()
        $text = 'This is example text.'
        $encryptedData = [CommonAES]::Encrypt($Key256, $IV, $text)
        $unencryptedData = [CommonAES]::Decrypt($Key256, $IV, $encryptedData)


        if ($HttpMethod -eq 'GET') {
            $html = '
            <!DOCTYPE html>
            <html>
            <body>

            <h2>AES Example</h2>

            <h3>Encrypt File</h3>
            <form action="/aes-example" method="POST">

                <label for="path">Clear Text:</label><br>
                <input style="width: 25rem;" type="text" id="clear-text" name="clear-text" value="' + $text + '"><br>

                <label for="name">AES 256 Key:</label><br>
                <input style="width: 25rem;" type="text" id="key" name="key" value="' + $Key256 + '"><br><br>

                <label for="content">IV:</label><br>
                <input style="width: 25rem;" type="text" id="iv" name="iv" value="' + $IV + '"><br><br>

                <input type="submit" value="Submit">

            </form> 

            <h3>Decrypt File</h3>
            <form action="/aes-example" method="POST">

                <label for="path">Crypt Text:</label><br>
                <input style="width: 25rem;" type="text" id="crypt-text" name="crypt-text" value="' + $encryptedData + '"><br>

                <label for="name">AES 256 Key:</label><br>
                <input style="width: 25rem;" type="text" id="key" name="key" value="' + $Key256 + '"><br><br>

                <label for="content">IV:</label><br>
                <input style="width: 25rem;" type="text" id="iv" name="iv" value="' + $IV + '"><br><br>

                <input type="submit" value="Submit">

            </form> 


            <p>Click Submit. Data will be posted to /aes-example (this page) to be processed.</p>

            </body>
            </html>
            '

        } else {

            $byteKey =[byte[]]($POST.key -split ' ' | foreach{[byte]$_})
            $byteIV =[byte[]]($POST.iv -split ' ' | foreach{[byte]$_})

            if ($null -ne $POST.'clear-text') {

                $clearText = $POST.'clear-text'
                $cryptText = [CommonAES]::Encrypt($byteKey, $byteIV, $clearText)

            } else {

                $cryptText = $POST.'crypt-text'
                $byteCryptText =[byte[]]($cryptText -split ' ' | foreach{[byte]$_})
                $clearText = [CommonAES]::Decrypt($byteKey, $byteIV, $byteCryptText)

            }

            $html = 
            "
                <!DOCTYPE html><html><body>

                <h2>AES Example</h2>

                <p>If you need this data save it now.</p>
                    <br>
                <p>Clear Text: $clearText</p>
                    <br>
                <p>Crypt Text: $cryptText</p>
                    <br>
                <p>Key: $($POST.key)</p>
                    <br>
                <p>IV: $($POST.iv)</p>

                </body></html>
            "
        }
        return [Response]::new(200, $html);
    }
}